*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String

*** Variables ***
${BASE_URL}    http://localhost:8080
${API_PREFIX}    /api/v1
${HEALTH_URL}    ${BASE_URL}/health

*** Keywords ***
Create Session For API
    Create Session    lunar-api    ${BASE_URL}    verify=true

Health Check Should Succeed
    ${response}    GET    ${HEALTH_URL}
    Status Should Be    200    ${response}
    Dictionary Should Contain Key    ${response.json()}    status

Authenticate As Provider
    [Arguments]    ${email}    ${password}
    ${body}    Create Dictionary    email=${email}    password=${password}
    ${response}    POST    ${BASE_URL}${API_PREFIX}/auth/login    json=${body}
    Status Should Be    200    ${response}
    ${token}    Get From Dictionary    ${response.json()}    token
    Set Suite Variable    ${AUTH_TOKEN}    ${token}
    ${headers}    Create Dictionary    Authorization=Bearer ${token}
    Set Suite Variable    ${HEADERS}    ${headers}

Create Offer
    [Arguments]    ${bandwidth}    ${price}    ${zone}
    ${body}    Create Dictionary
    ...    bandwidth_mbps=${bandwidth}
    ...    price_per_mbps=${price}
    ...    zone=${zone}
    ...    available_from=2026-06-01T00:00:00Z
    ...    available_until=2026-06-30T23:59:59Z
    ${response}    POST    ${BASE_URL}${API_PREFIX}/offers    json=${body}    headers=${HEADERS}
    Status Should Be    201    ${response}
    RETURN    ${response.json()}

Create Request
    [Arguments]    ${bandwidth}    ${budget}    ${zone}
    ${body}    Create Dictionary
    ...    bandwidth_mbps=${bandwidth}
    ...    max_budget=${budget}
    ...    zone=${zone}
    ...    requested_from=2026-06-10T00:00:00Z
    ...    requested_until=2026-06-20T23:59:59Z
    ${response}    POST    ${BASE_URL}${API_PREFIX}/requests    json=${body}    headers=${HEADERS}
    Status Should Be    201    ${response}
    RETURN    ${response.json()}
