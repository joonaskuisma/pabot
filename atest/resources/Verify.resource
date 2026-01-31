*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections

*** Keywords ***
Get Pabot Max Item And Executors From Log 
    [Arguments]    ${logfile}
    ${content}=    Get File    ${logfile}
    ${max_id}=    Get Max Pabot ID    ${content}    pattern=ID:
    ${max_executors}=    Get Max Pabot ID    ${content}
    RETURN    ${max_id}    ${max_executors}

Get Max Pabot ID
    [Arguments]    ${text}    ${pattern}=${EMPTY}
    ${matches}=    Get Regexp Matches
    ...    ${text}
    ...    \\[${pattern}(\\d+)\\]
    ...    1

    # matches = list of lists, each inner list has one item (the captured group)
    ${ids}=    Create List
    FOR    ${id}    IN    @{matches}
        ${id_int}=    Convert To Integer    ${id}
        Append To List    ${ids}    ${id_int}
    END

    ${max_id}=    Evaluate    max(${ids})+1    # because IDs are zero-based
    RETURN    ${max_id}