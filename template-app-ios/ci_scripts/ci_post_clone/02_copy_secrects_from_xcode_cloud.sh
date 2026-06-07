#!/bin/sh

# $ENVIRONMENT_CLIENT_ID and $ENVIRONMENT_CLIENT_SECRET are stored using ENV variables in Xcode Cloud
# CHANGEME

for app_dir in "customerapp-UIKit" "customerapp-Mixed" "customerapp-SwiftUI"; do
    plist="${CI_WORKSPACE}/${app_dir}/Resources/Plists/Info.plist"
    if [ -f "$plist" ]; then
        echo "Updating secrets in ${app_dir}/Resources/Plists/Info.plist"
        plutil -replace ENVIRONMENT_CLIENT_ID -string $ENVIRONMENT_CLIENT_ID "$plist"
        plutil -replace ENVIRONMENT_CLIENT_SECRET -string $ENVIRONMENT_CLIENT_SECRET "$plist"
        plutil -replace ENVIRONMENT_OPEN_ID_CLIENT_ID -string $ENVIRONMENT_OPEN_ID_CLIENT_ID "$plist"
        plutil -replace ENVIRONMENT_OPEN_ID_CLIENT_SECRET -string $ENVIRONMENT_OPEN_ID_CLIENT_SECRET "$plist"
        plutil -p "$plist"
    fi
done

exit 0
