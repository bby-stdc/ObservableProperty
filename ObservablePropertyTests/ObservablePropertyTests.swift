//
//  ObservablePropertyTests.swift
//  ObservablePropertyTests
//
//  Created by Jed Lewison on 2/21/16.
//  Copyright © 2016 Jed Lewison. All rights reserved.
//

import Quick
import Nimble

enum TestError: ErrorType {
    case SimpleError
}

@testable import ObservableProperty

let nilStringOptional = Optional<String>(nilLiteral: ())

class TestClass {
    var text = ObservableProperty<String>(value: "lulz")
    var optionalString = ObservableProperty(value: nilStringOptional, error: nil)
}

class ObservablePropertySpec: QuickSpec {

    override func spec() {

        var subject: TestClass!
        var observedValue: String?
        var observedError: ErrorType?

        beforeEach {
            subject = TestClass()
            subject.text.setValue("First Value")
        }

        context("observing with initial value included") {

            beforeEach {

                subject.text.addObserver(self) {

                    switch $0.event {
                    case .Error(let error, let value):
                        observedError = error
                        observedValue = value
                    case .Next(let value):
                        observedError = nil
                        observedValue = value
                    }

                }

            }

            describe("immediately after observation") {

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

            context("when reporting an error") {

                beforeEach {
                    subject.text.setError(TestError.SimpleError)
                }

                it("should have the error") {
                    expect(observedError).toNot(beNil())
                }

                it("should still have the first value") {
                    expect(observedValue).to(equal("First Value"))
                }

                context("The next time a value is set") {

                    beforeEach {
                        subject.text.setValue("Error-clearing value")
                    }

                    it("should automatically clear the error") {
                        expect(observedError).to(beNil())
                    }

                    it("the new value should equal the error-clearing value") {
                        expect(observedValue).to(equal("Error-clearing value"))
                    }

                }

                context("The next time a value is set with another error") {

                    beforeEach {
                        subject.text.setValue("Value with error", error: TestError.SimpleError)
                    }

                    it("should still have an error") {
                        expect(observedError).toNot(beNil())
                    }

                    it("the new value should be the value with an error") {
                        expect(observedValue).to(equal("Value with error"))
                    }

                }

            }

        }

        context("observing while ignoring initial value") {

            beforeEach {

                subject.text.addObserver(self, includeInitialValue: false) {

                    switch $0.event {
                    case .Error(let error, let value):
                        observedError = error
                        observedValue = value
                    case .Next(let value):
                        observedError = nil
                        observedValue = value
                    }

                }

            }

            describe("immediately after observation") {

                it("should not have an error") {
                    expect(observedError).to(beNil())
                }

                it("Should have the initial value") {
                    expect(observedValue).to(beNil())
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

            context("when reporting an error") {

                beforeEach {
                    subject.text.setError(TestError.SimpleError)
                }

                it("should have the error") {
                    expect(observedError).toNot(beNil())
                }

                it("should still have the first value") {
                    expect(observedValue).to(equal("First Value"))
                }

                context("The next time a value is set") {

                    beforeEach {
                        subject.text.setValue("Error-clearing value")
                    }

                    it("should automatically clear the error") {
                        expect(observedError).to(beNil())
                    }

                    it("the new value should equal the error-clearing value") {
                        expect(observedValue).to(equal("Error-clearing value"))
                    }
                    
                }
                
                context("The next time a value is set with another error") {
                    
                    beforeEach {
                        subject.text.setValue("Value with error", error: TestError.SimpleError)
                    }
                    
                    it("should still have an error") {
                        expect(observedError).toNot(beNil())
                    }
                    
                    it("the new value should be the value with an error") {
                        expect(observedValue).to(equal("Value with error"))
                    }
                    
                }
                
            }
            
        }
        
        
        afterEach {
            subject = nil
            observedError = nil
            observedValue = nil
        }
    }
}
