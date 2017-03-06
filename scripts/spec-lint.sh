#!/usr/bin/env bash
pod spec lint --sources=ssh://git@stash.mgmt.local/ioslib/markitpodspecs.git,https://github.com/CocoaPods/Specs.git
