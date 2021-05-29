//
//  Data+Image.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 09.04.2021.
//

import SwiftUI

extension Data {
    var image: Image {
        if let uiImage = UIImage(data: self) {
            return Image(uiImage: uiImage)
        }
        return Image("")
    }
}

extension Optional where Wrapped == Data {
    var image: Image {
        if let data = self {
            return data.image
        }
        return Image("")
    }
}
