#!/bin/sh
# scripts/eyrie/get_version.sh
# Extracts the version number from the __about__.py file
#

# Get the project directory
prj=$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")

# Extract the version from __about__.py
version=$(grep '__version__' "$prj/src/eyrie/__about__.py" | cut -d '"' -f 2)

# Output the version
echo "$version"
