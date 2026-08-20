default:
	just -l

xc:
	xed .

# Run the tests on macOS, single test e.g.: just test-macos 'rendersSupportedFeatures'
test-macos filter="":
	#!/usr/bin/env bash
	set -euo pipefail
	ARGS=""
	if [ -n "{{filter}}" ]; then ARGS="--filter {{filter}}"; fi
	swift test $ARGS

# Name to find the user-managed test simulator (snapshots last created on iPhone 13 Mini, iOS 26.2)
TEST_SIM_NAME := "Test Target"

# Run the tests on the iOS simulator (own snapshot references, text renders differently than on macOS).
# set SNAPSHOT_TESTING_RECORD=all to update the test images
test-ios filter="":
	#!/usr/bin/env bash
	set -euo pipefail
	TEST_SIM_ID=$(xcrun simctl list devices | grep '{{TEST_SIM_NAME}}' | grep -oE '[0-9A-F-]{36}' | head -1)
	# TEST_RUNNER_ prefix: xcodebuild forwards it to the test process with the prefix stripped.
	export TEST_RUNNER_SNAPSHOT_TESTING_RECORD="${SNAPSHOT_TESTING_RECORD:-}"
	ARGS=""
	if [ -n "{{filter}}" ]; then ARGS="-only-testing:TinySVGViewTests/{{filter}}"; fi
	xcodebuild -scheme TinySVGView -destination "platform=iOS Simulator,id=$TEST_SIM_ID" test -collect-test-diagnostics never $ARGS 2>&1 | xcbeautify --disable-logging

# Options are in .swiftformat.
format:
	swiftformat Source Tests
