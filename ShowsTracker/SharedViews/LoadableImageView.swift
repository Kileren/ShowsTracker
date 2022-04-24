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
    
    // MARK: - Dependencies
    
    @Injected var imageService: IImageService
    
    // MARK: - State
    
    private let path: String
    private let width: Int
    
    @State var image: Image?
    
    // MARK: - Lifecycle
    
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
