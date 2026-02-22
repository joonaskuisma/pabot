#  Copyright 2014->future! Mikko Korpela
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  partly based on work by Pekka Klarck
#  by Nokia Solutions and Networks
#  that was licensed under Apache License Version 2.0
from __future__ import absolute_import, print_function

import os
import re
import time
from typing import Any, Dict, List, Optional, Callable
from datetime import timedelta

from robot import __version__ as ROBOT_VERSION
from robot.api import ExecutionResult, ResultVisitor
from robot.conf import RobotSettings
from robot.errors import DataError
from robot.result.executionresult import CombinedResult
from robot.result import Keyword

try:
    from robot.result import TestSuite
except ImportError:
    from robot.result.testsuite import TestSuite

from robot.model import SuiteVisitor
from .writer import get_writer


class ResultMerger(ResultVisitor):
    """Merges multiple Robot Framework execution results into a single suite structure."""

    def __init__(
        self,
        result: ExecutionResult,
        tests_root_name: str,
        out_dir: str,
        copied_artifacts: List[str],
        timestamp_id: Optional[str],
        legacy_output: bool,
    ) -> None:
        """Initialize result merger state."""
        self.root: TestSuite = result.suite
        self.errors = result.errors
        self.current: Optional[TestSuite] = None
        self._skip_until: Optional[TestSuite] = None
        self._tests_root_name = tests_root_name
        self._prefix: str = ""
        self._out_dir = out_dir
        self.legacy_output = legacy_output
        self.timestamp_id = timestamp_id
        self.writer = get_writer()

        self._patterns: List[re.Pattern[str]] = []
        regexp_template = r'(src|href)="(.*?[\\\/]+)?({})"'

        for artifact in copied_artifacts:
            pattern = regexp_template.format(re.escape(artifact))
            self._patterns.append(re.compile(pattern))

    def merge(self, merged: ExecutionResult) -> None:
        """Merge a single execution result into the current result tree."""
        try:
            self._set_prefix(merged.source)
            merged.suite.visit(self)
            self.root.metadata.update(merged.suite.metadata)
            if self.errors != merged.errors:
                self.errors.add(merged.errors)
        except Exception:
            if self.writer:
                self.writer.write(f"Error while merging result {merged.source}", level="error")
            else:
                print(f"Error while merging result {merged.source}")
            raise

    def _set_prefix(self, source: str) -> None:
        """Set prefix used for artifact name rewriting."""
        self._prefix = prefix(source, self.timestamp_id)

    def start_suite(self, suite: TestSuite) -> None:
        """Handle suite start during result tree traversal."""
        if self._skip_until and self._skip_until != suite:
            return
        if not self.current:
            self.current = self._find_root(suite)
            assert self.current
            if self.current is not suite:
                self._append_keywords(from_suite=suite)
            else:
                self._append_keywords()
        else:
            next_suite = self._find(self.current.suites, suite)
            if next_suite is None:
                self._append_keywords(to_suite=suite, from_suite=suite)
                self.current.suites.append(suite)
                suite.parent = self.current
                self._skip_until = suite   
            else:
                self.current = next_suite
                if self.current is not suite:
                    self._append_keywords(from_suite=suite)
                else:
                    self._append_keywords()

    def _append_keywords(self, to_suite: Optional[TestSuite] = None, from_suite: Optional[TestSuite] = None) -> None:
        """Wrap suite setup and teardown into Pabot containers and preserve each
        original keyword with process ID in its name.
        """
        if to_suite is None:
            to_suite = self.current
        if from_suite is None:
            from_suite = self.current    

        process_id = self._prefix.split("-", 2)[-1] or "UNKNOWN"

        # ==============================
        # Helper: create or get container
        # ==============================
        def _get_or_create_container(name: str, suite: TestSuite) -> Keyword:
            
            container = None

            if name == "Pabot Suite Setup Container":
                container = suite.setup
            else:
                container = suite.teardown

            if not container or container.name != name:
                container = Keyword(name=name, owner="pabot", type="SETUP")
                container.body = []

                if name == "Pabot Suite Setup Container":
                    suite.setup = container
                else:
                    suite.teardown = container

            return container

        # ==============================
        # Helper: update container timing + status
        # ==============================
        def _update_container_metadata(container: Keyword) -> None:
            children = [kw for kw in container.body if isinstance(kw, Keyword)]
            if not children:
                return

            # Status
            statuses = [kw.status for kw in children if kw.status]
            if "FAIL" in statuses:
                container.status = "FAIL"
            elif statuses and all(s == "SKIP" for s in statuses):
                container.status = "SKIP"
            else:
                container.status = "PASS"

            # Elapsed time = sum of children (supports int and timedelta)
            elapsed_values = [
                kw.elapsed_time
                for kw in children
                if getattr(kw, "elapsed_time", None) is not None
            ]

            if not elapsed_values:
                return

            first_value = elapsed_values[0]

            if isinstance(first_value, timedelta):
                total = sum(elapsed_values, timedelta())
            else:
                total = sum(elapsed_values)

            container.elapsed_time = total

        # ==============================
        # ========= SETUP =========
        # ==============================
        if from_suite.has_setup:
            original_setup = from_suite.setup.deepcopy()
            setup_container = _get_or_create_container("Pabot Suite Setup Container", to_suite)

            original_setup.name = f"{original_setup.name} (ID:{process_id})"
            original_setup.type = "KEYWORD"

            setup_container.body.append(original_setup)
            _update_container_metadata(setup_container)
            to_suite.setup = setup_container

        # ==============================
        # ========= TEARDOWN =========
        # ==============================
        if from_suite.has_teardown:
            original_teardown = from_suite.teardown.deepcopy()
            teardown_container = _get_or_create_container("Pabot Suite Teardown Container", to_suite)

            original_teardown.name = f"{original_teardown.name} (ID:{process_id})"
            original_teardown.type = "KEYWORD"

            teardown_container.body.append(original_teardown)
            _update_container_metadata(teardown_container)
            to_suite.teardown = teardown_container

    def _find_root(self, suite: TestSuite) -> TestSuite:
        """Validate and return root suite."""
        if self.root.name != suite.name:
            raise ValueError(
                f'self.root.name "{self.root.name}" != suite.name "{suite.name}"'
            )
        return self.root

    def _find(self, items: List[TestSuite], suite: TestSuite) -> Optional[TestSuite]:
        """Find matching suite by name and source."""
        for item in items:
            if item.name == suite.name and item.source == suite.source:
                return item
        return None

    def end_suite(self, suite: TestSuite) -> None:
        """Handle suite end during traversal and merge timing/test data."""
        if self._skip_until and self._skip_until != suite:
            return
        if self._skip_until == suite:
            self._skip_until = None
            return
        self.merge_missing_tests(suite)
        self._calculate_elapsed_time(self.current)
        self.clean_pabotlib_waiting_keywords(self.current)
        self.current = self.current.parent

    def _calculate_elapsed_time(self, suite: TestSuite) -> None:
        """Calculate suite elapsed time as sum of setup, tests, suites, and teardown."""
        if not suite:
            return

        total = timedelta()

        # Add setup elapsed time
        if getattr(suite, "setup", None) and getattr(suite.setup, "elapsed_time", None) is not None:
            setup_elapsed = suite.setup.elapsed_time
            if isinstance(setup_elapsed, timedelta):
                total += setup_elapsed
            else:
                try:
                    total += timedelta(seconds=float(setup_elapsed))
                except Exception:
                    pass

        # Add all direct test elapsed times
        for test in getattr(suite, "tests", []) or []:
            test_elapsed = getattr(test, "elapsed_time", None)
            if test_elapsed is not None:
                if isinstance(test_elapsed, timedelta):
                    total += test_elapsed
                else:
                    try:
                        total += timedelta(seconds=float(test_elapsed))
                    except Exception:
                        pass

        # Add all child suite elapsed times
        for subsuite in getattr(suite, "suites", []) or []:
            subsuite_elapsed = getattr(subsuite, "elapsed_time", None)
            if subsuite_elapsed is not None:
                if isinstance(subsuite_elapsed, timedelta):
                    total += subsuite_elapsed
                else:
                    try:
                        total += timedelta(seconds=float(subsuite_elapsed))
                    except Exception:
                        pass

        # Add teardown elapsed time
        if getattr(suite, "teardown", None) and getattr(suite.teardown, "elapsed_time", None) is not None:
            teardown_elapsed = suite.teardown.elapsed_time
            if isinstance(teardown_elapsed, timedelta):
                total += teardown_elapsed
            else:
                try:
                    total += timedelta(seconds=float(teardown_elapsed))
                except Exception:
                    pass

        suite.elapsed_time = total

    def clean_pabotlib_waiting_keywords(self, suite: TestSuite) -> None:
        """Remove empty PabotLib waiting keywords from suite."""
        pass

    def merge_missing_tests(self, suite: TestSuite) -> None:
        """Add tests missing from current merged suite."""
        cur = self.current
        for test in suite.tests:
            if not any(t.longname == test.longname for t in cur.tests):
                test.parent = cur
                cur.tests.append(test)

    def merge_time(self, suite: TestSuite) -> None:
        """Merge suite start and end times."""
        cur = self.current
        if ROBOT_VERSION >= "7.0" and not self.legacy_output:
            cur.elapsed_time = None 
        cur.endtime = max([cur.endtime, suite.endtime])
        cur.starttime = min([cur.starttime, suite.starttime])

    def visit_message(self, msg: Any) -> None:
        """Rewrite artifact links inside HTML messages."""
        if not msg.html:
            return

        msg.message = msg.message.replace('src="../../', 'src="')
        msg.message = msg.message.replace('href="../../', 'href="')

        if not self._patterns:
            return

        if not ("src=" in msg.message or "href=" in msg.message):
            return

        for pattern in self._patterns:
            all_matches = re.finditer(pattern, msg.message)
            offset = 0
            prefix_str = self._prefix + "-"
            for match in all_matches:
                filename_start = match.start(3) + offset
                msg.message = (
                    msg.message[:filename_start]
                    + prefix_str
                    + msg.message[filename_start:]
                )
                offset += len(prefix_str)


class ResultsCombiner(CombinedResult):
    """Combine multiple already merged results."""

    def add_result(self, other: ExecutionResult) -> None:
        """Add another result into this combined result."""
        for suite in other.suite.suites:
            self.suite.suites.append(suite)
        self.errors.add(other.errors)


def prefix(source: str, timestamp_id: Optional[str]) -> str:
    """Generate prefix for artifacts based on result source path."""
    try:
        path_without_id, id_ = os.path.split(os.path.dirname(source))
        if not id_:
            return ""
        if os.path.split(path_without_id)[1] == 'pabot_results':
            return "-".join([str(p) for p in [timestamp_id, id_] if p is not None])
        else:
            _, index = os.path.split(path_without_id)
            if not index:
                return ""
            return "-".join([str(p) for p in [timestamp_id, index, id_] if p is not None])
    except Exception:
        return ""


def group_by_root(
    results: List[str],
    critical_tags: List[str],
    non_critical_tags: List[str],
    invalid_xml_callback: Callable[[], None],
) -> Dict[str, List[ExecutionResult]]:
    """Group execution results by root suite name."""
    groups: Dict[str, List[ExecutionResult]] = {}
    writer = get_writer()

    max_retries = 10
    retry_time = 0.3
    retries_used = 0

    for src in results:
        while True:
            try:
                res = ExecutionResult(src)
                break
            except DataError as err:
                if retries_used < max_retries:
                    retries_used += 1
                    time.sleep(retry_time)
                    continue

                if writer:
                    writer.write(err.message, level="error")
                    writer.write(f"Skipping '{src}' from final result", level="warning")
                else:
                    print(err.message)
                    print(f"Skipping '{src}' from final result")

                invalid_xml_callback()
                res = None
                break

        if res is None:
            continue

        if ROBOT_VERSION < "4.0":
            res.suite.set_criticality(critical_tags, non_critical_tags)

        groups[res.suite.name] = groups.get(res.suite.name, []) + [res]

    return groups


def merge_groups(
    results: List[str],
    critical_tags: List[str],
    non_critical_tags: List[str],
    tests_root_name: str,
    invalid_xml_callback: Callable[[], None],
    out_dir: str,
    copied_artifacts: List[str],
    timestamp_id: Optional[str],
    legacy_output: bool,
) -> List[ExecutionResult]:
    """Merge grouped execution results."""
    merged: List[ExecutionResult] = []

    for group in group_by_root(
        results, critical_tags, non_critical_tags, invalid_xml_callback
    ).values():
        base = group[0]
        merger = ResultMerger(
            base, tests_root_name, out_dir, copied_artifacts, timestamp_id, legacy_output
        )
        for out in group:
            merger.merge(out)
        merged.append(base)

    return merged


def merge(
    result_files: List[str],
    rebot_options: Dict[str, Any],
    tests_root_name: str,
    copied_artifacts: List[str],
    timestamp_id: Optional[str],
    invalid_xml_callback: Optional[Callable[[], None]] = None,
) -> ExecutionResult:
    """Main entry point for merging multiple Robot output files."""
    assert len(result_files) > 0

    if invalid_xml_callback is None:
        invalid_xml_callback = lambda: 0

    settings = RobotSettings(rebot_options).get_rebot_settings()

    critical_tags: List[str] = []
    non_critical_tags: List[str] = []

    if ROBOT_VERSION < "4.0":
        critical_tags = settings.critical_tags
        non_critical_tags = settings.non_critical_tags

    merged = merge_groups(
        result_files,
        critical_tags,
        non_critical_tags,
        tests_root_name,
        invalid_xml_callback,
        settings.output_directory,
        copied_artifacts,
        timestamp_id,
        rebot_options.get('legacyoutput'),
    )

    if len(merged) == 1:
        return merged[0]
    else:
        return ResultsCombiner(merged)
