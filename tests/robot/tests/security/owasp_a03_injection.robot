*** Settings ***
Resource    ../../resources/common.resource
Suite Setup    Create Session For API

*** Test Cases ***
A03-001 SQL Injection Prevention - Login
    ${body}    Create Dictionary
    ...    email=' OR 1=1 --
    ...    password=' OR '1'='1
    ${response}    POST    ${BASE_URL}${API_PREFIX}/auth/login    json=${body}
    Status Should Be    401    ${response}

A03-002 NoSQL Injection Prevention
    ${body}    Create Dictionary
    ...    email={"$ne": ""}
    ...    password={"$ne": ""}
    ${response}    POST    ${BASE_URL}${API_PREFIX}/auth/login    json=${body}
    Status Should Be    400    ${response}

A03-003 XSS Prevention - Input Validation
    ${body}    Create Dictionary
    ...    display_name=<script>alert('xss')</script>
    ...    email=xss@test.com
    ...    password=Test123!
    ${response}    POST    ${BASE_URL}${API_PREFIX}/auth/register    json=${body}
    Should Be True    ${response.status_code} in [400, 201]
    Run Keyword If    ${response.status_code} == 201
    ...    XSS Payload Should Be Sanitized    ${response.json()}

A03-004 OS Command Injection Prevention
    ${body}    Create Dictionary
    ...    name=rover; rm -rf /
    ...    bandwidth_mbps=100
    ${response}    POST    ${BASE_URL}${API_PREFIX}/rovers    json=${body}
    ...    headers=${HEADERS}
    Status Should Be    400    ${response}

*** Keywords ***
XSS Payload Should Be Sanitized
    [Arguments]    ${response_body}
    ${name}    Get From Dictionary    ${response_body}    display_name
    Should Not Contain    ${name}    <script>
