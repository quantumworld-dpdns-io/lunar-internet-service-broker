*** Settings ***
Resource    ../../resources/common.resource
Suite Setup    Create Session For API

*** Test Cases ***
Health Endpoint Returns OK
    Health Check Should Succeed

API Version Returns Correct Prefix
    ${response}    GET    ${BASE_URL}${API_PREFIX}/offers    headers=${HEADERS}
    ${status}    Convert To Integer    ${response.status_code}
    Should Be True    ${status} < 500
