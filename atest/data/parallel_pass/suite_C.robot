*** Settings ***
Test Tags    C

*** Test Cases ***
Case 1
    [Tags]    C1
    Log    START-1
    Sleep    500ms
    Log    END-1

Case 2
    [Tags]    C2
    Log    START-2
    Sleep    500ms
    Log    END-2

Case 3
    [Tags]    C3
    Log    START-3
    Sleep    500ms
    Log    END-3