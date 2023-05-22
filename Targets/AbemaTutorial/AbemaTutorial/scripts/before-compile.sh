#!/bin/bash

set -e

# SwiftLint
if [[ ! -z ${CI} ]]
then
    echo skipping swiftlint
else
    echo excute swiftlint

    $PODS_ROOT/SwiftLint/swiftlint lint --strict

    make mockolo
fi
