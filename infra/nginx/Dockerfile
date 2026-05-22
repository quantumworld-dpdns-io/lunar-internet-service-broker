FROM nginx:1.25-alpine

RUN apk --no-cache add certbot

COPY nginx.conf /etc/nginx/nginx.conf
COPY security-headers.conf /etc/nginx/security-headers.conf
COPY ssl-params.conf /etc/nginx/ssl-params.conf

RUN mkdir -p /etc/nginx/ssl /var/log/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
