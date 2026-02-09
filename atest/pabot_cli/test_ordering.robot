*** Settings ***
Resource    ../resources/Runner.resource
Test Tags    pabot    ordering

*** Test Cases ***
Ordering Static Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --ordering
    ...    ${DATA_DIR}ordering.txt
    ...    static
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

    Check That All Pabot Output Files Exist

Ordering Static Dynamic Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --ordering
    ...    ${DATA_DIR}ordering.txt
    ...    dynamic
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

    Check That All Pabot Output Files Exist

Ordering Static Dynamic Skip Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --ordering
    ...    ${DATA_DIR}ordering.txt
    ...    dynamic
    ...    skip
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=1    # Note skip = pass as exit code

    Check That All Pabot Output Files Exist