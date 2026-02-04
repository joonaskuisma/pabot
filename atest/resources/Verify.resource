*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections
Library    XML
Library    SeleniumLibrary
Resource    ../resources/Variables.resource

*** Keywords ***
Get Pabot Max Item And Executors From Log 
    [Arguments]    ${logfile}=${ROBOT_RESULTS_DIR}${/}${TEST_NAME}${/}pabot_results${/}pabot_manager.log
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

# Check XPath Text From HTML File
#     [Arguments]    ${file}    ${xpath}    ${expected_text}
#     ${xml}=    Parse Xml    source=${ROBOT_RESULTS_DIR}${/}${TEST_NAME}${/}${file}
#     ${elem}=    Get Element    source=${xml}    xpath=${xpath}
#     ${text}=    Get Element Text    source=${elem}
#     Should Contain    container=${text}    item=${expected_text}

Check XPath Text From HTML File
    [Arguments]    ${file}    ${xpath}    ${expected_text}
    ${path}=    Normalize Path    ${CURDIR}${/}..${/}results${/}${TEST_NAME}${/}${file}
    Open Browser    ${path}    browser=headlesschrome
    SeleniumLibrary.Element Text Should Be    locator=${xpath}    expected=${expected_text}
    Close Browser
