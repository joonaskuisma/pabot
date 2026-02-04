*** Settings ***
Resource    ../resources/Runner.resource
Test Tags    robot
Documentation    These parameters are from Robot Framework Version:  7.3.2 

*** Test Cases ***
#     --rpa                 Turn on the generic automation mode. Mainly affects
#                           terminology so that "test" is replaced with "task"
#                           in logs and reports. By default the mode is got
#                           from test/task header in data files.
Rpa Works  
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --rpa
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2
    Check XPath Text From HTML File    log.html    
    ...    xpath=//div[@id='statistics-container']//h2    
    ...    expected_text=Task Statistics
    Check XPath Text From HTML File    report.html    
    ...    xpath=//div[@id='statistics-container']//h2    
    ...    expected_text=Task Statistics

#     --language lang *     Activate localization. `lang` can be a name or a code
#                           of a built-in language, or a path or a module name of
#                           a custom language file.
Language Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --language
    ...    Finnish
    ...    ${DATA_DIR}nopea.txt
    ...    expect_return_code=2

#  -F --extension value     Parse only files with this extension when executing
#                           a directory. Has no effect when running individual
#                           files or when using resource files. If more than one
#                           extension is needed, separate them with a colon.
#                           Examples: `--extension txt`, `--extension robot:txt`
#                           Only `*.robot` files are parsed by default.
Extension Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --extension
    ...    txt
    ...    ${DATA_DIR}${/}robot_txt_files
    ...    expect_return_code=2

#  -I --parseinclude pattern *  Parse only files matching `pattern`. It can be:
#                           - a file name or pattern like `example.robot` or
#                             `*.robot` to parse all files matching that name,
#                           - a file path like `path/to/example.robot`, or
#                           - a directory path like `path/to/example` to parse
#                             all files in that directory, recursively.
Parseinclude Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --parseinclude
    ...    fast.robot
    ...    ${DATA_DIR}
    ...    expect_return_code=2

#  -N --name name           Set the name of the top level suite. By default the
#                           name is created based on the executed file or
#                           directory.
Name Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --name
    ...    MyCustomSuiteName
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2
    Check XPath Text From HTML File    log.html    
    ...    xpath=//*[@id="s1"]/div[1]/div[1]/span[3]  
    ...    expected_text=MyCustomSuiteName

#  -D --doc documentation   Set the documentation of the top level suite.
#                           Simple formatting is supported (e.g. *bold*). If the
#                           documentation contains spaces, it must be quoted.
#                           If the value is path to an existing file, actual
#                           documentation is read from that file.
#                           Examples: --doc "Very *good* example"
#                                     --doc doc_from_file.txt
Doc Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --doc
    ...    "Very good example"
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2
    Check XPath Text From HTML File    log.html    
    ...    xpath=//*[@id="s1"]/div[2]/table/tbody/tr[th[normalize-space(.)='Documentation:']]/td/p 
    ...    expected_text="Very good example"

#  -M --metadata name:value *  Set metadata of the top level suite. Value can
#                           contain formatting and be read from a file similarly
#                           as --doc. Example: --metadata Version:1.2
Metadata Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --metadata
    ...    Version:1.2
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2
    Check XPath Text From HTML File    log.html    
    ...    xpath=//*[@id="s1"]/div[2]/table/tbody/tr[th[normalize-space(.)='Version:']]/td/p
    ...    expected_text=1.2

#  -G --settag tag *        Sets given tag(s) to all executed tests.
Settag Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --settag
    ...    SetTag
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -t --test name *         Select tests by name or by long name containing also
#                           parent suite name like `Parent.Test`. Name is case
#                           and space insensitive and it can also be a simple
#                           pattern where `*` matches anything, `?` matches any
#                           single character, and `[chars]` matches one character
#                           in brackets.
Test Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --test
    ...    Case 2
    ...    -t
    ...    Case 3 Fail
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=1

#     --task name *         Alias to --test. Especially applicable with --rpa.
Task Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --rpa
    ...    --task
    ...    Case 2
    ...    --task
    ...    Case 3 Fail
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=1

#  -s --suite name *        Select suites by name. When this option is used with
#                           --test, --include or --exclude, only tests in
#                           matching suites and also matching other filtering
#                           criteria are selected. Name can be a simple pattern
#                           similarly as with --test and it can contain parent
#                           name separated with a dot. For example, `-s X.Y`
#                           selects suite `Y` only if its parent is `X`.
Suite Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --suite
    ...    Fast
    ...    ${DATA_DIR}
    ...    expect_return_code=2

#  -i --include tag *       Select tests by tag. Similarly as name with --test,
#                           tag is case and space insensitive and it is possible
#                           to use patterns with `*`, `?` and `[]` as wildcards.
#                           Tags and patterns can also be combined together with
#                           `AND`, `OR`, and `NOT` operators.
#                           Examples: --include foo --include bar*
#                                     --include fooANDbar*
Include Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --include
    ...    tc2ORtc3
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=1

#  -e --exclude tag *       Select test cases not to run by tag. These tests are
#                           not run even if included with --include. Tags are
#                           matched using same rules as with --include.
Exclude Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --exclude
    ...    tc1ORtc4
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=1

#  -R --rerunfailed output  Select failed tests from an earlier output file to be
#                           re-executed. Equivalent to selecting same tests
#                           individually using --test.
Rerunfailed Works
    ${res1}=    Run Pabot
    ...    --include
    ...    tc3
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=1
    ${res2}=    Run Pabot
    ...    --testlevelsplit
    ...    --rerunfailed
    ...    ${RESULTS_DIR}${/}${TEST_NAME}${/}output.xml
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=1

#  -S --rerunfailedsuites output  Select failed suites from an earlier output
#                           file to be re-executed.
Rerunfailedsuites Works
    ${res1}=    Run Pabot
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2
    ${res2}=    Run Pabot
    ...    --testlevelsplit
    ...    --rerunfailedsuites
    ...    ${RESULTS_DIR}${/}${TEST_NAME}${/}output.xml
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --runemptysuite       Executes suite even if it contains no tests. Useful
#                           e.g. with --include/--exclude when it is not an error
#                           that no test matches the condition.
Runemptysuite Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --include
    ...    no_match
    ...    --runemptysuite
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=0

#     --skip tag *          Tests having given tag will be skipped. Tag can be
#                           a pattern.
Skip Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --skip
    ...    tc3ORtc4
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=0

#     --skiponfailure tag *  Tests having given tag will be skipped if they fail.
#                           Tag can be a pattern
Skiponfailure Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --skiponfailure
    ...    tc3
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=1

#  -v --variable name:value *  Set variables in the test data. Only scalar
#                           variables with string value are supported and name is
#                           given without `${}`. See --variablefile for a more
#                           powerful variable setting mechanism.
#                           Examples:
#                           --variable name:Robot  =>  ${name} = `Robot`
#                           -v "hello:Hello world" =>  ${hello} = `Hello world`
#                           -v x: -v y:42          =>  ${x} = ``, ${y} = `42`
Variable Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --variable
    ...    test_variable:initialized
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -V --variablefile path *  Python or YAML file file to read variables from.
#                           Possible arguments to the variable file can be given
#                           after the path using colon or semicolon as separator.
#                           Examples: --variablefile path/vars.yaml
#                                     --variablefile environment.py:testing
Variablefile Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --variablefile
    ...    ${DATA_DIR}variablefile.py
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -d --outputdir dir       Where to create output files. The default is the
#                           directory where tests are run from and the given path
#                           is considered relative to that unless it is absolute.

# This is tested with Run Pabot already
# Outputdir Works
#     ${res}=    Run Pabot
#     ...    --testlevelsplit
#     ...    --outputdir
#     ...    ${ROBOT_RESULTS_DIR}${/}new_outdir${/}
#     ...    ${DATA_DIR}fast.robot
#     ...    expect_return_code=2

#  -o --output file         XML output file. Given path, similarly as paths given
#                           to --log, --report, --xunit, and --debugfile, is
#                           relative to --outputdir unless given as an absolute
#                           path. Other output files are created based on XML
#                           output files after the test execution and XML outputs
#                           can also be further processed with Rebot tool. Can be
#                           disabled by giving a special value `NONE`.
#                           Default: output.xml
Output Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --output
    ...    NONE
    ...    --no-rebot
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=253

#     --legacyoutput        Create XML output file in format compatible with
#                           Robot Framework 6.x and earlier.
Legacyoutput Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --legacyoutput
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -l --log file            HTML log file. Can be disabled by giving a special
#                           value `NONE`. Default: log.html
#                           Examples: `--log mylog.html`, `-l NONE`
Log Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --log
    ...    NONE
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -r --report file         HTML report file. Can be disabled with `NONE`
#                           similarly as --log. Default: report.html
Report Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --report
    ...    NONE
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -x --xunit file          xUnit compatible result file. Not created unless this
#                           option is specified.
Xunit Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --xunit
    ...    xunit.xml
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -b --debugfile file      Debug file written during execution. Not created
#                           unless this option is specified.
Debugfile Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --debugfile
    ...    debugfile.log
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -T --timestampoutputs    When this option is used, timestamp in a format
#                           `YYYYMMDD-hhmmss` is added to all generated output
#                           files between their basename and extension. For
#                           example `-T -o output.xml -r report.html -l none`
#                           creates files like `output-20070503-154410.xml` and
#                           `report-20070503-154410.html`.
Timestampoutputs Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --timestampoutputs
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --splitlog            Split the log file into smaller pieces that open in
#                           browsers transparently.
Splitlog Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --splitlog
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --logtitle title      Title for the generated log file. The default title
#                           is `<SuiteName> Log`.
Logtitle Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --logtitle
    ...    My Custom Log Title
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --reporttitle title   Title for the generated report file. The default
#                           title is `<SuiteName> Report`.
Reporttitle Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --reporttitle
    ...    My Custom Report Title
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --reportbackground colors  Background colors to use in the report file.
#                           Given in format `passed:failed:skipped` where the
#                           `:skipped` part can be omitted. Both color names and
#                           codes work.
#                           Examples: --reportbackground green:red:yellow
#                                     --reportbackground #00E:#E00
Reportbackground Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --reportbackground
    ...    green:blue:yellow
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --maxerrorlines lines  Maximum number of error message lines to show in
#                           report when tests fail. Default is 40, minimum is 10
#                           and `NONE` can be used to show the full message.
Maxerrorlines Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --maxerrorlines
    ...    10
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --maxassignlength characters  Maximum number of characters to show in log
#                           when variables are assigned. Zero or negative values
#                           can be used to avoid showing assigned values at all.
#                           Default is 200.
Maxassignlength Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --maxassignlength
    ...    0
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -L --loglevel level      Threshold level for logging. Available levels: TRACE,
#                           DEBUG, INFO (default), WARN, NONE (no logging). Use
#                           syntax `LOGLEVEL:DEFAULT` to define the default
#                           visible log level in log files.
#                           Examples: --loglevel DEBUG
#                                     --loglevel DEBUG:INFO
Loglevel Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --loglevel
    ...    WARN
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --suitestatlevel level  How many levels to show in `Statistics by Suite`
#                           in log and report. By default all suite levels are
#                           shown. Example:  --suitestatlevel 3
Suitestatlevel Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --suitestatlevel
    ...    0
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --tagstatinclude tag *  Include only matching tags in `Statistics by Tag`
#                           in log and report. By default all tags are shown.
#                           Given tag can be a pattern like with --include.
Tagstatinclude Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --tagstatinclude
    ...    tc1ORtc2
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --tagstatexclude tag *  Exclude matching tags from `Statistics by Tag`.
#                           This option can be used with --tagstatinclude
#                           similarly as --exclude is used with --include.
Tagstatexclude Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --tagstatexclude
    ...    tc3ORtc4
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --tagstatcombine tags:name *  Create combined statistics based on tags.
#                           These statistics are added into `Statistics by Tag`.
#                           If the optional `name` is not given, name of the
#                           combined tag is got from the specified tags. Tags are
#                           matched using the same rules as with --include.
#                           Examples: --tagstatcombine requirement-*
#                                     --tagstatcombine tag1ANDtag2:My_name
Tagstatcombine Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --tagstatcombine
    ...    tc1ORtc2ORtc3ORtc4:COMBINED
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --tagdoc pattern:doc *  Add documentation to tags matching the given
#                           pattern. Documentation is shown in `Test Details` and
#                           also as a tooltip in `Statistics by Tag`. Pattern can
#                           use `*`, `?` and `[]` as wildcards like --test.
#                           Examples: --tagdoc mytag:Example
#                                     --tagdoc "owner-*:Original author"
Tagdoc Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --tagdoc
    ...    tc1ORtc2ORtc3ORtc4:EXAMPLE
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --tagstatlink pattern:link:title *  Add external links into `Statistics by
#                           Tag`. Pattern can use `*`, `?` and `[]` as wildcards
#                           like --test. Characters matching to `*` and `?`
#                           wildcards can be used in link and title with syntax
#                           %N, where N is index of the match (starting from 1).
#                           Examples: --tagstatlink mytag:http://my.domain:Title
#                           --tagstatlink "bug-*:http://url/id=%1:Issue Tracker"
Tagstatlink Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --tagstatlink 
    ...    "tc1:https://pabot.org/PabotLib.html:PabotLib Test Link"
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --expandkeywords name:<pattern>|tag:<pattern> *
#                           Matching keywords will be automatically expanded in
#                           the log file. Matching against keyword name or tags
#                           work using same rules as with --removekeywords.
#                           Examples: --expandkeywords name:BuiltIn.Log
#                                     --expandkeywords tag:expand
Expandkeywords Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    ----expandkeywords
    ...    name:BuiltIn.Log
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --removekeywords all|passed|for|wuks|name:<pattern>|tag:<pattern> *
#                           Remove keyword data from the generated log file.
#                           Keywords containing warnings are not removed except
#                           in the `all` mode.
#                           all:     remove data from all keywords
#                           passed:  remove data only from keywords in passed
#                                    test cases and suites
#                           for:     remove passed iterations from FOR loops
#                           while:   remove passed iterations from WHILE loops
#                           wuks:    remove all but the last failing keyword
#                                    inside `BuiltIn.Wait Until Keyword Succeeds`
#                           name:<pattern>:  remove data from keywords that match
#                                    the given pattern. The pattern is matched
#                                    against the full name of the keyword (e.g.
#                                    'MyLib.Keyword', 'resource.Second Keyword'),
#                                    is case, space, and underscore insensitive,
#                                    and may contain `*`, `?` and `[]` wildcards.
#                                    Examples: --removekeywords name:Lib.HugeKw
#                                              --removekeywords name:myresource.*
#                           tag:<pattern>:  remove data from keywords that match
#                                    the given pattern. Tags are case and space
#                                    insensitive and patterns can contain `*`,
#                                    `?` and `[]` wildcards. Tags and patterns
#                                    can also be combined together with `AND`,
#                                    `OR`, and `NOT` operators.
#                                    Examples: --removekeywords foo
#                                              --removekeywords fooANDbar*
Removekeywords Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --removekeywords
    ...    passed
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --flattenkeywords for|while|iteration|name:<pattern>|tag:<pattern> *
#                           Flattens matching keywords in the generated log file.
#                           Matching keywords get all log messages from their
#                           child keywords and children are discarded otherwise.
#                           for:     flatten FOR loops fully
#                           while:   flatten WHILE loops fully
#                           iteration: flatten FOR/WHILE loop iterations
#                           foritem: deprecated alias for `iteration`
#                           name:<pattern>:  flatten matched keywords using same
#                                    matching rules as with
#                                    `--removekeywords name:<pattern>`
#                           tag:<pattern>:  flatten matched keywords using same
#                                    matching rules as with
#                                    `--removekeywords tag:<pattern>`
Flattenkeywords Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --flattenkeywords
    ...    name:BuiltIn.Log
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --nostatusrc          Sets the return code to zero regardless of failures
#                           in test cases. Error codes are returned normally.
Nostatusrc Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --nostatusrc
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=0

#     --dryrun              Verifies test data and runs tests so that library
#                           keywords are not executed.
Dryrun Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --dryrun
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=0

#  -X --exitonfailure       Stops test execution if any test fails.
Exitonfailure Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --exitonfailure
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --exitonerror         Stops test execution if any error occurs when parsing
#                           test data, importing libraries, and so on.
Exitonerror Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --exitonerror
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --skipteardownonexit  Causes teardowns to be skipped if test execution is
#                           stopped prematurely.
Skipteardownonexit Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --skipteardownonexit
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --randomize all|suites|tests|none  Randomizes the test execution order.
#                           all:    randomizes both suites and tests
#                           suites: randomizes suites
#                           tests:  randomizes tests
#                           none:   no randomization (default)
#                           Use syntax `VALUE:SEED` to give a custom random seed.
#                           The seed must be an integer.
#                           Examples: --randomize all
#                                     --randomize tests:1234
Randomize Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --randomize
    ...    all:1234
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --listener listener *  Class or module for monitoring test execution.
#                           Gets notifications e.g. when tests start and end.
#                           Arguments to the listener class can be given after
#                           the name using a colon or a semicolon as a separator.
#                           Examples: --listener MyListener
#                                     --listener path/to/Listener.py:arg1:arg2
Listener Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --listener
    ...    MyListener
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --prerunmodifier modifier *  Class to programmatically modify the suite
#                           structure before execution. Accepts arguments the
#                           same way as with --listener.
Prerunmodifier Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --prerunmodifier
    ...    MyPreRunModifier
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --prerebotmodifier modifier *  Class to programmatically modify the result
#                           model before creating reports and logs. Accepts
#                           arguments the same way as with --listener.
Prerebotmodifier Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --prerebotmodifier
    ...    MyPreRebotModifier
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --parser parser *     Custom parser class or module. Parser classes accept
#                           arguments the same way as with --listener.
Parser Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --exitonfailure 
    ...    --parser
    ...    MyParser
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --console type        How to report execution on the console.
#                           verbose:  report every suite and test (default)
#                           dotted:   only show `.` for passed test, `s` for
#                                     skipped tests, and `F` for failed tests
#                           quiet:    no output except for errors and warnings
#                           none:     no output whatsoever
Console Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --console
    ...    none
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -. --dotted              Shortcut for `--console dotted`.
Dotted Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --dotted
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --quiet               Shortcut for `--console quiet`.
Quiet Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --quiet
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -W --consolewidth chars  Width of the console output. Default is 78.
Consolewidth Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --consolewidth
    ...    50
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -C --consolecolors auto|on|ansi|off  Use colors on console output or not.
#                           auto: use colors when output not redirected (default)
#                           on:   always use colors
#                           ansi: like `on` but use ANSI colors also on Windows
#                           off:  disable colors altogether
Consolecolors Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --consolecolors
    ...    on
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#     --consolelinks auto|off  Control making paths to results files hyperlinks.
#                           auto: use links when colors are enabled (default)
#                           off: disable links unconditionally
Consolelinks Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --consolelinks
    ...    off
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -K --consolemarkers auto|on|off  Show markers on the console when top level
#                           keywords in a test case end. Values have same
#                           semantics as with --consolecolors.
Consolemarkers Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --consolemarkers
    ...    off
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -P --pythonpath path *   Additional locations (directories, ZIPs) where to
#                           search libraries and other extensions when they are
#                           imported. Multiple paths can be given by separating
#                           them with a colon (`:`) or by using this option
#                           several times. Given path can also be a glob pattern
#                           matching multiple paths.
#                           Examples: --pythonpath libs/
#                                     --pythonpath /opt/libs:libraries.zip
Pythonpath Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --pythonpath
    ...    ${ROBOT_RESULTS_DIR}${/}${TEST_NAME}
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -A --argumentfile path *  Text file to read more arguments from. Use special
#                           path `STDIN` to read contents from the standard input
#                           stream. File can have both options and input files
#                           or directories, one per line. Contents do not need to
#                           be escaped but spaces in the beginning and end of
#                           lines are removed. Empty lines and lines starting
#                           with a hash character (#) are ignored.
#                           Example file:
#                           |  --include regression
#                           |  --name Regression Tests
#                           |  # This is a comment line
#                           |  tests.robot
#                           |  path/to/test/directory/
#                           Examples:
#                           --argumentfile argfile.txt --argumentfile STDIN
Argumentfile Works
    ${res}=    Run Pabot
    ...    --testlevelsplit
    ...    --argumentfile
    ...    ${DATA_DIR}argumentfile1.txt
    ...    ${DATA_DIR}fast.robot
    ...    expect_return_code=2

#  -h -? --help             Print usage instructions.
#  --version                Print version information.