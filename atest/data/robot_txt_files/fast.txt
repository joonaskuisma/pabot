*** Test Cases ***
Case 1
    Log    START-1
    Log    END-1

Case 2
    Log    START-2
    Log    END-2

Case 3 Fail
    Log    START-3
    Fail    Intentional Failure
    Log    END-3

Case 4 Fail
    Log    START-4    
    Fail    Intentional Failure
    Log    END-4