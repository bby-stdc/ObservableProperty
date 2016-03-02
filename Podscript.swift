#!/usr/bin/swift -F /Users/jed/source/shared/Devcheckouts/built -framework Devcheckouts -framework Tasks

import Devcheckouts

Devcheckouts.create {

    inhibitAllWarnings()
    workspace("ObservableProperty")

    source("https://github.com/CocoaPods/Specs.git")

    target("ObservableProperty", project: "ObservableProperty", platform: .IOS("9.0")) {
        pod(Shared.SwiftSynchronized)
    }

    target("ObservablePropertyTests", project: "ObservableProperty", platform: .IOS("9.0")) {
        pod(Shared.SwiftSynchronized)
        pod(Cocoapods.Quick)
        pod(Cocoapods.Nimble)
    }
    
}

