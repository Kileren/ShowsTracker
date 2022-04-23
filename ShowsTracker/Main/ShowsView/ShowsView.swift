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
    @InjectedObject var interactor: ShowsViewInteractor
    @Injected var imageLoader: ImageLoader
    
    // MARK: - State
    
    @State private var index: Int = 0
    @State private var scrollProgress: CGFloat = 0
    
    @State private var detailsScreenIsPresented: Bool = false
    
    // MARK: - View
    
    var body: some View {
        GeometryReader { geometry in
            if interactor.isCurrentLoaded {
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .top) {
                        blurBackground(geometry: geometry)
                        
                        VStack(spacing: 32) {
                            if !appState.shows.isEmpty {
                                currentShows(geometry: geometry)
                                pageDotsView(geometry: geometry)
                            } else {
                                emptyShowsViews(geometry: geometry)
                            }
                            
                            if interactor.isPopularLoaded {
                                popular(geometry: geometry)
                            } else {
                                skeletonForPopular(geometry: geometry)
                            }
                        }
                    }
                }
            } else {
                skeletonLoader(geometry: geometry)
            }
        }
        .background(Color.backgroundLight)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            interactor.viewAppeared()
        }
        .sheet(isPresented: $detailsScreenIsPresented) {
            ShowDetailsView()
        }
    }
    
    func skeletonLoader(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            skeletonBackground(geometry: geometry)
            
            VStack(spacing: 32) {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(.separators)
                    .frame(width: geometry.size.width * 0.6,
                           height: geometry.size.width * 0.9)
                    .padding(.top, .topCurrentShowsOffset)
                
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(.separators)
                    .frame(width: 72, height: 12)
                
                skeletonForPopular(geometry: geometry)
            }
            .redacted(reason: .shimmer)
        }
    }
    
    func skeletonBackground(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top, content: {
            LinearGradient(gradient: .skeletonBackground,
                           startPoint: .top,
                           endPoint: .bottom)
                .frame(width: geometry.size.width,
                       height: geometry.size.width * 1.45,
                       alignment: .top)
                .ignoresSafeArea(edges: .top)
            
            backgroundImageGradient(geometry: geometry)
        })
        .background(
            Color.backgroundLight.edgesIgnoringSafeArea(.all)
        )
    }
    
    func skeletonForPopular(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            RoundedRectangle(cornerRadius: 17)
                .frame(width: 160, height: 34)
                .foregroundColor(.separators)
            
            popularShows(geometry: geometry, content: { width, height in
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: DesignConst.smallCornerRadius)
                        .foregroundColor(.separators)
                        .frame(width: width, height: height)
                }
            })
        }
        .padding(.horizontal, 24)
    }
    
    func blurBackground(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top, content: {
            if !appState.shows.isEmpty {
                backgroundImage(geometry: geometry)
            }
            backgroundImageGradient(geometry: geometry)
        })
        .background(
            Color.backgroundLight.edgesIgnoringSafeArea(.all)
        )
    }
    
    func currentShows(geometry: GeometryProxy) -> some View {
        let content = appState.shows.enumerated().map {
            WatchingShowView(
                image: interactor.imagesForShow[$0.element.id ?? 0] ?? Image(""),
                index: $0.offset,
                showId: $0.element.id ?? 0,
                detailsScreenIsPresented: $detailsScreenIsPresented)
        }
        
        return PagingScrollView(
            content: content,
            spacing: 16,
            changeIndexClosure: { index in
                withAnimation {
                    self.index = index
                }
                scrollProgress = CGFloat(index)
            },
            changeProgressClosure: { scrollProgress = $0 },
            tapAction: { _ in
                detailsScreenIsPresented = true
            }
        )
        .frame(width: geometry.size.width * 0.6,
               height: geometry.size.width * 0.9)
        .padding(.top, .topCurrentShowsOffset)
    }
    
    private func emptyShowsViews(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .cornerRadius(DesignConst.normalCornerRadius)
                .frame(width: geometry.size.width * 0.6,
                       height: geometry.size.width * 0.9)
                .padding(.top, .topCurrentShowsOffset)
                .foregroundColor(.white100)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 4, y: 4)
            
            VStack(spacing: 12) {
                Images.emptyList
                    .resizable()
                    .frame(width: geometry.size.width * 0.35,
                       height: geometry.size.width * 0.35)
                
                Text(Strings.noTrackingShows)
                    .font(.regular15)
                    .foregroundColor(.text100)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 55 + geometry.size.width * 0.15)
            
//            ZStack {
//                RoundedRectangle(cornerRadius: 15)
//                    .frame(width: geometry.size.width * 0.4,
//                           height: 30)
//                    .foregroundColor(.bay)
//
//                Text(Strings.add)
//                    .font(.regular15)
//                    .foregroundColor(.white100)
//            }
//            .padding(.bottom, 24)
            
            STButton(title: Strings.add,
                     style: .small(width: .fit),
                     geometry: geometry) {
                print("Add button tapped")
            }
                .padding(.bottom, 24)
        }
    }
    
    @ViewBuilder
    func pageDotsView(geometry: GeometryProxy) -> some View {
        if appState.shows.count > 1 {
            PageDotsView(numberOfPages: appState.shows.count,
                         currentIndex: index)
                .frame(width: geometry.size.width, height: 12, alignment: .center)
        } else {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 0, height: 0)
        }
    }
    
    func backgroundImage(geometry: GeometryProxy) -> some View {
        let index = max(min(Int(scrollProgress.rounded()), appState.shows.count - 1), 0)
        let show = appState.shows[index]
        let image = imageLoader.cachedImage(ofType: .poster, from: show)?.wrapInImage() ?? Image("")
        let opacity = 1 - abs(scrollProgress - CGFloat(index)) * 1.25
        
        return image
            .resizable()
            .frame(width: geometry.size.width,
                   height: geometry.size.width * 1.335,
                   alignment: .top)
            .opacity(Double(opacity))
            .ignoresSafeArea(edges: .top)
            .blur(radius: 15)
            .scaleEffect(CGSize(width: 1.05, height: 1.05))
    }
    
    func backgroundImageGradient(geometry: GeometryProxy) -> some View {
        Rectangle()
            .frame(width: geometry.size.width,
                   height: geometry.size.width * 1.45,
                   alignment: .top)
            .foregroundColor(.clear)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.backgroundLight, Color.backgroundLight.opacity(0)]),
                    startPoint: .bottom,
                    endPoint: .top))
            .ignoresSafeArea(edges: .top)
    }
    
    func popular(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(Strings.popular)
                    .font(.medium28)
                    .foregroundColor(.text100)
                Spacer()
                Text(Strings.more)
                    .font(.medium13)
                    .foregroundColor(.bay)
            }
            
            popularShows(geometry: geometry, content: { width, height in
                ForEach(appState.popularShows, id: \.id) { show in
                    showView(show: show)
                        .frame(width: width, height: height)
                        .onTapGesture {
                            appState.detailedShowId = show.id
                            detailsScreenIsPresented = true
                        }
                }
            })
        }
        .padding(.horizontal, 24)
    }
    
    func popularShows<Content: View>(
        geometry: GeometryProxy,
        content: (_ width: CGFloat, _ height: CGFloat) -> Content) -> some View {
        
        let showWidth = (geometry.size.width - 88) / 3
        let showHeight = showWidth * (28 / 19)
        let columns: [GridItem] = [
            GridItem(.fixed(showWidth), spacing: 20, alignment: .leading),
            GridItem(.fixed(showWidth), spacing: 20, alignment: .leading),
            GridItem(.fixed(showWidth), spacing: 20, alignment: .leading)
        ]
        
        return LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: 16,
            pinnedViews: [],
            content: {
                content(showWidth, showHeight)
            })
    }
    
    func showView(show: PlainShow) -> some View {
        LoadableImageView(path: .typed(type: .poster, from: show))
            .cornerRadius(DesignConst.smallCornerRadius)
    }
}

fileprivate struct WatchingShowView: View, Identifiable, Indexable {
    var id = UUID()
    let image: Image
    var index: Int
    var showId: Int
    
    @Binding var detailsScreenIsPresented: Bool
    
    @InjectedObject var appState: AppState
    
    var body: some View {
        image
            .resizable()
            .cornerRadius(DesignConst.normalCornerRadius)
            .onTapGesture {
                appState.detailedShowId = showId
                detailsScreenIsPresented = true
            }
    }
}

fileprivate extension CGFloat {
    static let topCurrentShowsOffset: CGFloat = 80
}

// MARK: - Preview

struct ShowsView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerPreview()
        Resolver.registerViewPreview()
        
        let view = ShowsView()
        view.interactor.isCurrentLoaded = true
        view.interactor.isPopularLoaded = true
        return view
//            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//            .previewDisplayName("iPhone SE (2nd generation)")
    }
}

#if DEBUG
fileprivate extension Resolver {
    static func registerViewPreview() {
        register { ImageLoader() }
        register { ShowsViewInteractor(appState: resolve(), imageLoader: resolve()) }
    }
}
#endif

extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)

                NavigationLink(
                    destination: view
                        .navigationBarTitle("")
                        .navigationBarHidden(true),
                    isActive: binding
                ) {
                    EmptyView()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
