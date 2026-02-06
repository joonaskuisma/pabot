*** Settings ***
Resource    ../resources/Runner.resource
Resource    ../resources/XmlAssertions.resource
Test Tags    pabotlib    transfer

*** Test Cases ***
PabotLib Value Transfer Between Processes Works
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
    
PabotLib Value Transfer Continuously
    ${r}=    Run Pabot
    ...    --test 
    ...    Transfer A
    ...    --test 
    ...    Transfer B
    ...    --test 
    ...    Transfer C
    ...    --processes    
    ...    3
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_transfer.robot
    ...    expect_return_code=0