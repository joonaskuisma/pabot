*** Settings ***
Test Tags    B

*** Test Cases ***
Case 1
    [Tags]    B1
    Log    START-1
    Sleep    500ms
    Log    END-1

Case 2
    [Tags]    B2
    Log    START-2
    Sleep    500ms
    Log    END-2

Case 3
    [Tags]    B3
    Log    START-3
    Sleep    500ms
    Log    END-3