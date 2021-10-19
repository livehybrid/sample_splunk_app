import argparse
import logging
import os
import subprocess
import sys
import traceback
from typing import Optional, List

from versioningit.core import Versioningit
from versioningit.errors import Error
from versioningit.logging import log, warn_bad_version
from versioningit.util import showcmd


def main(argv: Optional[List[str]] = None) -> None:

    parser = argparse.ArgumentParser(
        description="print the next version"
    )
    parser.add_argument(
        "--traceback", action="store_true", help="Show full traceback on library error"
    )
    parser.add_argument(
        "-v", "--verbose", action="count", default=0, help="Show more log messages"
    )
    parser.add_argument(
        "-w", "--write", action="store_true", help="Write version to configured file"
    )
    parser.add_argument("project_dir", nargs="?", default=os.curdir)

    args = parser.parse_args(argv)
    if args.verbose == 0:
        log_level = logging.WARNING
    elif args.verbose == 1:
        log_level = logging.INFO
    else:
        log_level = logging.DEBUG
    logging.basicConfig(
        format="[%(levelname)-8s] %(name)s: %(message)s",
        level=log_level,
    )
    try:
        vgit = Versioningit.from_project_dir(args.project_dir)
        description = vgit.get_vcs_description()
        log.info("vcs returned tag %s", description.tag)
        log.debug("vcs state: %s", description.state)
        log.debug("vcs branch: %s", description.branch)
        log.debug("vcs fields: %r", description.fields)
        tag_version = vgit.get_tag2version(description.tag)
        log.info("tag2version returned version %s", tag_version)
        warn_bad_version(tag_version, "Version extracted from tag")
        next_version = vgit.get_next_version(tag_version, description.branch)
        print(next_version)
        if args.write:
            vgit.write_version(next_version)
    except Error as e:
        if args.traceback:
            traceback.print_exc()
        else:
            print(f"versioningit: {type(e).__name__}: {e}", file=sys.stderr)
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        if args.traceback:
            traceback.print_exc()
        else:
            assert isinstance(e.cmd, list)
            log.error("%s: command returned %d", showcmd(e.cmd), e.returncode)
        sys.exit(e.returncode)


if __name__ == "__main__":
    main()  # pragma: no cover
