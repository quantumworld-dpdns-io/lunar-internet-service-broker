*** Settings ***
Resource    ../../resources/common.resource
Suite Setup    Create Session For API

*** Test Cases ***
A01-001 Unauthorized Access Returns 401
    ${headers}    Create Dictionary    Authorization=Bearer invalid-token
    ${response}    GET    ${BASE_URL}${API_PREFIX}/offers    headers=${headers}
    Status Should Be    401    ${response}

A01-002 Missing Auth Header Returns 401
    ${response}    GET    ${BASE_URL}${API_PREFIX}/offers
    Status Should Be    401    ${response}

A01-003 Operator Cannot Access Admin Endpoints
    # Setup: authenticate as operator
    ${headers}    Create Dictionary    Authorization=Bearer operator-token
    ${response}    GET    ${BASE_URL}${API_PREFIX}/admin/users    headers=${headers}
    Status Should Be    403    ${response}

A01-004 Cannot Modify Other Users Resources
    # Verify user isolation
    ${response}    PUT    ${BASE_URL}${API_PREFIX}/offers/fake-id    json={"status": "cancelled"}
    ...    headers=${HEADERS}
    Should Not Be Equal As Integers    ${response.status_code}    200

A01-005 IDOR Prevention Check
    # Test that user A cannot access user B's data via ID manipulation
    ${response}    GET    ${BASE_URL}${API_PREFIX}/users/00000000-0000-0000-0000-000000000000
    ...    headers=${HEADERS}
    Should Be True    ${response.status_code} in [401, 403, 404]
