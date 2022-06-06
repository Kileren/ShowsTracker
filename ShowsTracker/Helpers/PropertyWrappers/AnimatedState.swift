//
//  AnimatedState.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 07.05.2022.
//

import SwiftUI

@propertyWrapper
struct AnimatedState<Value>: DynamicProperty {
    let storage: State<Value>
    let animation: Animation?

    init(value: Value,
         animation: Animation? = nil) {
        self.storage = State<Value>(initialValue: value)
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
        withAnimation(animation) {
            self.storage.wrappedValue = value
        }
    }
}
