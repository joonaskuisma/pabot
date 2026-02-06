*** Settings ***
Resource    ../resources/Runner.resource
Resource    ../resources/XmlAssertions.resource
Test Tags    pabotlib    execution

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
