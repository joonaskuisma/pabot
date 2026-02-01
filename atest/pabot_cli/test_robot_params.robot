*** Comments ***
    --rpa                 Turn on the generic automation mode. Mainly affects
                          terminology so that "test" is replaced with "task"
                          in logs and reports. By default the mode is got
                          from test/task header in data files.
    --language lang *     Activate localization. `lang` can be a name or a code
                          of a built-in language, or a path or a module name of
                          a custom language file.
 -F --extension value     Parse only files with this extension when executing
                          a directory. Has no effect when running individual
                          files or when using resource files. If more than one
                          extension is needed, separate them with a colon.
                          Examples: `--extension txt`, `--extension robot:txt`
                          Only `*.robot` files are parsed by default.
 -I --parseinclude pattern *  Parse only files matching `pattern`. It can be:
                          - a file name or pattern like `example.robot` or
                            `*.robot` to parse all files matching that name,
                          - a file path like `path/to/example.robot`, or
                          - a directory path like `path/to/example` to parse
                            all files in that directory, recursively.
 -N --name name           Set the name of the top level suite. By default the
                          name is created based on the executed file or
                          directory.
 -D --doc documentation   Set the documentation of the top level suite.
                          Simple formatting is supported (e.g. *bold*). If the
                          documentation contains spaces, it must be quoted.
                          If the value is path to an existing file, actual
                          documentation is read from that file.
                          Examples: --doc "Very *good* example"
                                    --doc doc_from_file.txt
 -M --metadata name:value *  Set metadata of the top level suite. Value can
                          contain formatting and be read from a file similarly
                          as --doc. Example: --metadata Version:1.2
 -G --settag tag *        Sets given tag(s) to all executed tests.
 -t --test name *         Select tests by name or by long name containing also
                          parent suite name like `Parent.Test`. Name is case
                          and space insensitive and it can also be a simple
                          pattern where `*` matches anything, `?` matches any
                          single character, and `[chars]` matches one character
                          in brackets.
    --task name *         Alias to --test. Especially applicable with --rpa.
 -s --suite name *        Select suites by name. When this option is used with
                          --test, --include or --exclude, only tests in
                          matching suites and also matching other filtering
                          criteria are selected. Name can be a simple pattern
                          similarly as with --test and it can contain parent
                          name separated with a dot. For example, `-s X.Y`
                          selects suite `Y` only if its parent is `X`.
 -i --include tag *       Select tests by tag. Similarly as name with --test,
                          tag is case and space insensitive and it is possible
                          to use patterns with `*`, `?` and `[]` as wildcards.
                          Tags and patterns can also be combined together with
                          `AND`, `OR`, and `NOT` operators.
                          Examples: --include foo --include bar*
                                    --include fooANDbar*
 -e --exclude tag *       Select test cases not to run by tag. These tests are
                          not run even if included with --include. Tags are
                          matched using same rules as with --include.
 -R --rerunfailed output  Select failed tests from an earlier output file to be
                          re-executed. Equivalent to selecting same tests
                          individually using --test.
 -S --rerunfailedsuites output  Select failed suites from an earlier output
                          file to be re-executed.
    --runemptysuite       Executes suite even if it contains no tests. Useful
                          e.g. with --include/--exclude when it is not an error
                          that no test matches the condition.
    --skip tag *          Tests having given tag will be skipped. Tag can be
                          a pattern.
    --skiponfailure tag *  Tests having given tag will be skipped if they fail.
                          Tag can be a pattern
 -v --variable name:value *  Set variables in the test data. Only scalar
                          variables with string value are supported and name is
                          given without `${}`. See --variablefile for a more
                          powerful variable setting mechanism.
                          Examples:
                          --variable name:Robot  =>  ${name} = `Robot`
                          -v "hello:Hello world" =>  ${hello} = `Hello world`
                          -v x: -v y:42          =>  ${x} = ``, ${y} = `42`
 -V --variablefile path *  Python or YAML file file to read variables from.
                          Possible arguments to the variable file can be given
                          after the path using colon or semicolon as separator.
                          Examples: --variablefile path/vars.yaml
                                    --variablefile environment.py:testing
 -d --outputdir dir       Where to create output files. The default is the
                          directory where tests are run from and the given path
                          is considered relative to that unless it is absolute.
 -o --output file         XML output file. Given path, similarly as paths given
                          to --log, --report, --xunit, and --debugfile, is
                          relative to --outputdir unless given as an absolute
                          path. Other output files are created based on XML
                          output files after the test execution and XML outputs
                          can also be further processed with Rebot tool. Can be
                          disabled by giving a special value `NONE`.
                          Default: output.xml
    --legacyoutput        Create XML output file in format compatible with
                          Robot Framework 6.x and earlier.
 -l --log file            HTML log file. Can be disabled by giving a special
                          value `NONE`. Default: log.html
                          Examples: `--log mylog.html`, `-l NONE`
 -r --report file         HTML report file. Can be disabled with `NONE`
                          similarly as --log. Default: report.html
 -x --xunit file          xUnit compatible result file. Not created unless this
                          option is specified.
 -b --debugfile file      Debug file written during execution. Not created
                          unless this option is specified.
 -T --timestampoutputs    When this option is used, timestamp in a format
                          `YYYYMMDD-hhmmss` is added to all generated output
                          files between their basename and extension. For
                          example `-T -o output.xml -r report.html -l none`
                          creates files like `output-20070503-154410.xml` and
                          `report-20070503-154410.html`.
    --splitlog            Split the log file into smaller pieces that open in
                          browsers transparently.
    --logtitle title      Title for the generated log file. The default title
                          is `<SuiteName> Log`.
    --reporttitle title   Title for the generated report file. The default
                          title is `<SuiteName> Report`.
    --reportbackground colors  Background colors to use in the report file.
                          Given in format `passed:failed:skipped` where the
                          `:skipped` part can be omitted. Both color names and
                          codes work.
                          Examples: --reportbackground green:red:yellow
                                    --reportbackground #00E:#E00
    --maxerrorlines lines  Maximum number of error message lines to show in
                          report when tests fail. Default is 40, minimum is 10
                          and `NONE` can be used to show the full message.
    --maxassignlength characters  Maximum number of characters to show in log
                          when variables are assigned. Zero or negative values
                          can be used to avoid showing assigned values at all.
                          Default is 200.
 -L --loglevel level      Threshold level for logging. Available levels: TRACE,
                          DEBUG, INFO (default), WARN, NONE (no logging). Use
                          syntax `LOGLEVEL:DEFAULT` to define the default
                          visible log level in log files.
                          Examples: --loglevel DEBUG
                                    --loglevel DEBUG:INFO
    --suitestatlevel level  How many levels to show in `Statistics by Suite`
                          in log and report. By default all suite levels are
                          shown. Example:  --suitestatlevel 3
    --tagstatinclude tag *  Include only matching tags in `Statistics by Tag`
                          in log and report. By default all tags are shown.
                          Given tag can be a pattern like with --include.
    --tagstatexclude tag *  Exclude matching tags from `Statistics by Tag`.
                          This option can be used with --tagstatinclude
                          similarly as --exclude is used with --include.
    --tagstatcombine tags:name *  Create combined statistics based on tags.
                          These statistics are added into `Statistics by Tag`.
                          If the optional `name` is not given, name of the
                          combined tag is got from the specified tags. Tags are
                          matched using the same rules as with --include.
                          Examples: --tagstatcombine requirement-*
                                    --tagstatcombine tag1ANDtag2:My_name
    --tagdoc pattern:doc *  Add documentation to tags matching the given
                          pattern. Documentation is shown in `Test Details` and
                          also as a tooltip in `Statistics by Tag`. Pattern can
                          use `*`, `?` and `[]` as wildcards like --test.
                          Examples: --tagdoc mytag:Example
                                    --tagdoc "owner-*:Original author"
    --tagstatlink pattern:link:title *  Add external links into `Statistics by
                          Tag`. Pattern can use `*`, `?` and `[]` as wildcards
                          like --test. Characters matching to `*` and `?`
                          wildcards can be used in link and title with syntax
                          %N, where N is index of the match (starting from 1).
                          Examples: --tagstatlink mytag:http://my.domain:Title
                          --tagstatlink "bug-*:http://url/id=%1:Issue Tracker"
    --expandkeywords name:<pattern>|tag:<pattern> *
                          Matching keywords will be automatically expanded in
                          the log file. Matching against keyword name or tags
                          work using same rules as with --removekeywords.
                          Examples: --expandkeywords name:BuiltIn.Log
                                    --expandkeywords tag:expand
    --removekeywords all|passed|for|wuks|name:<pattern>|tag:<pattern> *
                          Remove keyword data from the generated log file.
                          Keywords containing warnings are not removed except
                          in the `all` mode.
                          all:     remove data from all keywords
                          passed:  remove data only from keywords in passed
                                   test cases and suites
                          for:     remove passed iterations from FOR loops
                          while:   remove passed iterations from WHILE loops
                          wuks:    remove all but the last failing keyword
                                   inside `BuiltIn.Wait Until Keyword Succeeds`
                          name:<pattern>:  remove data from keywords that match
                                   the given pattern. The pattern is matched
                                   against the full name of the keyword (e.g.
                                   'MyLib.Keyword', 'resource.Second Keyword'),
                                   is case, space, and underscore insensitive,
                                   and may contain `*`, `?` and `[]` wildcards.
                                   Examples: --removekeywords name:Lib.HugeKw
                                             --removekeywords name:myresource.*
                          tag:<pattern>:  remove data from keywords that match
                                   the given pattern. Tags are case and space
                                   insensitive and patterns can contain `*`,
                                   `?` and `[]` wildcards. Tags and patterns
                                   can also be combined together with `AND`,
                                   `OR`, and `NOT` operators.
                                   Examples: --removekeywords foo
                                             --removekeywords fooANDbar*
    --flattenkeywords for|while|iteration|name:<pattern>|tag:<pattern> *
                          Flattens matching keywords in the generated log file.
                          Matching keywords get all log messages from their
                          child keywords and children are discarded otherwise.
                          for:     flatten FOR loops fully
                          while:   flatten WHILE loops fully
                          iteration: flatten FOR/WHILE loop iterations
                          foritem: deprecated alias for `iteration`
                          name:<pattern>:  flatten matched keywords using same
                                   matching rules as with
                                   `--removekeywords name:<pattern>`
                          tag:<pattern>:  flatten matched keywords using same
                                   matching rules as with
                                   `--removekeywords tag:<pattern>`
    --nostatusrc          Sets the return code to zero regardless of failures
                          in test cases. Error codes are returned normally.
    --dryrun              Verifies test data and runs tests so that library
                          keywords are not executed.
 -X --exitonfailure       Stops test execution if any test fails.
    --exitonerror         Stops test execution if any error occurs when parsing
                          test data, importing libraries, and so on.
    --skipteardownonexit  Causes teardowns to be skipped if test execution is
                          stopped prematurely.
    --randomize all|suites|tests|none  Randomizes the test execution order.
                          all:    randomizes both suites and tests
                          suites: randomizes suites
                          tests:  randomizes tests
                          none:   no randomization (default)
                          Use syntax `VALUE:SEED` to give a custom random seed.
                          The seed must be an integer.
                          Examples: --randomize all
                                    --randomize tests:1234
    --listener listener *  Class or module for monitoring test execution.
                          Gets notifications e.g. when tests start and end.
                          Arguments to the listener class can be given after
                          the name using a colon or a semicolon as a separator.
                          Examples: --listener MyListener
                                    --listener path/to/Listener.py:arg1:arg2
    --prerunmodifier modifier *  Class to programmatically modify the suite
                          structure before execution. Accepts arguments the
                          same way as with --listener.
    --prerebotmodifier modifier *  Class to programmatically modify the result
                          model before creating reports and logs. Accepts
                          arguments the same way as with --listener.
    --parser parser *     Custom parser class or module. Parser classes accept
                          arguments the same way as with --listener.
    --console type        How to report execution on the console.
                          verbose:  report every suite and test (default)
                          dotted:   only show `.` for passed test, `s` for
                                    skipped tests, and `F` for failed tests
                          quiet:    no output except for errors and warnings
                          none:     no output whatsoever
 -. --dotted              Shortcut for `--console dotted`.
    --quiet               Shortcut for `--console quiet`.
 -W --consolewidth chars  Width of the console output. Default is 78.
 -C --consolecolors auto|on|ansi|off  Use colors on console output or not.
                          auto: use colors when output not redirected (default)
                          on:   always use colors
                          ansi: like `on` but use ANSI colors also on Windows
                          off:  disable colors altogether
    --consolelinks auto|off  Control making paths to results files hyperlinks.
                          auto: use links when colors are enabled (default)
                          off: disable links unconditionally
 -K --consolemarkers auto|on|off  Show markers on the console when top level
                          keywords in a test case end. Values have same
                          semantics as with --consolecolors.
 -P --pythonpath path *   Additional locations (directories, ZIPs) where to
                          search libraries and other extensions when they are
                          imported. Multiple paths can be given by separating
                          them with a colon (`:`) or by using this option
                          several times. Given path can also be a glob pattern
                          matching multiple paths.
                          Examples: --pythonpath libs/
                                    --pythonpath /opt/libs:libraries.zip
 -A --argumentfile path *  Text file to read more arguments from. Use special
                          path `STDIN` to read contents from the standard input
                          stream. File can have both options and input files
                          or directories, one per line. Contents do not need to
                          be escaped but spaces in the beginning and end of
                          lines are removed. Empty lines and lines starting
                          with a hash character (#) are ignored.
                          Example file:
                          |  --include regression
                          |  --name Regression Tests
                          |  # This is a comment line
                          |  tests.robot
                          |  path/to/test/directory/
                          Examples:
                          --argumentfile argfile.txt --argumentfile STDIN
 -h -? --help             Print usage instructions.
 --version                Print version information.

*** Settings ***
Resource    ../resources/Runner.resource

*** Test Cases ***