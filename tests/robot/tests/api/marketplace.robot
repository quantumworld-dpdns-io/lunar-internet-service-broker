*** Settings ***
Resource    ../../resources/common.resource
Suite Setup    Create Session For API
Suite Teardown    Delete All Sessions

*** Test Cases ***
Create Capacity Offer
    ${offer}    Create Offer    100    0.5    nearside
    Dictionary Should Contain Key    ${offer}    id

Create Relay Request
    ${request}    Create Request    50    100    nearside
    Dictionary Should Contain Key    ${request}    id

List Available Offers
    ${response}    GET    ${BASE_URL}${API_PREFIX}/offers    headers=${HEADERS}
    Status Should Be    200    ${response}
    ${body}    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    offers

List Open Requests
    ${response}    GET    ${BASE_URL}${API_PREFIX}/requests    headers=${HEADERS}
    Status Should Be    200    ${response}

Search Offers By Zone
    ${params}    Create Dictionary    zone=nearside
    ${response}    GET    ${BASE_URL}${API_PREFIX}/offers    params=${params}    headers=${HEADERS}
    Status Should Be    200    ${response}

Filter Requests By Budget
    ${params}    Create Dictionary    max_budget=500
    ${response}    GET    ${BASE_URL}${API_PREFIX}/requests    params=${params}    headers=${HEADERS}
    Status Should Be    200    ${response}
