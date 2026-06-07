#!/bin/zsh

if [ -z "$CI_ARCHIVE_PATH" ]; then
    echo "Archive was not created, skipped Whats new"
    exit 0
fi

lastTag=$(git fetch --unshallow -q && git describe --tags --abbrev=0)

echo "last tag: $lastTag"

# CHANGEME
git log --pretty=format:"%s" "$lastTag..HEAD" > "$CI_PRIMARY_REPOSITORY_PATH/TestFlight/WhatToTest.da.txt"
