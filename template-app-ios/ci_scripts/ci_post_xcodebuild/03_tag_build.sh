#!/bin/sh

if [ -z "$CI_ARCHIVE_PATH" ]; then
    echo "Archive was not created, skipped tagging"
    exit 0
fi

cd ..


if [[ -n $CI_APP_STORE_SIGNED_APP_PATH ]]; # checks if there is an AppStore signed archive after running xcodebuild
then
    
    marketingVersion=$(xcodebuild -showBuildSettings | grep MARKETING_VERSION | tr -d 'MARKETING_VERSION =')
    buildNumber=${CI_BUILD_NUMBER}

    tag="${ENVIRONMENT_CONFIGURATION}/xcode-cloud/${marketingVersion}-${buildNumber}"
        
    git=$(sh /etc/profile; which git)

    $("$git" tag -a ${tag} -m "Released ${tag}")
    # CHANGEME
    # GIT_PASSWORD should be stored in xcode cloud as a secret
    $("$git" push https://username:${GIT_PASSWORD}@github.com/sadiq81/ios-template-app.git --tags)

    echo "Tagged build ${tag}"
 
fi
