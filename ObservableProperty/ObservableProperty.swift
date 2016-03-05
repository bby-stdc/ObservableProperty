//
//  ObservableProperty.swift
//
//  Created by Jed Lewison on 2/21/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation
import SwiftSynchronized

public final class ObservableProperty<Value> {

    public typealias ObservationClosure = (Observation<Value>) -> ()

    public init(value: Value, error: ErrorType? = nil) {
        _value = value
        _error = error
    }

    public func setError(newErrorValue: ErrorType?) {
        guard newErrorValue != nil || error != nil else { return }
        error = newErrorValue
        notifyAll( ObservationEvent(change: value, error: newErrorValue) )
    }

    public private(set) var value: Value {
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

    public func addObserver(observer: AnyObject, closure: ObservationClosure) {
        let initialObservation = ObservationEvent(change: value, error: error)
        let boxedObserver = WeakObserverBox(boxedObserver: observer, closure: closure)
        observationQueue.performOnQueue {
            self.observers.append(boxedObserver)
            boxedObserver.notify(initialObservation)
        }
    }
    
    private var _value: Value
    private var _error: ErrorType?
    private let lock = NSRecursiveLock()
    private var observers: [WeakObserverBox<Value>] = []
    private let observationQueue: NSOperationQueue = .mainQueue()
    private func notifyAll(observationInstance: ObservationEvent<Value>) {
        observationQueue.performOnQueue {
            self.observers.forEach { $0.notify(observationInstance) }
            self.observers = self.observers.filter { $0.boxedObserver != nil }
        }
    }

}

extension ObservableProperty {

    public func setValue(newValue: Value, error newErrorValue: ErrorType?) {
        value = newValue
        error = newErrorValue
        notifyAll( ObservationEvent(change: newValue, error: newErrorValue) )
    }

    public func setValue(newValue: Value) {
        setValue(newValue, error: nil)
    }
    
}

extension ObservableProperty where Value: Equatable {

    public func setValue(newValue: Value, error newErrorValue: ErrorType?) {
        guard value != newValue || newErrorValue != nil || error != nil else { return }
        value = newValue
        error = newErrorValue
        notifyAll( ObservationEvent(change: newValue, error: newErrorValue) )
    }

    public func setValue(newValue: Value) {
        setValue(newValue, error: nil)
    }

}

final internal class WeakObserverBox<Value> {

    typealias ObservationClosure = (Observation<Value>) -> ()

    init(boxedObserver: AnyObject?, closure: ObservationClosure) {
        self.boxedObserver = boxedObserver
        self.closure = closure
    }
    weak var boxedObserver: AnyObject?
    let closure: ObservationClosure
    func notify(instance: ObservationEvent<Value>) {
        guard let _ = boxedObserver else { return }
        closure( Observation(event: instance, observerBox: self) )
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