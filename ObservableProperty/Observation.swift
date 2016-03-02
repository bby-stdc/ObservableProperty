//
//  Observation.swift
//  ObservableProperty
//
//  Created by Jed Lewison on 2/28/16.
//  Copyright © 2016 Jed Lewison. All rights reserved.
//

import Foundation

public enum Observation<Value> {
    case None
    case Some(Value)
    case Error(ErrorType, Value?)
    case Final(Value?, ErrorType?)

    public var isFinal: Bool {
        switch self {
        case .Final:
            return true
        case .None, .Some, .Error:
            return false
        }
    }

    public var value: Value? {
        switch self {
        case .Some(let value):
            return value
        case .Error(_, let value):
            return value
        case .Final(let value, _):
            return value
        case .None:
            return nil
        }
    }
    
    public var error: ErrorType? {
        switch self {
        case .Some(_), .None:
            return nil
        case .Error(let error, _):
            return error
        case .Final(_, let error):
            return error
        }
    }

    public init(value: Value?, error: ErrorType?, isFinal: Bool) {
        switch (isFinal, value, error) {
        case (true, _, _):
            self = .Final(value, error)
        case (false, _, .Some(let error)):
            self = .Error(error, value)
        case (false, .Some(let value), _):
            self = .Some(value)
        case (false, nil, nil), _:
            self = .None
        }

        if let error = error {
            self = .Error(error, value)
        } else if let value = value {
            self = .Some(value)
        } else {
            self = .None
        }
    }
}