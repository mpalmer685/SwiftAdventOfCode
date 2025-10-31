#!/usr/bin/env bash
set -e

if [ "$CI" == true ]; then
    echo "CI == true, skipping swiftlint hook"
    exit 0
fi

SWIFTLINT=$(command -v swiftlint)
if [ -z "$SWIFTLINT" ]; then
    echo "swiftlint not found, please install it to use this hook."
    exit 1
fi

# Always lint Package.swift to prevent "No lintable files found at paths: ''"
# caused by a combination of --use-script-input-files and --force-exclude
# See https://github.com/realm/SwiftLint/issues/2619
export SCRIPT_INPUT_FILE_0="Package.swift"
count=1

# Changed files added to stage area
for file_path in $(git diff --diff-filter=d --name-only --cached | grep ".swift$"); do
    export SCRIPT_INPUT_FILE_$count="$file_path"
    count=$((count + 1))
done

if [ $count -eq 1 ]; then
    echo "No Swift files to lint."
    exit 0
fi

export SCRIPT_INPUT_FILE_COUNT=$count
$SWIFTLINT lint --use-script-input-files --force-exclude
