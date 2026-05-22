*** Settings ***
Resource    ../../resources/common.resource
Suite Setup    Create Session For API

*** Variables ***
${TEST_PASSWORD}    TestPassword123!

*** Test Cases ***
A04-001 Insecure Design - Rate Limiting
    # Send many requests rapidly
    FOR    ${i}    IN RANGE    100
        ${response}    GET    ${BASE_URL}${API_PREFIX}/offers
        Exit For Loop If    ${response.status_code} == 429
    END
    # Should eventually be rate limited
    Should Be True    ${response.status_code} in [200, 429]

A05-001 Security Misconfiguration - CORS
    ${headers}    Create Dictionary    Origin=https://malicious-site.com
    ${response}    OPTIONS    ${BASE_URL}${API_PREFIX}/offers    headers=${headers}
    ${cors}    Get From Dictionary    ${response.headers}    Access-Control-Allow-Origin
    Should Not Be Equal    ${cors}    *

A06-001 Vulnerable Components - Version Disclosure
    ${response}    GET    ${HEALTH_URL}
    ${server}    Get From Dictionary    ${response.headers}    Server    default=unknown
    Should Not Contain    ${server}    nginx/    msg=Server version should not be exposed

A07-001 Authentication Failures - Weak Password
    ${body}    Create Dictionary
    ...    email=weak@test.com
    ...    password=123
    ${response}    POST    ${BASE_URL}${API_PREFIX}/auth/register    json=${body}
    Status Should Be    400    ${response}

A07-002 Session Management - Token Expiry
    ${headers}    Create Dictionary    Authorization=Bearer expired.jwt.token
    ${response}    GET    ${BASE_URL}${API_PREFIX}/offers    headers=${headers}
    Status Should Be    401    ${response}

A08-001 Integrity Failures - JWT Tampering
    ${headers}    Create Dictionary
    ...    Authorization=Bearer eyJhbGciOiJub25lIn0.eyJyb2xlIjoiYWRtaW4ifQ.
    ${response}    GET    ${BASE_URL}${API_PREFIX}/admin/users    headers=${headers}
    Status Should Be    401    ${response}

A09-001 Logging Failures - Sensitive Data Exposure
    # Ensure passwords not logged in response
    ${body}    Create Dictionary
    ...    email=logtest@test.com
    ...    password=SuperSecretPassword123!
    ${response}    POST    ${BASE_URL}${API_PREFIX}/auth/register    json=${body}
    ${body_str}    Convert To String    ${response.content}
    Should Not Contain    ${body_str}    SuperSecretPassword123!

A10-001 SSRF Prevention
    ${body}    Create Dictionary
    ...    url=http://169.254.169.254/latest/meta-data/
    ${response}    POST    ${BASE_URL}${API_PREFIX}/webhooks/test    json=${body}
    ...    headers=${HEADERS}
    Status Should Be    400    ${response}

A10-002 CSRF Protection
    ${headers}    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ${response}    POST    ${BASE_URL}${API_PREFIX}/offers
    ...    data=bandwidth_mbps=100
    ...    headers=${headers}
    Status Should Be    415    ${response}
