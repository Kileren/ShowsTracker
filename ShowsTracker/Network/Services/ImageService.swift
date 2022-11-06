//
//  ImageService.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 23.04.2022.
//

import Foundation
import Moya
import UIKit

protocol IImageService {
    func loadImage(path: String) async throws -> UIImage
    func cachedImage(for path: String) -> UIImage?
}

final class ImageService {
    
    private let provider = MoyaProvider<ImageTarget>(stubClosure: { _ in isPreview ? .delayed(seconds: 0) : .never })
    
    private var cache: [String: UIImage] = [:]
}

extension ImageService: IImageService {
    
    func loadImage(path: String) async throws -> UIImage {
        #if DEBUG
        if isPreview { return UIImage(named: "TheWitcher")! }
        #endif
        
        if let image = cache[path] {
            return image
        }
        
        guard !path.isEmpty else { return UIImage(named: "noImage")! }
        
        let result = await provider.request(target: .image(path: path, width: 500))
        
        switch result {
        case .success(let response):
            if let image = await image(from: response.data) {
                await cacheImage(image, for: path)
//                Logger.log(imageResponse: response)
                return image
            }
            Logger.log(warning: "Couldn't parse image", response: response)
            return UIImage(named: "noImage")!
        case .failure(let error):
            Logger.log(error: error)
            throw error
        }
    }
    
    func cachedImage(for path: String) -> UIImage? {
        cache[path]
    }
    
    @MainActor
    func cacheImage(_ image: UIImage, for path: String) {
        cache[path] = image
    }
}

// MARK: - Helpers

private extension ImageService {
    @MainActor
    func image(from data: Data) async -> UIImage? {
        UIImage(data: data)
    }
}
