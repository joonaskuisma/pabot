*** Settings ***
Test Tags    A

*** Test Cases ***
Case 1
    [Tags]    A1
    Log    START-1
    Sleep    500ms
    Log    END-1

Case 2
    [Tags]    A2
    Log    START-2
    Sleep    500ms
    Log    END-2

Case 3
    [Tags]    A3
    Log    START-3
    Sleep    500ms
    Log    END-3