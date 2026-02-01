*** Settings ***
Resource    ../resources/Runner.resource
Resource    ../resources/XmlAssertions.resource

*** Test Cases ***
PabotLib Lock Prevents Overlap
    ${r}=    Run Pabot
    ...    --processes    
    ...    2
    ...    --pabotlibport
    ...    0
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_locks.robot

    ${a_start}    ${a_end}=    Get Test Start And End    Critical A
    ${b_start}    ${b_end}=    Get Test Start And End    Critical B
    ${a_crit_start}    ${a_crit_end}=    Get Keyword Start And End In Test By Argument    Critical A    Locked Section    A
    ${b_crit_start}    ${b_crit_end}=    Get Keyword Start And End In Test By Argument   Critical B    Locked Section    B
    
    Should Overlap    ${a_start}    ${a_end}    ${b_start}    ${b_end}
    Should Not Overlap    ${a_crit_start}    ${a_crit_end}    ${b_crit_start}    ${b_crit_end}

PabotLib Lock Prevents Overlap With Pabotlib Running Separately
    # ${process}=    Run Process    python 
    # ...    -c 
    # ...    import sys; print(sys.executable)
    # ...    cwd=${ATEST_DIR}
    # ...    stdout=PIPE
    # ...    stderr=PIPE

    # Log    STDOUT:\n${process.stdout}
    # Log    STDERR:\n${process.stderr}

    ${pabotlib_process}=    Start Pabotlib Server
    ${r}=    Run Pabot
    ...    --processes    
    ...    2
    ...    --no-pabotlib
    ...    --pabotlibhost    
    ...    127.0.0.1
    ...    --pabotlibport
    ...    8270
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_locks.robot

    ${a_start}    ${a_end}=    Get Test Start And End    Critical A
    ${b_start}    ${b_end}=    Get Test Start And End    Critical B
    ${a_crit_start}    ${a_crit_end}=    Get Keyword Start And End In Test By Argument    Critical A    Locked Section    A
    ${b_crit_start}    ${b_crit_end}=    Get Keyword Start And End In Test By Argument   Critical B    Locked Section    B
    
    Should Overlap    ${a_start}    ${a_end}    ${b_start}    ${b_end}
    Should Not Overlap    ${a_crit_start}    ${a_crit_end}    ${b_crit_start}    ${b_crit_end}
    [Teardown]    Terminate Process    ${pabotlib_process}

# PabotLib Lock Prevents Overlap Non Default Host And Port
#     ${pabotlib_process}=    Start Pabotlib Server    host=0.0.0.0    port=8080
#     ${r}=    Run Pabot
#     ...    --processes    
#     ...    2
#     ...    --pabotlibhost    
#     ...    0.0.0.0
#     ...    --pabotlibport
#     ...    8080
#     ...    --testlevelsplit
#     ...    ${DATA_DIR}pabotlib_locks.robot

#     ${a_start}    ${a_end}=    Get Test Start And End    Critical A
#     ${b_start}    ${b_end}=    Get Test Start And End    Critical B
#     ${a_crit_start}    ${a_crit_end}=    Get Keyword Start And End In Test By Argument    Critical A    Locked Section    A
#     ${b_crit_start}    ${b_crit_end}=    Get Keyword Start And End In Test By Argument   Critical B    Locked Section    B
    
#     Should Overlap    ${a_start}    ${a_end}    ${b_start}    ${b_end}
#     Should Not Overlap    ${a_crit_start}    ${a_crit_end}    ${b_crit_start}    ${b_crit_end}
#     [Teardown]    Terminate Process    ${pabotlib_process}

Locks Does Not Work Without PabotLib
    ${r}=    Run Pabot
    ...    --processes    
    ...    2
    ...    --no-pabotlib
    ...    --pabotlibhost    
    ...    127.0.0.1
    ...    --pabotlibport
    ...    8270
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_locks.robot
    ...    expect_return_code=2