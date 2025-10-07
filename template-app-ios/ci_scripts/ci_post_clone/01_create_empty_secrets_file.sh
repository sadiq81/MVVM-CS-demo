#!/bin/sh

# Development-secrets.xcconfig and Production-secrets.xcconfig should not be checked into VCS.
# Variables from these files should be stored in Xcode Cloud as secret ENV variables

mkdir -p "${CI_WORKSPACE}/customerapp/Resources/Config/Secrets/"
touch "${CI_WORKSPACE}/customerapp/Resources/Config/Secrets/Development-secrets.xcconfig"
touch "${CI_WORKSPACE}/customerapp/Resources/Config/Secrets/Production-secrets.xcconfig"
