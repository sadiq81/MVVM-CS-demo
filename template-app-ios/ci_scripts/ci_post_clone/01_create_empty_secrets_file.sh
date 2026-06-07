#!/bin/sh

# Secrets xcconfig files are not checked into VCS.
# Variables from these files should be stored in Xcode Cloud as secret ENV variables

# UIKit secrets
mkdir -p "${CI_WORKSPACE}/customerapp-UIKit/Resources/Config/Secrets/"
touch "${CI_WORKSPACE}/customerapp-UIKit/Resources/Config/Secrets/UIKit-Development-secrets.xcconfig"
touch "${CI_WORKSPACE}/customerapp-UIKit/Resources/Config/Secrets/UIKit-Production-secrets.xcconfig"

# Mixed secrets
mkdir -p "${CI_WORKSPACE}/customerapp-Mixed/Resources/Config/Secrets/"
touch "${CI_WORKSPACE}/customerapp-Mixed/Resources/Config/Secrets/Mixed-Development-secrets.xcconfig"
touch "${CI_WORKSPACE}/customerapp-Mixed/Resources/Config/Secrets/Mixed-Production-secrets.xcconfig"

# SwiftUI secrets
mkdir -p "${CI_WORKSPACE}/customerapp-SwiftUI/Resources/Config/Secrets/"
touch "${CI_WORKSPACE}/customerapp-SwiftUI/Resources/Config/Secrets/SwiftUI-Development-secrets.xcconfig"
touch "${CI_WORKSPACE}/customerapp-SwiftUI/Resources/Config/Secrets/SwiftUI-Production-secrets.xcconfig"
