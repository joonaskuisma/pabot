*** Settings ***
Library    Process
Library    OperatingSystem
Resource    ../resources/Variables.resource
Resource    ../resources/Verify.resource

*** Keywords ***
Run Pabot
    [Arguments]    @{args}    ${expect_return_code}=0
    ${stdout_file}    Set Variable    ${RESULTS_DIR}/${TEST_NAME}/stdout.txt
    ${stderr_file}    Set Variable    ${RESULTS_DIR}/${TEST_NAME}/stderr.txt
    Create Directory    path=${ATEST_DIR}${/}${RESULTS_DIR}/${TEST_NAME}
    Create File    ${ATEST_DIR}${/}${stdout_file}
    Create File    ${ATEST_DIR}${/}${stderr_file}
    ${result}=    Run Process
    ...    pabot
    ...    --outputdir
    ...    ${RESULTS_DIR}${/}${TEST_NAME}
    ...    @{args}
    # ...    stdin=NONE
    # ...    stdout=NONE
    # # ...    stderr=NONE
    ...    stdout=${stdout_file}
    ...    stderr=${stderr_file}
    ...    timeout=10s
    ...    cwd=${ATEST_DIR}

    Log    STDOUT:\n${result.stdout}
    Log    STDERR:\n${result.stderr}
    
    IF    "${expect_return_code}" != "${EMPTY}"
        Should Be Equal As Integers    ${result.rc}    ${expect_return_code}    Pabot exited with unexpected return code.
    END
    Should Be Empty    ${result.stderr}    Pabot produced unexpected output to stderr.
    RETURN    ${result}

Start Pabotlib Server
    [Arguments]    ${host}=127.0.0.1    ${port}=8270    ${resource_file}=resource.txt
    # ${process}=    Run Process    C:\\Users\\kuism\\VSC_Projects\\Github\\pabot\\venv_312_pabot_editable\\Scripts\\python.exe
    # ...    -c 
    # ...    import sys; print(sys.executable)
    # ...    cwd=${ATEST_DIR}
    # ...    stdout=PIPE
    # ...    stderr=PIPE

    # Log    STDOUT:\n${process.stdout}
    # Log    STDERR:\n${process.stderr}

    ${process}=    Start Process
    # TODO: muuta polku dynaamiseksi
    ...    ${CURDIR}\\..\\..\\venv_312_pabot_editable\\Scripts\\python.exe
    ...    -m 
    ...    pabot.pabotlib
    ...    ${resource_file}
    ...    ${host}
    ...    ${port}    
    ...    cwd=${ATEST_DIR}
    # ...    stdout=PIPE
    # ...    stderr=PIPE
    # Wait For Process    ${process}    timeout=2s    on_timeout=continue
    # Log    STDOUT:\n${process.stdout}
    # Log    STDERR:\n${process.stderr}

Check Pabot Output Xml Contains
    [Arguments]    ${filepath}    ${text}
    ${content}=    Get File    ${filepath}
    Should Contain    ${content}    ${text}



Check That All Pabot Output Files Exist
    [Arguments]    ${files}=@{DEFAULT_PABOT_OUTPUT_FILES}
    FOR    ${file}    IN    @{files}
        File Should Exist    ${ROBOT_RESULTS_DIR}${/}${TEST_NAME}${/}${file}
    END
    File Should Exist    ${PABOT_SUITENAMES_FILE}
    File Should Exist    ${ROBOT_RESULTS_DIR}${/}${TEST_NAME}${/}pabot_results${/}pabot_manager.log




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

Clean Results Directory
    Remove Directory If Exists    path=${ROBOT_RESULTS_DIR}
    Directory Should Not Exist    path=${ROBOT_RESULTS_DIR}
