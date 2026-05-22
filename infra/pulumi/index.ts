import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";

const config = new pulumi.Config();
const env = config.require("environment");
const domain = config.require("domain");
const region = config.require("region");

// VPC
const vpc = new awsx.ec2.Vpc("lunar-broker-vpc", {
  cidrBlock: "10.0.0.0/16",
  numberOfAvailabilityZones: 2,
  subnets: [
    { type: "public", cidrMask: 24 },
    { type: "private", cidrMask: 24 },
  ],
  tags: { Name: `lunar-broker-${env}-vpc`, Environment: env },
});

// ECS Cluster
const cluster = new aws.ecs.Cluster("lunar-broker-cluster", {
  name: `lunar-broker-${env}`,
  tags: { Environment: env },
});

// RDS (PostgreSQL / Supabase-compatible)
const dbSubnetGroup = new aws.rds.SubnetGroup("lunar-broker-db-subnet", {
  subnetIds: vpc.privateSubnetIds,
  tags: { Name: `lunar-broker-${env}-db-subnet`, Environment: env },
});

const db = new aws.rds.Instance("lunar-broker-db", {
  engine: "postgres",
  engineVersion: "15.6",
  instanceClass: "db.t3.medium",
  allocatedStorage: 50,
  dbName: "lunar_broker",
  username: "lunar_admin",
  password: config.requireSecret("dbPassword"),
  dbSubnetGroupName: dbSubnetGroup.name,
  vpcSecurityGroupIds: [vpc.securityGroups[0].id],
  skipFinalSnapshot: env === "dev",
  backupRetentionPeriod: env === "prod" ? 30 : 7,
  storageEncrypted: true,
  tags: { Name: `lunar-broker-${env}-db`, Environment: env },
});

// Redis / ElastiCache
const redis = new aws.elasticache.Cluster("lunar-broker-redis", {
  engine: "redis",
  engineVersion: "7.1",
  nodeType: "cache.t3.micro",
  numCacheNodes: 1,
  subnetGroupName: new aws.elasticache.SubnetGroup("redis-subnet", {
    subnetIds: vpc.privateSubnetIds,
  }).name,
  securityGroupIds: [vpc.securityGroups[0].id],
  tags: { Name: `lunar-broker-${env}-redis`, Environment: env },
});

// S3 buckets
const assetsBucket = new aws.s3.BucketV2("lunar-broker-assets", {
  bucket: `lunar-broker-${env}-assets`,
  forceDestroy: env === "dev",
  tags: { Environment: env },
});

// ECR repositories
const gatewayRepo = new aws.ecr.Repository("lunar-gateway", {
  name: `lunar-broker-${env}-gateway`,
  tags: { Environment: env },
});

const apiRepo = new aws.ecr.Repository("lunar-rust-api", {
  name: `lunar-broker-${env}-rust-api`,
  tags: { Environment: env },
});

const frontendRepo = new aws.ecr.Repository("lunar-frontend", {
  name: `lunar-broker-${env}-frontend`,
  tags: { Environment: env },
});

// ALB
const alb = new awsx.lb.ApplicationLoadBalancer("lunar-broker-alb", {
  subnetIds: vpc.publicSubnetIds,
  tags: { Name: `lunar-broker-${env}-alb`, Environment: env },
});

// Fargate services
const gatewayService = new awsx.ecs.FargateService("lunar-gateway", {
  cluster: cluster.arn,
  taskDefinitionArgs: {
    container: {
      image: gatewayRepo.url,
      cpu: 256,
      memory: 512,
      portMappings: [{ containerPort: 8080, targetGroup: alb.defaultTargetGroup }],
      environment: [
        { name: "SUPABASE_URL", value: db.endpoint },
        { name: "REDIS_URL", value: redis.cacheNodes[0].address },
      ],
    },
  },
  tags: { Environment: env },
});

const apiService = new awsx.ecs.FargateService("lunar-rust-api", {
  cluster: cluster.arn,
  taskDefinitionArgs: {
    container: {
      image: apiRepo.url,
      cpu: 512,
      memory: 1024,
      portMappings: [{ containerPort: 8081 }],
    },
  },
  tags: { Environment: env },
});

const frontendService = new awsx.ecs.FargateService("lunar-frontend", {
  cluster: cluster.arn,
  taskDefinitionArgs: {
    container: {
      image: frontendRepo.url,
      cpu: 256,
      memory: 512,
      portMappings: [{ containerPort: 3000 }],
      environment: [
        { name: "NEXT_PUBLIC_API_URL", value: pulumi.interpolate`https://${domain}/api` },
      ],
    },
  },
  tags: { Environment: env },
});

// DNS
const zone = aws.route53.getZone({ name: domain, privateZone: false });

new aws.route53.Record("lunar-broker-dns", {
  zoneId: zone.then(z => z.zoneId),
  name: env === "prod" ? domain : `${env}.${domain}`,
  type: "A",
  aliases: [{
    name: alb.loadBalancer.dnsName,
    zoneId: alb.loadBalancer.zoneId,
    evaluateTargetHealth: true,
  }],
});

// Outputs
export const vpcId = vpc.vpcId;
export const clusterArn = cluster.arn;
export const dbEndpoint = db.endpoint;
export const redisEndpoint = redis.cacheNodes[0].address;
export const albDnsName = alb.loadBalancer.dnsName;
export const gatewayRepoUrl = gatewayRepo.url;
