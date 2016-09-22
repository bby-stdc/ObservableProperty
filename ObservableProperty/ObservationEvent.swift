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

    public var error: Error? {
        return event.error
    }

    public func unobserve() {
        observerBox?.boxedObserver = nil
    }

}

public enum ObservationEvent<Value> {
    case initial(Error?, Value)
    case next(Error?, Value)

    public var value: Value {
        switch self {
        case .next(_, let value):
            return value
        case .initial(_, let value):
            return value
        }
    }
    
    public var error: Error? {
        switch self {
        case .next(let error, _):
            return error
        case .initial(let error, _):
            return error
        }
    }

}
