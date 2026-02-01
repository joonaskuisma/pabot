*** Settings ***
Resource    ../resources/Runner.resource
Documentation    Tests for pabot CLI options like --help, --version, --verbose, --processes all etc.
# --verbose
# --testlevelsplit
# --command .. --end-command
# --processes num
# --no-pabotlib
# --pabotlibhost host
# --pabotlibport port
# --processtimeout num
# --shard i/n
# --artifacts extensions
# --artifactsinsubfolders
# --resourcefile file
# --argumentfile[num] file
# --suitesfrom file
# --ordering file [static|dynamic] [skip|run_all]
# --chunk
# --pabotprerunmodifier modifier
# --no-rebot
# --pabotconsole [verbose|dotted|quiet|none]
# --help
# --version

*** Test Cases ***
# --verbose
Verbose Works
    [Tags]    verbose
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --verbose
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

# --testlevelsplit
Testlevelsplit Works
    [Tags]    testlevelsplit
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

Without Testlevelsplit Works
    [Tags]    testlevelsplit
    ${res}=    Run Pabot
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

# --command .. --end-command
Command - End Command Works
    [Tags]    command
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --command
    ...    python my_robot.py
    ...    --end-command
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

    Check That All Pabot Output Files Exist

# --processes num
Processes All Works
    [Tags]    processes
    ${res}=    Run Pabot
    ...    --processes
    ...    all
    ...    --testlevelsplit
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

Processes 2 Works
    [Tags]    processes
    ${res}=    Run Pabot
    ...    --processes
    ...    2
    ...    --testlevelsplit
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

Processes 1 Works
    [Tags]    processes
    ${res}=    Run Pabot
    ...    --processes
    ...    1
    ...    --testlevelsplit
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

# --no-pabotlib            # Covered in test_pabotlib.robot
# --pabotlibhost host      # Covered in test_pabotlib.robot
# --pabotlibport port      # Covered in test_pabotlib.robot

# --processtimeout num
Processtimeout Works
    [Tags]    processtimeout
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --processtimeout
    ...    3
    ...    ${DATA_DIR}slow.robot
    ...    expect_return_code=2

    Check That All Pabot Output Files Exist

Processtimeout Short Works
    [Tags]    processtimeout
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --processtimeout
    ...    1    # 0s seems to be treated as no timeout
    ...    ${DATA_DIR}slow.robot
    ...    expect_return_code=4

    Check That All Pabot Output Files Exist

Processtimeout Long Works
    [Tags]    processtimeout
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --processtimeout
    ...    10
    ...    ${DATA_DIR}slow.robot
    ...    expect_return_code=0

    Check That All Pabot Output Files Exist

# --shard i/n
Shard Works N/2
    [Tags]    shard
    ${res1}=    Run Pabot
    ...    --testlevelsplit
    ...    --shard
    ...    1/2
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=${EMPTY}

    Check That All Pabot Output Files Exist

    ${res2}=    Run Pabot
    ...    --testlevelsplit
    ...    --shard
    ...    2/2
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=${EMPTY}

    Check That All Pabot Output Files Exist

    ${total_rc}=    Evaluate    ${res1.rc} + ${res2.rc}
    Should Be Equal As Integers    ${total_rc}    2    msg=Pabot did not run all tests in shards as expected.

Shard Works N/3
    [Tags]    shard
    ${res1}=    Run Pabot
    ...    --testlevelsplit
    ...    --shard
    ...    1/3
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=${EMPTY}

    Check That All Pabot Output Files Exist

    ${res2}=    Run Pabot
    ...    --testlevelsplit
    ...    --shard
    ...    2/3
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=${EMPTY}

    Check That All Pabot Output Files Exist

    ${res3}=    Run Pabot
    ...    --testlevelsplit
    ...    --shard
    ...    3/3
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=${EMPTY}

    Check That All Pabot Output Files Exist

    ${total_rc}=    Evaluate    ${res1.rc} + ${res2.rc} + ${res3.rc}
    Should Be Equal As Integers    ${total_rc}    2    msg=Pabot did not run all tests in shards as expected.

# --artifacts extensions
# --artifactsinsubfolders
# --resourcefile file

# --argumentfile[num] file
Argumentfile Works
    [Tags]    argumentfile
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --argumentfile1
    ...    ${DATA_DIR}argumentfile1.txt
    ...    --argumentfile2
    ...    ${DATA_DIR}argumentfile2.txt
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=4

    Check That All Pabot Output Files Exist

# --suitesfrom file
Suitesfrom Works
    [Tags]    suitesfrom
    # TODO NEEDS FIXING: Does not shorting if previous run is with --testlevelsplit
    ${res}=    Run Pabot
    # ...    --testlevelsplit
    ...    ${DATA_DIR}parallel_fail${/}
    ...    expect_return_code=1

    ${res}=    Run Pabot
    ...    --processes
    ...    1
    ...    --suitesfrom
    ...    ${RESULTS_DIR}${/}output.xml
    ...    ${DATA_DIR}parallel_fail${/}
    ...    expect_return_code=1

    Check That All Pabot Output Files Exist

# --ordering file [static|dynamic] [skip|run_all]        # Covered in test_ordering.robot

# --chunk
Chunk Works
    [Tags]    chunk
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --processes
    ...    2
    ...    --chunk
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

    Check That All Pabot Output Files Exist

# --pabotprerunmodifier modifier
Pabotprerunmodifier Works
    [Tags]    pabotprerunmodifier
    # TODO: Exit code???
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --pabotprerunmodifier
    ...    ModifierThatDoesNothing
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

# --no-rebot
No Rebot Works
    [Tags]    norebot
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --no-rebot
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=253

    ${no_rebot_output}    Create List    ${DEFAULT_PABOT_OUTPUT_FILES}

# --pabotconsole [verbose|dotted|quiet|none]
Pabotconsole Verbose Works
    [Tags]    pabotconsole
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --pabotconsole
    ...    verbose
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2
    
    Check That All Pabot Output Files Exist
    # ${item_count}    ${max_worker_id}=    Get Pabot Max Item And Executors From Log    ${PABOT_MANAGER_FILE}
    # Should Be Equal As Integers    ${max_worker_id}    2    Pabot did not use 2 processes as expected.
    # Should Be Equal As Integers    ${item_count}    4    Pabot did not run all expected items.

Pabotconsole Dotted Works
    [Tags]    pabotconsole
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --pabotconsole
    ...    dotted
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

Pabotconsole Quiet Works
    [Tags]    pabotconsole
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --pabotconsole
    ...    quiet
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2 

Pabotconsole None Works
    [Tags]    pabotconsole
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --pabotconsole
    ...    none
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

# --help
Version Works
    [Tags]    version
    ${r}=    Run Pabot    --version    expect_return_code=251
    Should Contain    ${r.stdout}    Version

# --version
Help Works
    [Tags]    help
    ${r}=    Run Pabot    --help    expect_return_code=251
    Should Contain    ${r.stdout}    parallel executor for Robot Framework
