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
    
    enum Path {
        case short(String)
        case full(String)
        case typed(type: ImageProvidableType, from: ImageProvidable)
    }
    
    // MARK: - Dependencies
    
    @Injected var imageLoader: ImageLoader
    
    // MARK: - State
    
    private let path: Path
    
    @State var image: Image?
    
    // MARK: - Lifecycle
    
    init(path: Path) {
        self.path = path
    }
    
    // MARK: - UI
    
    var body: some View {
        if let image = self.image {
            image
                .resizable()
        } else {
            Rectangle()
                .foregroundColor(.separators)
                .redacted(reason: .shimmer)
                .onAppear {
                    async { await obtainImage() }
                }
        }
    }
}

// MARK: - Helpers

private extension LoadableImageView {
    private func obtainImage() async {
        switch path {
        case .short(let shortPath):
            image = await imageLoader.obtainImage(byShortPath: shortPath).wrapInImage()
        case .full(let fullPath):
            image = await imageLoader.obtainImage(byFullPath: fullPath).wrapInImage()
        case .typed(let type, let from):
            image = await imageLoader.obtainImage(ofType: type, from: from).wrapInImage()
        }
    }
}

struct LoadableImageView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerPreview()
        Resolver.registerViewPreview()
        
        return LoadableImageView(path: .short(""))
    }
}

#if DEBUG
fileprivate extension Resolver {
    static func registerViewPreview() {
        register { ImageLoader() }
    }
}
#endif
