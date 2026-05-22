# Security Architecture

## Overview

Security is implemented at multiple layers:

- **Network**: Nginx WAF, rate limiting, IP filtering, mTLS
- **Application**: JWT auth, RBAC, input validation, CSP headers
- **Blockchain**: Smart contract audits, multi-sig, timelocks
- **Infrastructure**: Pulumi security groups, ECR scanning, Trivy

## OWASP Top 10 Coverage

| A# | Category | Test File | Status |
|----|----------|-----------|--------|
| A01 | Broken Access Control | `owasp_a01_access_control.robot` | ✅ |
| A02 | Cryptographic Failures | — | Via TLS + JWT |
| A03 | Injection | `owasp_a03_injection.robot` | ✅ |
| A04 | Insecure Design | `owasp_top10.robot` | ✅ |
| A05 | Security Misconfiguration | `owasp_top10.robot` | ✅ |
| A06 | Vulnerable Components | `owasp_top10.robot` | ✅ |
| A07 | Authentication Failures | `owasp_top10.robot` | ✅ |
| A08 | Integrity Failures | `owasp_top10.robot` | ✅ |
| A09 | Logging Failures | `owasp_top10.robot` | ✅ |
| A10 | SSRF + CSRF | `owasp_top10.robot` | ✅ |

## Reporting

See [SECURITY.md](../SECURITY.md) for vulnerability reporting policy.
