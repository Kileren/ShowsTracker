//
//  STAnimation.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 25.08.2022.
//

import Foundation
import SwiftUI

func withAnimation(_ animation: STAnimation, animateCompletion: Bool, action: () -> Void, completion: @escaping () -> Void) {
    withAnimation(animation.nativeAnimation, action)
    after(timeout: animation.duration) {
        if animateCompletion {
            withAnimation(animation.nativeAnimation) {
                completion()
            }
        } else {
            completion()
        }
    }
}

enum STAnimation {
    case linear(duration: TimeInterval)
    case easeIn(duration: TimeInterval)
    case easeOut(duration: TimeInterval)
    case easeInOut(duration: TimeInterval)
    
    var duration: TimeInterval {
        switch self {
        case .linear(let duration), .easeIn(let duration), .easeOut(let duration), .easeInOut(let duration):
            return duration
        }
    }
    
    var nativeAnimation: Animation {
        switch self {
        case .linear(let duration):
            return .linear(duration: duration)
        case .easeIn(let duration):
            return .easeIn(duration: duration)
        case .easeOut(let duration):
            return .easeOut(duration: duration)
        case .easeInOut(let duration):
            return .easeInOut(duration: duration)
        }
    }
}
