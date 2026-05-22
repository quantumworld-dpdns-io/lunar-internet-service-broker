# API Reference

## Base URL

```
https://api.lunar-broker.example.com/api/v1
```

## Authentication

All API requests (except health) require a Bearer JWT token:

```
Authorization: Bearer <token>
```

### POST /auth/login
```json
{
  "email": "user@example.com",
  "password": "secure_password"
}
```

### POST /auth/register
```json
{
  "email": "user@example.com",
  "password": "secure_password",
  "display_name": "User Name",
  "role": "operator"
}
```

## Marketplace

### GET /offers
Query params: `zone`, `status`, `min_bandwidth`, `max_price`, `page`, `limit`

### POST /offers
```json
{
  "relay_id": "uuid",
  "bandwidth_mbps": 100,
  "price_per_mbps": 0.5,
  "available_from": "2026-06-01T00:00:00Z",
  "available_until": "2026-06-30T23:59:59Z",
  "zone": "nearside"
}
```

### GET /requests
Query params: `zone`, `status`, `min_budget`, `max_budget`, `page`, `limit`

### POST /requests
```json
{
  "rover_id": "uuid",
  "bandwidth_mbps": 50,
  "max_budget": 500,
  "requested_from": "2026-06-10T00:00:00Z",
  "requested_until": "2026-06-20T23:59:59Z",
  "zone": "nearside"
}
```

### GET /matches
### POST /commitments

## Error Responses

```json
{
  "error": "description",
  "code": "ERROR_CODE",
  "details": {}
}
```

Status codes:
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 429: Rate Limited
- 500: Internal Error
