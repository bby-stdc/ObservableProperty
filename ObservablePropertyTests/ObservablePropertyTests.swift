//
//  ObservablePropertyTests.swift
//  ObservablePropertyTests
//
//  Created by Jed Lewison on 2/21/16.
//  Copyright © 2016 Jed Lewison. All rights reserved.
//

import Quick
import Nimble

@testable import ObservableProperty

let asdf = Optional<String>(nilLiteral: ())

class TestClass {
    var text = ObservableProperty<String>(value: "lulz")
    var optionalString = ObservableProperty(value: asdf, error: nil)
}

class ObservablePropertySpec: QuickSpec {

    override func spec() {

        var subject: TestClass!
        var observedValue: String?
        var observedError: ErrorType?

        beforeEach {
            subject = TestClass()
            subject.text.setValue("First Value")
            subject.text.addObserver(self) {
                switch $0 {
                case .Error(let error, let value):
                    observedError = error
                    observedValue = value
                case .Next(let value):
                    observedError = nil
                    observedValue = value
                }
            }

        }

        context("immediately after observation") {

            it("should not have an error") {
                expect(observedError).to(beNil())
            }

            it("Should have the initial value") {
                expect(observedValue).to(equal("First Value"))
            }

        }

        context("after a change") {

            beforeEach {
                subject.text.setValue("Second Value")
            }

            it("still should not have an error") {
                expect(observedError).to(beNil())
            }

            it("Should eventualy get the second value") {
                expect(observedValue).to(equal("Second Value"))
            }

        }

        afterEach {
            subject = nil
            observedError = nil
            observedValue = nil
        }
    }
}
