*** Test Cases ***
Case 1
    Log    START-1
    Sleep    1s
    Log    END-1

Case 2
    Log    START-2
    Sleep    1s
    Log    END-2

Case 3 Fail
    Log    START-3
    Sleep    5s
    Log    END-3

Case 4 Fail
    Log    START-4    
    Sleep    5s
    Log    END-4