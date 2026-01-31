*** Settings ***
Library    Process
Library    OperatingSystem
Resource    ../resources/Variables.resource
Resource    ../resources/Verify.resource

*** Keywords ***
Run Pabot
    [Arguments]    @{args}    ${expect_return_code}=0
    ${result}=    Run Process
    ...    pabot
    ...    --outputdir
    ...    ${RESULTS_DIR}
    ...    @{args}
    ...    stdout=PIPE
    ...    stderr=PIPE
    ...    timeout=60s
    ...    cwd=${ATEST_DIR}

    Log    STDOUT:\n${result.stdout}
    Log    STDERR:\n${result.stderr}

    Should Be Equal As Integers    ${result.rc}    ${expect_return_code}    Pabot exited with unexpected return code.
    # Should Be Empty    ${result.stderr}    Pabot produced unexpected output to stderr.
    RETURN    ${result}

Check Pabot Output Xml Contains
    [Arguments]    ${filepath}    ${text}
    ${content}=    Get File    ${filepath}
    Should Contain    ${content}    ${text}



Check That All Pabot Output Files Exist
    [Arguments]    ${files}=@{DEFAULT_PABOT_OUTPUT_FILES}
    FOR    ${file}    IN    @{files}
        File Should Exist    ${ROBOT_RESULTS_DIR}${/}${file}
    END
    File Should Exist    ${PABOT_SUITENAMES_FILE}
    File Should Exist    ${PABOT_MANAGER_FILE}




Remove Directory If Exists
    [Arguments]    ${path}
    ${exists}=    Run Keyword And Return Status    Directory Should Exist    ${path}
    IF    ${exists}
        Remove Directory    ${path}    recursive=True
    END

Remove Pabot Suite Names File If Exists
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${PABOT_SUITENAMES_FILE}
    IF    ${exists}
        Remove File    ${PABOT_SUITENAMES_FILE}
    END

Clean Up Results
    Remove Directory If Exists    ${RESULTS_DIR}
    Remove Pabot Suite Names File If Exists