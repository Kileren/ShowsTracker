//
//  ShowsView.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import SwiftUI

struct ShowsView: View {
    @State var appState = AppState()
    
    @State private var index: Int = 0
    @State private var scrollProgress: CGFloat = 0
    
    private var timerTimes = 0
    
    var body: some View {
        ZStack {
            blurBackground
            currentShows
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
        let content = appState.shows.map { WatchingShowView(image: $0.image) }
        return GeometryReader { geometry in
            PagingScrollView(
                content: content,
                spacing: 32,
                changeIndexClosure: {
                    scrollProgress = CGFloat($0)
                },
                changeProgressClosure: { scrollProgress = $0 }
            )
            .frame(width: geometry.size.width * 0.6,
                   height: geometry.size.width * 0.9)
            .padding(.leading, geometry.size.width * 0.2)
            .padding(.top, 80)
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
        let opacity = 1 - abs(scrollProgress - CGFloat(index)) * 2
        
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

struct ShowsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowsView()
    }
}

fileprivate struct WatchingShowView: View, Identifiable, Equatable {
    var id = UUID()
    let image: Image
    
    var body: some View {
        image
            .resizable()
            .cornerRadius(16)
    }
}
