#!/bin/bash

set -e

# SwiftGen
if [[ ! -z ${CI} ]]
then
    echo skipping swiftgen,
else
    echo excute swiftgen

    # not git-added (manual `bundle exec pod install` is required)
    #----------------------------------------
    PODS_ROOT="./Pods"
    SWIFTGEN="${PODS_ROOT}"/SwiftGen/bin/swiftgen
    if [ -x "${SWIFTGEN}" ]; then
        "${SWIFTGEN}" --version
        "${SWIFTGEN}" config run
    else
        rm -rf "${PODS_ROOT}"/SwiftGen  # clean up for next install
        echo "error: SwiftGen is not installed. Run \`make bootstrap\`."
        exit 1
    fi
fi
