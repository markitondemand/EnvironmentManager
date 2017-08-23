#!/usr/bin/env bash
pod lib lint --verbose --sources=ssh://git@stash.mgmt.local/ioslib/markitpodspecs.git,https://github.com/CocoaPods/Specs.git
