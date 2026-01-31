#!/usr/bin/env python
import sys
from robot import run_cli


def main():
    # Forward all CLI arguments directly to Robot Framework
    # sys.argv[0] is the script name, so we drop it
    print(sys.argv[1:])
    rc = run_cli(sys.argv[1:])
    # rc = run_cli(["--help"])
    sys.exit(rc)


if __name__ == "__main__":
    main()