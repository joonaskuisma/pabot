*** Settings ***
Library    OperatingSystem
Resource    ../resources/Runner.resource
Test Setup    Clean Up Results
# Test Teardown    Remove Directory If Exists    atest/results
