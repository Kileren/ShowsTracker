//
//  ShowsView.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Combine
import SwiftUI
import Resolver

struct ShowsView: View {
    
    // MARK: - Injected
    
    @Injected private var imageService: IImageService
    @InjectedObject private var viewModel: ShowsViewModel
    @ObservedObject private var sheetNavigator = SheetNavigator()
    
    // MARK: - State
    
    @State private var index: Int = 0
    @State private var scrollProgress: CGFloat = 0
    @State private var verticalScrollOffset: CGFloat = 0
    
    // MARK: - View
    
    var body: some View {
        GeometryReader { geometry in
            if viewModel.model.isUserShowsLoaded {
                TrackableScrollView(axis: .vertical, showIndicators: false, contentOffset: $verticalScrollOffset) { _ in
                    ZStack(alignment: .top) {
                        blurBackground(geometry: geometry)
                            .offset(y: verticalScrollOffset < 0 ? verticalScrollOffset : 0)
                        
                        VStack(spacing: 32) {
                            if !viewModel.model.userShows.isEmpty {
                                currentShows(geometry: geometry)
                                if viewModel.model.userShows.count > 1 {
                                    pageDotsView(geometry: geometry)
                                }
                            } else {
                                emptyShowsViews(geometry: geometry)
                            }
                            
                            if viewModel.model.isPopularShowsLoaded {
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
        .onAppear { viewModel.viewAppeared() }
        .sheet(isPresented: $sheetNavigator.showSheet) {
            viewModel.reload()
        } content: {
            sheetNavigator.sheetView()
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
            if !viewModel.model.userShows.isEmpty {
                backgroundImage(geometry: geometry)
            }
            backgroundImageGradient(geometry: geometry)
        })
        .background(
            Color.backgroundLight.edgesIgnoringSafeArea(.all)
        )
        .scaleEffect(1.1, anchor: .center)
    }
    
    func currentShows(geometry: GeometryProxy) -> some View {
        let models = viewModel.model.userShows.enumerated().map {
            ShowsScrollView.Model(image: $0.element.image, index: $0.offset, showID: $0.element.id) { showID in
                sheetNavigator.sheetDestination = .showDetails(showID: showID)
            }
        }
        
        return ShowsScrollView(models: models, currentCardIndex: $index, scrollProgress: $scrollProgress)
            .frame(width: geometry.size.width, height: geometry.size.width * 0.9)
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
            
            STButton(title: Strings.add, style: .small(width: .fit)) {
                sheetNavigator.sheetDestination = .showsList
            }
            .padding(.bottom, 24)
        }
    }
    
    func pageDotsView(geometry: GeometryProxy) -> some View {
        HStack(spacing: 12) {
            STButton(
                title: Strings.all,
                style: .custom(width: 54, height: 24, font: .regular15)) {
                    sheetNavigator.sheetDestination = .likedShows
                }
            PageDotsView(numberOfPages: viewModel.model.userShows.count, currentIndex: index)
                .frame(height: 12, alignment: .center)
        }
        .frame(width: geometry.size.width)
    }
    
    func backgroundImage(geometry: GeometryProxy) -> some View {
        let index: Int
        let opacity: CGFloat
        if scrollProgress > 0.5, (viewModel.model.userShows.count - 1) >= (self.index + 1) {
            index = self.index + 1
            opacity = scrollProgress
        } else {
            index = self.index
            if (viewModel.model.userShows.count - 1) >= (self.index + 1) {
                opacity = 1 - scrollProgress
            } else {
                opacity = 1
            }
        }
        
        let image = viewModel.model.userShows[index].image
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
                Button {
                    sheetNavigator.sheetDestination = .showsList
                } label: {
                    Text(Strings.more)
                        .font(.medium13)
                        .foregroundColor(.bay)
                }
            }
            
            popularShows(geometry: geometry, content: { width, height in
                ForEach(viewModel.model.popularShows, id: \.id) { show in
                    LoadableImageView(path: show.posterPath)
                        .frame(width: width, height: height)
                        .cornerRadius(DesignConst.smallCornerRadius)
                        .onTapGesture {
                            sheetNavigator.sheetDestination = .showDetails(showID: show.id)
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
}

// MARK: - Routing

extension ShowsView {
    struct Routing: Equatable {
        var detailsShown = false
        var showsListShown = false
    }
}

// MARK: - Model

extension ShowsView {
    struct Model: Equatable {
        var isUserShowsLoaded: Bool = false
        var isPopularShowsLoaded: Bool = false
        
        var userShows: [UserShow] = []
        var popularShows: [PopularShow] = []
        
        struct UserShow: Equatable {
            var id: Int = 0
            var image: Image = Image("")
        }
        
        struct PopularShow: Equatable {
            var id: Int = 0
            var posterPath: String = ""
        }
    }
}

// MARK: - Sheet Navigator

private class SheetNavigator: ObservableObject {
    
    @Published var showSheet = false
    var sheetDestination: SheetDestination = .none {
        didSet {
            showSheet = true
        }
    }
    
    enum SheetDestination {
        case none
        case showDetails(showID: Int)
        case showsList
        case likedShows
    }
    
    func sheetView() -> AnyView {
        switch sheetDestination {
        case .none:
            return AnyView(Text(""))
        case .showDetails(let showID):
            return AnyView(ShowDetailsView(showID: showID))
        case .showsList:
            return AnyView(ShowsListView())
        case .likedShows:
            return AnyView(LikedShowsListView())
        }
    }
}

fileprivate extension CGFloat {
    static let topCurrentShowsOffset: CGFloat = 80
}

// MARK: - Preview

struct ShowsView_Previews: PreviewProvider {
    static var previews: some View {
        return ShowsView()
//            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//            .previewDisplayName("iPhone SE (2nd generation)")
    }
}
