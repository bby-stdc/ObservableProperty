//
//  Observation.swift
//  ObservableProperty
//
//  Created by Jed Lewison on 2/28/16.
//  Copyright © 2016 Jed Lewison. All rights reserved.
//

import Foundation

final public class Observation<Value> {

    public let event: ObservationEvent<Value>

    weak var observerBox: WeakObserverBox<Value>?

    init(event: ObservationEvent<Value>, observerBox: WeakObserverBox<Value>) {
        self.event = event
        self.observerBox = observerBox
    }

    public var value: Value {
        return event.value
    }

    public var error: ErrorType? {
        return event.error
    }

    public func unobserve() {
        observerBox?.boxedObserver = nil
    }

}

public enum ObservationEvent<Value> {
    case Next(Value)
    case Error(ErrorType, Value)

    public var value: Value {
        switch self {
        case .Next(let value):
            return value
        case .Error(_, let value):
            return value
        }
    }
    
    public var error: ErrorType? {
        switch self {
        case .Next(_):
            return nil
        case .Error(let error, _):
            return error
        }
    }

    public init(change: Value, error: ErrorType?) {
        switch (change, error) {
        case (_, .Some(let error)):
            self = .Error(error, change)
        case _:
            self = .Next(change)
        }
    }
}