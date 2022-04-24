//
//  EnvironmentValues+Preview.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 27.01.2022.
//

import SwiftUI

public extension EnvironmentValues {
    var isPreview: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
}
