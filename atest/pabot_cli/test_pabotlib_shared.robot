*** Settings ***
Resource    ../resources/Runner.resource
Resource    ../resources/XmlAssertions.resource
Test Tags    pabotlib    shared

*** Test Cases ***
PabotLib Lock Prevents Overlap
    ${path}=    Normalize Path    ${CURDIR}${/}..${/}results${/}${TEST_NAME}${/}output.xml
    ${r}=    Run Pabot
    ...    --test 
    ...    Transfer 1
    ...    --test 
    ...    Transfer 2
    ...    --processes    
    ...    2
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_transfer.robot
    ...    expect_return_code=0
