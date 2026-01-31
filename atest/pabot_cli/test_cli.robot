*** Settings ***
Resource    ../resources/Runner.resource

*** Test Cases ***
Help Works
    ${r}=    Run Pabot    --help    expect_return_code=251
    Should Contain    ${r.stdout}    parallel executor for Robot Framework

Version Works
    ${r}=    Run Pabot    --version    expect_return_code=251
    Should Contain    ${r.stdout}    Version

Pabotconsole Verbose Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --pabotconsole
    ...    verbose
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2
    
    Check That All Pabot Output Files Exist
    # ${item_count}    ${max_worker_id}=    Get Pabot Max Item And Executors From Log    ${PABOT_MANAGER_FILE}
    # Should Be Equal As Integers    ${max_worker_id}    2    Pabot did not use 2 processes as expected.
    # Should Be Equal As Integers    ${item_count}    4    Pabot did not run all expected items.

Pabotconsole Dotted Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --pabotconsole
    ...    dotted
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

Pabotconsole Quiet Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --pabotconsole
    ...    quiet
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2 

Pabotconsole None Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --pabotconsole
    ...    none
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

Verbose Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --verbose
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

Processes All Works
    ${res}=    Run Pabot
    ...    --processes
    ...    all
    ...    --testlevelsplit
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

Processes 2 Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

Command - End Command Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --command
    ...    python my_robot.py
    ...    --end-command
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

    Check That All Pabot Output Files Exist