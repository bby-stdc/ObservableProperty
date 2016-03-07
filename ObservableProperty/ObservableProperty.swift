//
//  ObservableProperty.swift
//
//  Created by Jed Lewison on 2/21/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

public final class ObservableProperty<Value> {

    public typealias ObservationClosure = (Observation<Value>) -> ()

    public init(value: Value, error: ErrorType? = nil, observationQueue: NSOperationQueue = .mainQueue(), assertSafeAcess: Bool = false) {
        _value = value
        _assertSafeAccess = assertSafeAcess
        _error = error
        _observationQueue = observationQueue
    }

    private let _assertSafeAccess: Bool

    public func setError(newErrorValue: ErrorType?) {
        _observationQueue.performOnQueue {
            guard newErrorValue != nil || self.error != nil else { return }
            self.error = newErrorValue
            self.notifyAll( ObservationEvent(change: self.value, error: newErrorValue) )
        }
    }

    public private(set) var value: Value {
        get { return _performWithQueueWarning(_value) }
        set { _value = newValue }
    }

    public private(set) var error: ErrorType? {
        get { return _performWithQueueWarning(_error) }
        set { _error = newValue }
    }

    public func removeObserver(observer: AnyObject) {
        _observationQueue.performOnQueue {
            self.observers = self.observers.filter { $0.boxedObserver !== observer }
        }
    }

    public func addObserver(observer: AnyObject, closure: ObservationClosure) {
        _observationQueue.performOnQueue {
            let boxedObserver = WeakObserverBox(boxedObserver: observer, closure: closure)
            self.observers.append(boxedObserver)
            boxedObserver.notify( self.observationEventInstance() )
        }
    }

    private func _performWithQueueWarning<ReturnType>(@autoclosure getter: () -> ReturnType) -> ReturnType {
        if _assertSafeAccess {
            assert(_observationQueue == NSOperationQueue.currentQueue(), "WARNING: \(self) accessed from \(NSOperationQueue.currentQueue()) instead of observationQueue: \(_observationQueue)")
        }
        return getter()
    }

    private var _value: Value
    private var _error: ErrorType?

    private var observers: [WeakObserverBox<Value>] = []
    private let _observationQueue: NSOperationQueue

    private func observationEventInstance() -> ObservationEvent<Value> {
        return ObservationEvent(change: value, error: error)
    }

}

extension ObservableProperty {

    public func setValue(newValue: Value, error newErrorValue: ErrorType?) {
        _observationQueue.performOnQueue { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.value = newValue
            strongSelf.error = newErrorValue
            strongSelf.notifyAll( strongSelf.observationEventInstance() )
        }
    }

    public func setValue(newValue: Value) {
        setValue(newValue, error: nil)
    }

    private func notifyAll(observationInstance: ObservationEvent<Value>) {
        observers.forEach { $0.notify(observationInstance) }
        observers = observers.filter { $0.boxedObserver != nil }
    }

}

extension ObservableProperty where Value: Equatable {

    public func setValue(newValue: Value, error newErrorValue: ErrorType?) {
        _observationQueue.performOnQueue { [weak self] in
            guard self?.value != newValue || newErrorValue != nil || self?.error != nil else { return }
            self?.value = newValue
            self?.error = newErrorValue
            self?.notifyAll( ObservationEvent(change: newValue, error: newErrorValue) )
        }
    }

    public func setValue(newValue: Value) {
        setValue(newValue, error: nil)
    }

    private func notifyAll(observationInstance: ObservationEvent<Value>) {
        observers.forEach {
            guard value == observationInstance.value else { return }
            $0.notify(observationInstance)
        }
        observers = observers.filter { $0.boxedObserver != nil }
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