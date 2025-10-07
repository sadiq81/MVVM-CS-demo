#!/bin/sh

cd "${CI_WORKSPACE}/customerapp/Resources/Plists"

# $ENVIRONMENT_CLIENT_ID and $ENVIRONMENT_CLIENT_SECRET are stored using ENV variables in Xcode Cloud
# CHANGEME
plutil -replace ENVIRONMENT_CLIENT_ID -string $ENVIRONMENT_CLIENT_ID Info.plist
plutil -replace ENVIRONMENT_CLIENT_SECRET -string $ENVIRONMENT_CLIENT_SECRET Info.plist

plutil -replace ENVIRONMENT_OPEN_ID_CLIENT_ID -string $ENVIRONMENT_OPEN_ID_CLIENT_ID Info.plist
plutil -replace ENVIRONMENT_OPEN_ID_CLIENT_SECRET -string $ENVIRONMENT_OPEN_ID_CLIENT_SECRET Info.plist

plutil -p Info.plist

exit 0
