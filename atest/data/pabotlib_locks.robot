*** Settings ***
Library    pabot.PabotLib

*** Test Cases ***
Critical A
    Acquire Lock    DB
    Locked Section    A
    Release Lock    DB

Critical B
    Acquire Lock    DB
    Locked Section    B
    Release Lock    DB

*** Keywords ***
Locked Section
    [Arguments]    ${section_name}    ${sleep_time}=1s
    Log    ENTER-${section_name}
    Sleep    ${sleep_time}
    Log    EXIT-${section_name}
