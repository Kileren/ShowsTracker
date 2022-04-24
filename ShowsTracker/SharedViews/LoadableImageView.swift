//
//  LoadableImageView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 14.06.2021.
//

import SwiftUI
import Resolver

struct LoadableImageView: View {
    
    // MARK: - Model
    
//    enum Path {
//        case short(String)
//        case full(String)
//        case typed(type: ImageProvidableType, from: ImageProvidable)
//    }
    
    // MARK: - Dependencies
    
//    @Injected var imageLoader: ImageLoader
    @Injected var imageService: IImageService
    
    // MARK: - State
    
//    private let path: Path
    
    private let path: String
    private let width: Int
    
    @State var image: Image?
    
    // MARK: - Lifecycle
    
//    init(path: Path) {
//        self.path = path
//    }
    
    init(path: String, width: Int = 500) {
        self.path = path
        self.width = width
    }
    
    // MARK: - UI
    
    var body: some View {
        if let image = self.image {
            image
                .resizable()
                .scaledToFill()
        } else {
            Rectangle()
                .foregroundColor(.separators)
                .redacted(reason: .shimmer)
                .onAppear {
                    obtainImage()
                }
        }
    }
}

// MARK: - Helpers

private extension LoadableImageView {
    private func obtainImage() {
//        switch path {
//        case .short(let shortPath):
//            image = await imageLoader.obtainImage(byShortPath: shortPath).wrapInImage()
//        case .full(let fullPath):
//            image = await imageLoader.obtainImage(byFullPath: fullPath).wrapInImage()
//        case .typed(let type, let from):
//            image = await imageLoader.obtainImage(ofType: type, from: from).wrapInImage()
//        }
        Task {
            do {
                let loadedImage = try await imageService.loadImage(path: path, width: width)
                image = Image(uiImage: loadedImage)
            } catch {
                Logger.log(message: "Image not loaded and not handled")
            }
        }
    }
}

struct LoadableImageView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerPreview()
        
        return LoadableImageView(path: "")
    }
}
