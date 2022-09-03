//
//  AnimatedTemporaryState.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 01.09.2022.
//

import SwiftUI

@propertyWrapper
struct AnimatedTemporaryState<Value>: DynamicProperty {
    let storage: State<Value>
    let duration: TimeInterval
    let animation: Animation?

    init(value: Value,
         duration: TimeInterval,
         animation: Animation? = nil) {
        self.storage = State<Value>(initialValue: value)
        self.duration = duration
        self.animation = animation
    }

    public var wrappedValue: Value {
        get {
            storage.wrappedValue
        }
        nonmutating set {
            self.process(newValue)
        }
    }

    public var projectedValue: Binding<Value> {
        storage.projectedValue
    }

    private func process(_ value: Value) {
        let currentValue = self.storage.wrappedValue
        
        withAnimation(animation) {
            self.storage.wrappedValue = value
            after(timeout: duration) {
                withAnimation(animation) {
                    self.storage.wrappedValue = currentValue
                }
            }
        }
    }
}

