//
//  ShowsView.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import SwiftUI
import Resolver

struct ShowsView: View {
    
    // MARK: - Injected
    
    @InjectedObject var appState: AppState
    
    // MARK: - State
    
    @State private var index: Int = 0
    @State private var scrollProgress: CGFloat = 0
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            blurBackground
            currentShows
            pageDotsView
        }
    }
    
    var blurBackground: some View {
        GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {
                backgroundSubview(geometry: geometry)
                backgroudImage(geometry: geometry)
                backgroundImageGradient(geometry: geometry)
            })
        }
    }
    
    var currentShows: some View {
        let content = appState.shows.enumerated().map {
            WatchingShowView(image: $0.element.image, index: $0.offset)
        }
        return GeometryReader { geometry in
            PagingScrollView(
                content: content,
                spacing: 16,
                changeIndexClosure: { index in
                    withAnimation {
                        self.index = index
                    }
                    scrollProgress = CGFloat(index)
                },
                changeProgressClosure: { scrollProgress = $0 }
            )
            .frame(width: geometry.size.width * 0.6,
                   height: geometry.size.width * 0.9)
            .padding(.leading, geometry.size.width * 0.2)
            .padding(.top, 80)
        }
    }
    
    var pageDotsView: some View {
        GeometryReader { geometry in
            PageDotsView(numberOfPages: appState.shows.count,
                         currentIndex: index)
                .frame(width: geometry.size.width, height: 12, alignment: .center)
                .padding(.top, 80 + geometry.size.width * 0.9 + 32)
        }
    }
    
    func backgroundSubview(geometry: GeometryProxy) -> some View {
        Rectangle()
            .frame(width: geometry.size.width,
                   height: geometry.size.width * 1.335 + 100,
                   alignment: .top)
            .foregroundColor(.white)
            .ignoresSafeArea(edges: .top)
    }
    
    func backgroudImage(geometry: GeometryProxy) -> some View {
        let images = appState.shows.map { $0.image }
        let index = max(min(Int(scrollProgress.rounded()), images.count - 1), 0)
        let image = images[Int(index)]
        let opacity = 1 - abs(scrollProgress - CGFloat(index)) * 1.25
        
        return image
            .resizable(resizingMode: .tile)
            .frame(width: geometry.size.width,
                   height: geometry.size.width * 1.335,
                   alignment: .top)
            .opacity(Double(opacity))
            .ignoresSafeArea(edges: .top)
            .blur(radius: 15)
    }
    
    func backgroundImageGradient(geometry: GeometryProxy) -> some View {
        Rectangle()
            .frame(width: geometry.size.width,
                   height: geometry.size.width * 1.335 + 100,
                   alignment: .top)
            .foregroundColor(.clear)
            .background(LinearGradient(gradient: Gradient(colors: [.white, .clear]), startPoint: .bottom, endPoint: .top))
            .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Preview

struct ShowsView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerPreview()
        
        return ShowsView()
//            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//            .previewDisplayName("iPhone SE (2nd generation)")
    }
}

fileprivate struct WatchingShowView: View, Identifiable, Equatable, Indexable {
    var id = UUID()
    let image: Image
    var index: Int
    
    var body: some View {
        image
            .resizable()
            .cornerRadius(16)
    }
}
