#!/usr/bin/swift -F /Users/jed/source/shared/Devcheckouts/built -framework Devcheckouts -framework Tasks

import Devcheckouts

Devcheckouts.create {

    inhibitAllWarnings()
    workspace("ObservableProperty")

    source("https://github.com/CocoaPods/Specs.git")

    target("ObservablePropertyTests", project: "ObservableProperty", platform: .IOS("9.0")) {
        pod(Cocoapods.Quick)
        pod(Cocoapods.Nimble)
    }
    
}

