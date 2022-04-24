//
//  ImageServicePreview.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 24.04.2022.
//

#if DEBUG
import Foundation
import UIKit

final class ImageServicePreview: IImageService {
    func loadImage(path: String, width: Int) async throws -> UIImage {
        UIImage(named: "TheWitcher")!
    }
    
    func cachedImage(for path: String) -> UIImage? {
        UIImage(named: "TheWitcher")
    }
}
#endif
