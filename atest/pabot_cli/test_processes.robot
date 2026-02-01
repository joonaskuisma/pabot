*** Settings ***
Resource    ../resources/Runner.resource

*** Test Cases ***
Pabot Respects Process Count
    ${res}=    Run Pabot
    ...    --processes
    ...    2
    ...    --testlevelsplit
    ...    ${DATA_DIR}parallel.robot
    
    Check That All Pabot Output Files Exist
    ${item_count}    ${max_worker_id}=    Get Pabot Max Item And Executors From Log    ${PABOT_MANAGER_FILE}
    Should Be Equal As Integers    ${max_worker_id}    2    Pabot did not use 2 processes as expected.
    Should Be Equal As Integers    ${item_count}    2    Pabot did not run all expected items.

Pabot Respects Process Count With Multiple Suites
    ${res}=    Run Pabot
    ...    --processes
    ...    4
    ...    --testlevelsplit
    ...    ${DATA_DIR}parallel_pass
    
    Check That All Pabot Output Files Exist
    ${item_count}    ${max_worker_id}=    Get Pabot Max Item And Executors From Log    ${PABOT_MANAGER_FILE}
    Should Be Equal As Integers    ${max_worker_id}    4    Pabot did not use 4 processes as expected.
    Should Be Equal As Integers    ${item_count}    9    Pabot did not run all expected items.

Pabot Respects Process Count With Multiple Suites With Different DataSources
    ${res}=    Run Pabot
    ...    --processes
    ...    4
    ...    --testlevelsplit
    ...    ${DATA_DIR}parallel_pass${/}suite_A.robot
    ...    ${DATA_DIR}parallel_pass${/}suite_B.robot
    ...    ${DATA_DIR}parallel_pass${/}suite_C.robot
    
    Check That All Pabot Output Files Exist
    ${item_count}    ${max_worker_id}=    Get Pabot Max Item And Executors From Log    ${PABOT_MANAGER_FILE}
    Should Be Equal As Integers    ${max_worker_id}    4    Pabot did not use 4 processes as expected.
    Should Be Equal As Integers    ${item_count}    9    Pabot did not run all expected items.