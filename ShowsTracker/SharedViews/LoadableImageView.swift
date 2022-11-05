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
    
    private var isImageLoaded: Binding<Bool>?
    @State private var image: Image?
    
    // MARK: - Lifecycle
    
    init(path: String, isImageLoaded: Binding<Bool>? = nil) {
        self.path = path
        self.isImageLoaded = isImageLoaded
    }
    
    // MARK: - UI
    
    var body: some View {
        if let image = self.image {
            image
                .resizable()
                .scaledToFill()
        } else {
            Rectangle()
                .foregroundColor(Color(light: .separators, dark: .backgroundDarkEl1))
                .frame(minHeight: 150)
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
                let loadedImage = try await imageService.loadImage(path: path)
                image = Image(uiImage: loadedImage)
                isImageLoaded?.wrappedValue = true
            } catch {
                Logger.log(message: "Image not loaded and not handled")
            }
        }
    }
}

struct LoadableImageView_Previews: PreviewProvider {
    static var previews: some View {
        return LoadableImageView(path: "")
    }
}
