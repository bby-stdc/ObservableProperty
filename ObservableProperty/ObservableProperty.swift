//
//  ObservableProperty.swift
//
//  Created by Jed Lewison on 2/21/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation
import SwiftSynchronized

public final class ObservableProperty<Value: Equatable> {

    public init(value: Value?, error: ErrorType? = nil) {
        _value = value
        _error = error
    }

    public func setValue(newValue: Value?, error newErrorValue: ErrorType?) {
        guard value != newValue || newErrorValue != nil || error != nil else { return }
        value = newValue
        error = newErrorValue
        notifyAll( Observation(value: newValue, error: newErrorValue, isFinal: false) )
    }

    public func setValue(newValue: Value?) {
        guard value != newValue else { return }
        value = newValue
        notifyAll( Observation(value: newValue, error: error, isFinal: false) )
    }

    public func setError(newErrorValue: ErrorType?) {
        guard newErrorValue != nil || error != nil else { return }
        error = newErrorValue
        notifyAll( Observation(value: value, error: newErrorValue, isFinal: false) )
    }

    public private(set) var value: Value? {
        get { return lock.performAndWait(_value) }
        set { lock.performAndWait(_value = newValue) }
    }

    public private(set) var error: ErrorType? {
        get { return lock.performAndWait(_error) }
        set { lock.performAndWait(_error = newValue) }
    }

    public func removeObserver(observer: AnyObject) {
        observationQueue.performOnQueue {
            self.observers = self.observers.filter { $0.boxedObserver !== observer }
        }
    }

    public func addObserver(observer: AnyObject, closure: (Observation<Value>) -> ()) {
        let initialObservation = Observation(value: value, error: error, isFinal: false)
        let boxedObserver = WeakObserverBox(boxedObserver: observer, closure: closure)
        observationQueue.performOnQueue {
            self.observers.append(boxedObserver)
            boxedObserver.notify(initialObservation)
        }
    }

    public func makeFinal() {
        notifyAll( Observation(value: value, error: error, isFinal: true) )
        value = nil
        error = nil
    }

    private var _value: Value?
    private var _error: ErrorType?
    private let lock = NSRecursiveLock()
    private var observers: [WeakObserverBox<Value>] = []
    private let observationQueue: NSOperationQueue = .mainQueue()
    private func notifyAll(observationInstance: Observation<Value>) {
        observationQueue.performOnQueue {
            self.observers.forEach { $0.notify(observationInstance) }
            
            switch observationInstance {
            case .Final:
                // Remove all observers
                self.observers = []
            case .None, .Some, .Error:
                // Remove deallocated observers
                self.observers = self.observers.filter { $0.boxedObserver != nil }
            }
        }
    }

}

private class WeakObserverBox<Value> {
    init(boxedObserver: AnyObject?, closure: (Observation<Value>) -> ()) {
        self.boxedObserver = boxedObserver
        self.closure = closure
    }
    weak var boxedObserver: AnyObject?
    let closure: (Observation<Value>) -> ()
    func notify(instance: Observation<Value>) {
        guard let _ = boxedObserver else { return }
        closure(instance)
    }
}

private extension NSOperationQueue {
    func performOnQueue(action: () -> ()) {
        if self == NSOperationQueue.currentQueue() {
            action()
        } else {
            addOperationWithBlock(action)
        }
    }
}