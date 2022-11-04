//
//  Array+Extensions.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 04.11.2022.
//

import Foundation

extension Array {
    func safeObject(at index: Int) -> Element? {
        if (count - 1) >= index {
            return self[index]
        }
        return nil
    }
}
