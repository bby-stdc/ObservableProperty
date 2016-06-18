//
//  ObservableProperty.swift
//
//  Created by Jed Lewison on 2/21/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

public final class ObservableProperty<Value> {

    public typealias ObservationClosure = (Observation<Value>) -> ()

    public init(value: Value, error: ErrorProtocol? = nil, observationQueue: OperationQueue = .main(), assertSafeAcess: Bool = false) {
        _value = value
        _assertSafeAccess = assertSafeAcess
        _error = error
        _observationQueue = observationQueue
    }

    private let _assertSafeAccess: Bool

    public func set(error: ErrorProtocol?) {
        _observationQueue.performOnQueue {
            // Make sure we're either setting or clearing an error
            guard error != nil || self.error != nil else { return }
            self.error = error
            self.notifyAll( .next(error, self.value) )
        }
    }

    public private(set) var value: Value {
        get { return _performWithQueueWarning(_value) }
        set { _value = newValue }
    }

    public private(set) var error: ErrorProtocol? {
        get { return _performWithQueueWarning(_error) }
        set { _error = newValue }
    }

    public func remove(_ observer: AnyObject) {
        _observationQueue.performOnQueue {
            self.observers = self.observers.filter { $0.boxedObserver !== observer }
        }
    }

    public func add(_ observer: AnyObject, observeCurrentValue: Bool = true, closure: ObservationClosure) {
        _observationQueue.performOnQueue {
            let boxedObserver = WeakObserverBox(boxedObserver: observer, closure: closure)
            self.observers.append(boxedObserver)
            if observeCurrentValue {
                boxedObserver.notify( .initial(self.error, self.value) )
            }
        }
    }

    private func _performWithQueueWarning<ReturnType>( _ getter: @autoclosure () -> ReturnType) -> ReturnType {
        if _assertSafeAccess {
            assert(_observationQueue == OperationQueue.current(), "WARNING: \(self) accessed from \(OperationQueue.current()) instead of observationQueue: \(_observationQueue)")
        }
        return getter()
    }

    private var _value: Value
    private var _error: ErrorProtocol?

    private var observers: [WeakObserverBox<Value>] = []
    private let _observationQueue: OperationQueue

}

extension ObservableProperty {

    public func set(value newValue: Value, error newErrorValue: ErrorProtocol?) {
        _observationQueue.performOnQueue { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.value = newValue
            strongSelf.error = newErrorValue
            strongSelf.notifyAll( .next(newErrorValue, newValue) )
        }
    }

    public func set(value newValue: Value) {
        set(value: newValue, error: nil)
    }

    private func notifyAll(_ observationInstance: ObservationEvent<Value>) {
        observers.forEach { $0.notify(observationInstance) }
        observers = observers.filter { $0.boxedObserver != nil }
    }

}

extension ObservableProperty where Value: Equatable {

    public func set(value newValue: Value, error newErrorValue: ErrorProtocol?) {
        _observationQueue.performOnQueue { [weak self] in
            guard self?.value != newValue || newErrorValue != nil || self?.error != nil else { return }
            self?.value = newValue
            self?.error = newErrorValue
            self?.notifyAll( .next(newErrorValue, newValue) )
        }
    }

    public func set(value newValue: Value) {
        set(value: newValue, error: nil)
    }

    private func notifyAll(_ observationInstance: ObservationEvent<Value>) {
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

    func notify(_ instance: ObservationEvent<Value>) {
        guard let _ = boxedObserver else { return }
        closure( Observation(event: instance, observerBox: self) )
    }

}

private extension OperationQueue {

    func performOnQueue(_ action: () -> ()) {
        if self == OperationQueue.current() {
            action()
        } else {
            addOperation(action)
        }
    }
}
