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
    func loadImage(path: String, width: Int) async throws -> UIImage
    func cachedImage(for path: String) -> UIImage?
}

final class ImageService {
    
    private let provider = MoyaProvider<ImageTarget>(stubClosure: { _ in isPreview ? .immediate : .never })
    
    private var cache: [String: UIImage] = [:]
}

extension ImageService: IImageService {
    
    func loadImage(path: String, width: Int) async throws -> UIImage {
        if let image = cache[path] {
            return image
        }
        
        let result = await provider.request(target: .image(path: path, width: width))
        
        switch result {
        case .success(let response):
            if let image = UIImage(data: response.data) {
                cache[path] = image
                Logger.log(imageResponse: response)
                return image
            }
            Logger.log(warning: "Couldn't parse image", response: response)
            return UIImage(named: "TheMandalorian")!
        case .failure(let error):
            Logger.log(error: error)
            throw error
        }
    }
    
    func cachedImage(for path: String) -> UIImage? {
        cache[path]
    }
}
