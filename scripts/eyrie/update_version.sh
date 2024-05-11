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

    # Check if automatic versioning is disabled
    case "${EYRIE_AUTO_VERSION:-true}" in
        true|yes|on|1)
            ;;
        *)
            echo "Automatic versioning is disabled."
            return 0
            ;;
    esac

    # Fetch the last commit message
    last_commit_message=$(git log -1 --pretty=%B)

    # Check if the last commit was a version update and exit if so
    if echo "$last_commit_message" | grep -q "^Version updated to"; then
        echo "Last commit was already a version update; skipping."
        return 0
    fi

    new_version=$(versioningit)
    old_version=$(grep '^version = ' "pyproject.toml" | cut -d'"' -f2)

    if [ "$new_version" = "$old_version" ]; then
        echo "Current pyproject.toml version $old_version is correct."
    else
        awk -v ver="$new_version" '
            /^\[project\]/ { in_project = 1 }
            /^version = / && in_project { print "version = \"" ver "\""; next }
            { print }
        ' "pyproject.toml" > "pyproject.toml.tmp" && mv "pyproject.toml.tmp" "pyproject.toml"

        echo "Updated pyproject.toml to version $new_version"

        if [ "$1" = "--commit" ]; then
            git add pyproject.toml
            git commit -m "Version updated to $new_version"
        fi
    fi
}

update_version "$1"
