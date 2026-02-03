*** Settings ***
Library    OperatingSystem
Resource    ../resources/Runner.resource
Suite Setup    Clean Results Directory
# Test Setup    Clean Up Results
# Test Teardown    Remove Directory If Exists    atest/results
