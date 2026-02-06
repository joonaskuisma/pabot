*** Settings ***
Resource    ../resources/Runner.resource
Resource    ../resources/XmlAssertions.resource
Test Tags    pabotlib    locks

*** Test Cases ***
PabotLib Lock Prevents Overlap
    ${path}=    Normalize Path    ${CURDIR}${/}..${/}results${/}${TEST_NAME}${/}output.xml
    ${r}=    Run Pabot
    ...    --include 
    ...    AORB
    ...    --processes    
    ...    2
    ...    --pabotlibport
    ...    0
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_locks.robot
    
    ${a_start}    ${a_end}=    Get Test Start And End    Critical A    xml=${path}
    ${b_start}    ${b_end}=    Get Test Start And End    Critical B    xml=${path}
    ${a_crit_start}    ${a_crit_end}=    Get Keyword Start And End In Test By Argument    
    ...    Critical A    Locked Section    A    xml=${path}
    ${b_crit_start}    ${b_crit_end}=    Get Keyword Start And End In Test By Argument   
    ...    Critical B    Locked Section    B    xml=${path}
    
    Should Overlap    ${a_start}    ${a_end}    ${b_start}    ${b_end}
    Should Not Overlap    ${a_crit_start}    ${a_crit_end}    ${b_crit_start}    ${b_crit_end}

PabotLib Lock Prevents Overlap With Pabotlib Running Separately
    ${path}=    Normalize Path    ${CURDIR}${/}..${/}results${/}${TEST_NAME}${/}output.xml
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
    ...    --include 
    ...    AORB
    ...    --processes    
    ...    2
    ...    --no-pabotlib
    ...    --pabotlibhost    
    ...    127.0.0.1
    ...    --pabotlibport
    ...    8270
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_locks.robot

    ${a_start}    ${a_end}=    Get Test Start And End    Critical A    xml=${path}
    ${b_start}    ${b_end}=    Get Test Start And End    Critical B    xml=${path}
    ${a_crit_start}    ${a_crit_end}=    Get Keyword Start And End In Test By Argument
    ...    Critical A    Locked Section    A    xml=${path}
    ${b_crit_start}    ${b_crit_end}=    Get Keyword Start And End In Test By Argument
    ...    Critical B    Locked Section    B    xml=${path}
    
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
    ...    --test 
    ...    Critical A
    ...    --test
    ...    Critical B
    ...    ${DATA_DIR}pabotlib_locks.robot
    ...    expect_return_code=2

Multiple Locks Released At Once
    ${path}=    Normalize Path    ${CURDIR}${/}..${/}results${/}${TEST_NAME}${/}output.xml
    ${r}=    Run Pabot
    ...    --processes    
    ...    2
    ...    --testlevelsplit
    ...    --include
    ...    CORD
    ...    ${DATA_DIR}pabotlib_locks.robot
    
    ${c_start}    ${c_end}=    Get Test Start And End    Critical C    xml=${path}
    ${d_start}    ${d_end}=    Get Test Start And End    Critical D    xml=${path}
    ${c_crit_start}    ${c_crit_end}=    Get Keyword Start And End In Test By Argument    
    ...    Critical C     Locked Section    C    xml=${path}
    ${d_crit_start}    ${d_crit_end}=    Get Keyword Start And End In Test By Argument   
    ...    Critical D    Locked Section    D    xml=${path}
    
    Should Overlap    ${c_start}    ${c_end}    ${d_start}    ${d_end}
    Should Not Overlap    ${c_crit_start}    ${c_crit_end}    ${d_crit_start}    ${d_crit_end}

Pabotlib Test Fails Inside Locked Section
    ${path}=    Normalize Path    ${CURDIR}${/}..${/}results${/}${TEST_NAME}${/}output.xml
    ${r}=    Run Pabot
    ...    --test
    ...    Critical A
    ...    --test
    ...    Critical B Fail
    ...    --processes    
    ...    2
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_locks.robot
    ...    expect_return_code=1
    
    ${a_start}    ${a_end}=    Get Test Start And End    Critical A    xml=${path}
    ${b_start}    ${b_end}=    Get Test Start And End    Critical B Fail   xml=${path}
    ${a_crit_start}    ${a_crit_end}=    Get Keyword Start And End In Test By Argument    
    ...    Critical A    Locked Section    A    xml=${path}
    ${b_crit_start}    ${b_crit_end}=    Get Keyword Start And End In Test By Argument   
    ...    Critical B Fail    Locked Section    B Fail    xml=${path}
    
    Should Overlap    ${a_start}    ${a_end}    ${b_start}    ${b_end}
    Should Not Overlap    ${a_crit_start}    ${a_crit_end}    ${b_crit_start}    ${b_crit_end}

Pabotlib Test Fails Inside Locked Section When Next Test Uses Same Lock
    ${path}=    Normalize Path    ${CURDIR}${/}..${/}results${/}${TEST_NAME}${/}output.xml
    ${r}=    Run Pabot
    ...    --test
    ...    Critical A
    ...    --test
    ...    Critical B Fail
    ...    --processes    
    ...    1
    ...    --ordering
    ...    ${DATA_DIR}pabotlib_locks_ordering1.txt
    ...    --testlevelsplit
    ...    ${DATA_DIR}pabotlib_locks.robot
    ...    expect_return_code=1
    
    #${a_start}    ${a_end}=    Get Test Start And End    Critical A    xml=${path}
    #${b_start}    ${b_end}=    Get Test Start And End    Critical B Fail   xml=${path}
    ${a_crit_start}    ${a_crit_end}=    Get Keyword Start And End In Test By Argument    
    ...    Critical A    Locked Section    A    xml=${path}
    ${b_crit_start}    ${b_crit_end}=    Get Keyword Start And End In Test By Argument   
    ...    Critical B Fail    Locked Section    B Fail    xml=${path}
    
    #Should Overlap    ${a_start}    ${a_end}    ${b_start}    ${b_end}
    Should Not Overlap    ${a_crit_start}    ${a_crit_end}    ${b_crit_start}    ${b_crit_end}

Pabotlib Deadlock Happens
    ${r}=    Run Pabot
    ...    --test
    ...    Deadlock 1
    ...    --test
    ...    Deadlock 2
    ...    --processes    
    ...    2
    ...    --testlevelsplit
    ...    --processtimeout
    ...    5
    ...    ${DATA_DIR}pabotlib_locks.robot
    ...    expect_return_code=2
