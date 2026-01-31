*** Settings ***
Resource    ../resources/Runner.resource
Resource    ../resources/XmlAssertions.resource

*** Test Cases ***
PabotLib Lock Prevents Overlap
    ${r}=    Run Pabot
    ...    --processes
    ...    2
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_locks.robot

    ${a_start}    ${a_end}=    Get Test Start And End    Critical A
    ${b_start}    ${b_end}=    Get Test Start And End    Critical B
    ${a_crit_start}    ${a_crit_end}=    Get Keyword Start And End In Test By Argument    Critical A    Locked Section    A
    ${b_crit_start}    ${b_crit_end}=    Get Keyword Start And End In Test By Argument   Critical B    Locked Section    B
    
    Should Overlap    ${a_start}    ${a_end}    ${b_start}    ${b_end}
    Should Not Overlap    ${a_crit_start}    ${a_crit_end}    ${b_crit_start}    ${b_crit_end}

Locks Does Not Work Without PabotLib
    ${r}=    Run Pabot
    ...    --no-pabotlib
    ...    --processes
    ...    2
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_locks.robot
    ...    expect_return_code=2