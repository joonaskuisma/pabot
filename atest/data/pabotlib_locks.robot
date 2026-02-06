*** Settings ***
Library    pabot.PabotLib

*** Test Cases ***
Critical B Fail
    [Tags]    Bfail
    Acquire Lock    AB
    Locked Section    B Fail
    Fail    msg=This fails inside locked section without teardown!
    Release Lock    AB

Critical A
    [Tags]    A
    Acquire Lock    AB
    Locked Section    A
    Release Lock    AB

Critical B
    [Tags]    B
    Acquire Lock    AB
    Locked Section    B
    Release Lock    AB

Critical C
    [Tags]    C
    Sleep    0.5
    Acquire Lock    CD1
    Sleep    0.5
    Acquire Lock    CD2
    Locked Section    C
    Release Locks

Critical D
    [Tags]    D
    Sleep    0.5
    Acquire Lock    CD1
    Sleep    0.5
    Acquire Lock    CD2
    Locked Section    D
    Release Locks

Deadlock 1
    Acquire Lock    DEAD1
    Sleep    1s
    Acquire Lock    DEAD2
    Locked Section    DL1
    Release Locks

Deadlock 2
    Acquire Lock    DEAD2
    Sleep    1s
    Acquire Lock    DEAD1
    Locked Section    DL1
    Release Locks

*** Keywords ***
Locked Section
    [Arguments]    ${section_name}    ${sleep_time}=1s
    Log    ENTER-${section_name}
    Sleep    ${sleep_time}
    Log    EXIT-${section_name}
