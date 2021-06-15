//
//  UIImage+Extensions.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 15.06.2021.
//

import UIKit
import SwiftUI

extension UIImage {
    func wrapInImage() -> Image {
        Image(uiImage: self)
    }
}
