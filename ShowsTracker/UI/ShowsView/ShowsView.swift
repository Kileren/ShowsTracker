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
    
    // MARK: - View
    
    var body: some View {
        GeometryReader { geometry in
            if viewModel.model.isUserShowsLoaded {
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .top) {
                        blurBackground(geometry: geometry)
                        
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
        let content = viewModel.model.userShows.enumerated().map {
            WatchingShowView(
                image: $0.element.image,
                index: $0.offset,
                showId: $0.element.id,
                sheetNavigator: sheetNavigator)
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
            tapAction: { _ in }
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
            
            STButton(
                title: Strings.add,
                style: .small(width: .fit),
                geometry: geometry) {
                    sheetNavigator.sheetDestination = .showsList
                }
                .padding(.bottom, 24)
        }
    }
    
    @ViewBuilder
    func pageDotsView(geometry: GeometryProxy) -> some View {
        PageDotsView(numberOfPages: viewModel.model.userShows.count,
                     currentIndex: index)
            .frame(width: geometry.size.width, height: 12, alignment: .center)
    }
    
    func backgroundImage(geometry: GeometryProxy) -> some View {
        let index = max(min(Int(scrollProgress.rounded()), viewModel.model.userShows.count - 1), 0)
        let image = viewModel.model.userShows[index].image
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

fileprivate struct WatchingShowView: View, Identifiable, Indexable {
    var id = UUID()
    let image: Image
    var index: Int
    var showId: Int
    
    @ObservedObject var sheetNavigator: SheetNavigator
    
    var body: some View {
        image
            .resizable()
            .cornerRadius(DesignConst.normalCornerRadius)
            .onTapGesture {
                sheetNavigator.sheetDestination = .showDetails(showID: showId)
            }
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
    }
    
    func sheetView() -> AnyView {
        switch sheetDestination {
        case .none:
            return AnyView(Text(""))
        case .showDetails(let showID):
            return AnyView(ShowDetailsView(showID: showID))
        case .showsList:
            return AnyView(ShowsListView())
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
