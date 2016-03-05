//
//  Observation.swift
//  ObservableProperty
//
//  Created by Jed Lewison on 2/28/16.
//  Copyright © 2016 Jed Lewison. All rights reserved.
//

import Foundation

public enum ObservationEvent<Value> {
    case Change(Value)
    case Error(ErrorType, Value)

    public var value: Value {
        switch self {
        case .Change(let value):
            return value
        case .Error(_, let value):
            return value
        }
    }
    
    public var error: ErrorType? {
        switch self {
        case .Change(_):
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
            self = .Change(change)
        }
    }
}