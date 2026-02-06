*** Settings ***
Library    pabot.PabotLib

*** Test Cases ***
Transfer 1
    Sleep    1s
    Set Parallel Value For Key    key=shared    value=${True}    # 1s
    Sleep    2s
    ${value}=    Get Parallel Value For Key    key=shared        # 3s
    Should Be Equal    ${value}    True

Transfer 2
    ${value}=    Get Parallel Value For Key    key=shared        # 0s
    Should Be Equal    ${value}    ${EMPTY}
    Sleep    2s
    ${value}=    Get Parallel Value For Key    key=shared        # 2s
    Set Parallel Value For Key    key=shared    value=True       # 2s
    Should Be Equal    ${value}    ${True}

Transfer A
    FOR    ${i}    IN RANGE    101
        Set Parallel Value For Key    key=shared    value=a${i}
    END

Transfer B
    FOR    ${i}    IN RANGE    101
        Set Parallel Value For Key    key=shared    value=b${i}
    END

Transfer C
    FOR    ${i}    IN RANGE    250
        ${value}=    Get Parallel Value For Key    key=shared
    END
    ${list}    Create List    b100    a100
    Should Contain Any    ${list}    ${value}
    
    