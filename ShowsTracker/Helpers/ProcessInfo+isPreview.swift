//
//  ProcessInfo+isPreview.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 24.04.2022.
//

import Foundation

var isPreview: Bool {
    #if DEBUG
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    #else
    return false
    #endif
}
