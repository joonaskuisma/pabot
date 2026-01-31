*** Variables ***
${ATEST_DIR}    atest  # Pabot cwd
${RESULTS_DIR}    results
${ROBOT_RESULTS_DIR}    ${ATEST_DIR}${/}${RESULTS_DIR}
${DATA_DIR}    data${/}
${PABOT_SUITENAMES_FILE}    ${ATEST_DIR}${/}.pabotsuitenames
${PABOT_RESULTS_FOLDER}     ${RESULTS_DIR}${/}pabot_results
${PABOT_MANAGER_FILE}     ${ATEST_DIR}${/}${PABOT_RESULTS_FOLDER}${/}pabot_manager.log
@{DEFAULT_PABOT_OUTPUT_FILES}    output.xml    log.html    report.html
