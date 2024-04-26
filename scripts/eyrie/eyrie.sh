#!/bin/sh
#
# Runs the `eyrie` CLI.
#
# (For when you've only got `scripts/eyrie/` in your `$PATH`, and no `eyrie`
# executable in your Python environment. (Typically for Eyrie developers.))
#

python "$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")/src/eyrie/cli.py"
