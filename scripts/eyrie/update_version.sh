#!/bin/sh
#
# This script updates the version in `pyproject.toml` using `versioningit` and,
# optionally, commits the change if the `--commit` flag is provided.
#
# Usage:
#   ./update_version.sh [--commit]
#
# Options:
#   --commit  If specified, adds a "Version updated..." commit with git.
#

# `cd` to the project directory
cd "$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")"

update_version() {
    VERSION=$(versioningit)
    current_version=$(awk -F= '/^version/ {gsub(/[[:space:]]+/, "", $2); gsub(/"/, "", $2); print $2; exit}' pyproject.toml)

    if [ "$VERSION" = "$current_version" ]; then
        echo "Current pyproject.toml version $current_version is correct."
    else
        awk -v ver="$VERSION" '
            /^\[project\]/ { in_project = 1 }
            /^version = / && in_project { print "version = \"" ver "\""; next }
            { print }
        ' "pyproject.toml" > "pyproject.toml.tmp" && mv "pyproject.toml.tmp" "pyproject.toml"

        echo "Updated pyproject.toml to version $VERSION"

        if [ "$1" = "--commit" ]; then
            git add pyproject.toml
            git commit -m "Version updated to $VERSION"
        fi
    fi
}

update_version "$1"