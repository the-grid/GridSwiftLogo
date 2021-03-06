
#!/bin/bash

# **** Update me when new Xcode versions are released! ****
PLATFORM="platform=iOS Simulator,OS=10.0,name=iPhone 6"
SDK="iphonesimulator10.0"


# It is pitch black.
set -e
function trap_handler() {
    echo -e "\n\nOh no! You walked directly into the slavering fangs of a lurking grue!"
    echo "**** You have died ****"
    exit 255
}
trap trap_handler INT TERM EXIT


MODE="$1"

if type xcpretty-travis-formatter &> /dev/null; then
    FORMATTER="-f $(xcpretty-travis-formatter)"
  else
    FORMATTER="-s"
fi

if [ "$MODE" = "main" ]; then
    echo "Verifying iOS main project build."

    set -o pipefail && xcodebuild \
        -project "GridLogo.xcodeproj" \
        -scheme "GridLogo" \
        -sdk "$SDK" \
        -destination "$PLATFORM" \
        build | xcpretty $FORMATTER
    trap - EXIT
    exit 0
fi

echo "Unrecognised mode '$MODE'."
