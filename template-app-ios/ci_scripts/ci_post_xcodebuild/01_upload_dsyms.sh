#!/bin/sh

if [ -z "$CI_ARCHIVE_PATH" ]; then
    echo "Archive was not created, skipped Dsyms"
    exit 0
fi

set -e

echo "Archive path is available. Let's run dSYMs uploading script"
# Move up to parent directory
cd ..
# Debug
echo "Derived data path: $CI_DERIVED_DATA_PATH"
echo "Archive path: $CI_ARCHIVE_PATH"
echo "WORKSPACE path: $CI_WORKSPACE"
echo "Current dir: " pwd
# Crashlytics dSYMs script

"$CI_PRIMARY_REPOSITORY_PATH/ci_scripts/ci_post_xcodebuild/upload-symbols" -gsp "$CI_WORKSPACE/customerapp/Resources/Plists/GoogleService-Info.plist" -p ios "$CI_ARCHIVE_PATH/dSYMs"
