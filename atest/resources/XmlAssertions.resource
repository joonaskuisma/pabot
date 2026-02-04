*** Settings ***
Library    OperatingSystem
Library    XML
Library    DateTime
Library    Collections
Resource    ../resources/Variables.resource

*** Keywords ***
Get Test Start And End
    [Arguments]    ${testname}    ${xml}
    ${root}=    Parse XML    ${xml}

    ${status_elem}=    Get Element
    ...    ${root}
    ...    xpath=.//test[@name="${testname}"]/status

    ${start}=    XML.Get Element Attribute
    ...    ${status_elem}
    ...    start

    ${elapsed}=    XML.Get Element Attribute
    ...    ${status_elem}
    ...    elapsed

    ${end}=    Add Time To Date
    ...    ${start}
    ...    ${elapsed}
    ...    result_format=%Y-%m-%dT%H:%M:%S.%f

    RETURN    ${start}    ${end}

Get Keyword Start And End In Test By Argument
    [Arguments]    ${testname}    ${kwname}    ${argvalue}    ${xml}
    ${root}=    Parse XML    ${xml}

    ${kws}=    Get Elements
    ...    ${root}
    ...    xpath=.//test[@name="${testname}"]//kw[@name="${kwname}"]

    FOR    ${kw}    IN    @{kws}
        ${args}=    Get Elements    ${kw}    arg
        FOR    ${arg}    IN    @{args}
            ${text}=    Get Element Text    ${arg}
            IF    '${text}' == '${argvalue}'
                ${status_elem}=    Get Element    ${kw}    status
                ${start}=    XML.Get Element Attribute    ${status_elem}    start
                ${elapsed}=    XML.Get Element Attribute    ${status_elem}    elapsed
                ${end}=    Add Time To Date
                ...    ${start}
                ...    ${elapsed}
                ...    result_format=%Y-%m-%dT%H:%M:%S.%f
                RETURN    ${start}    ${end}
            END
        END
    END
    Fail    Keyword '${kwname}' with argument '${argvalue}' not found in test '${testname}'

Should Not Overlap
    [Arguments]    ${a_start}    ${a_end}    ${b_start}    ${b_end}
    ${c1}=    Run Keyword And Return Status
    ...    Should Be True    '${a_end}' <= '${b_start}'
    ${c2}=    Run Keyword And Return Status
    ...    Should Be True    '${b_end}' <= '${a_start}'
    Should Be True    ${c1} or ${c2}

Should Overlap
    [Arguments]    ${a_start}    ${a_end}    ${b_start}    ${b_end}
    ${c1}=    Run Keyword And Return Status
    ...    Should Be True    '${a_start}' < '${b_end}'
    ${c2}=    Run Keyword And Return Status
    ...    Should Be True    '${b_start}' < '${a_end}'
    Should Be True    ${c1} and ${c2}