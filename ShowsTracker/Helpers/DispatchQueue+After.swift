//
//  DispatchQueue+After.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.05.2022.
//

import Foundation

func after(timeout: TimeInterval, action: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: action)
}
