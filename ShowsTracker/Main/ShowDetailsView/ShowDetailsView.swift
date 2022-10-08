//
//  ShowDetailsView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 30.05.2021.
//

import Combine
import SwiftUI
import Resolver

struct ShowDetailsView: View {
    
    // MARK: - Dependencies
    
    @InjectedObject private var viewModel: ShowDetailsViewModel
    @ObservedObject private var sheetNavigator: SheetNavigator = SheetNavigator()
    
    // MARK: - State
    
    @AnimatedState(
        value: false,
        animation: .easeInOut(duration: 0.25)
    ) private var episodeDetailsShown: Bool
    @State private var episodeDetails = ""
    @State private var episodeDetailsErrorState: FloatingErrorView.State = .hidden
    
    var showID: Int
    
    @State private var contentOffset: CGFloat = 0
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            if viewModel.model.isLoaded {
                ZStack(alignment: .top) {
                    blurBackground(geometry: geometry)
                    
                    TrackableScrollView(showIndicators: false, contentOffset: $contentOffset) { geometry in
                        ZStack(alignment: .top) {
                            overlayView(geometry: geometry)
                            
                            VStack(spacing: 12) {
                                Color.clear
                                    .frame(height: imageWidthHeight(for: geometry).height)
                                    .padding(.top, 40)
                                mainInfoView(geometry: geometry)
                                Spacer()
                            }
                            .frame(minHeight: geometry.size.height)
                            
                            blurBackground(geometry: geometry)
                                .foregroundColor(.yellowSoft)
                                .mask {
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: Const.minSpacingFromTopToOverlay)
                                    Spacer()
                                }
                                .offset(y: contentOffset)
                                .allowsHitTesting(false)
                            
                            imageView(geometry: geometry)
                        }
                    }
                    .readSize { size in
                        print("------------------------")
                        print(size)
                        print(geometry.size.height)
                    }
                }
            } else {
                ShowDetailsSkeletonView()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear { viewModel.viewAppeared(withShowID: showID) }
        .sheet(isPresented: $sheetNavigator.showSheet) {
            sheetNavigator.sheetView()
        }
        .overlay {
            if episodeDetailsShown {
                episodeDetailsView
            }
            
            FloatingErrorView(
                icon: Image(systemName: "xmark.circle.fill"),
                text: Strings.noDescription,
                state: $episodeDetailsErrorState
            )
        }
    }
    
    func overlayView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            spacer(height: spacingFromTopToOverlay(geometry: geometry))
            Rectangle()
                .cornerRadius(DesignConst.normalCornerRadius,
                              corners: [.topLeft, .topRight])
                .foregroundColor(.backgroundLight)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: offsetForOverlay(geometry: geometry))
        }
    }
    
    func imageView(geometry: GeometryProxy) -> some View {
        let (width, height) = imageWidthHeight(for: geometry)
        return LoadableImageView(path: viewModel.model.posterPath)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(DesignConst.normalCornerRadius)
            .padding(.top, 40)
            .scaleEffect(scaleForImage(geometry: geometry), anchor: .bottom)
            .offset(y: offsetForImage(geometry: geometry))
    }
}

// MARK: - Background

private extension ShowDetailsView {
    func blurBackground(geometry: GeometryProxy) -> some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {
            backgroundImage(geometry: geometry)
            backgroundImageGradient(geometry: geometry)
        })
        .background(
            Color.backgroundLight.edgesIgnoringSafeArea(.all)
        )
        .mask {
            // Fixes scroll background on devices without safe area
            VStack {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.8)
                Spacer()
            }
        }
    }
    
    func backgroundImage(geometry: GeometryProxy) -> some View {
        LoadableImageView(path: viewModel.model.posterPath)
            .frame(width: geometry.size.width,
                   height: geometry.size.width * 1.335,
                   alignment: .top)
            .ignoresSafeArea(edges: .top)
            .blur(radius: 15)
            .scaleEffect(1.1, anchor: .center)
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
}

// MARK: - Main Info

private extension ShowDetailsView {
    
    func mainInfoView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            infoView(geometry: geometry)
            spacer(height: 24)
            Group {
                infoTabs(geometry: geometry)
                spacer(height: 16)
                
                switch viewModel.model.selectedInfoTab {
                case .episodes where viewModel.model.episodesInfo.numberOfSeasons > 0:
                    episodesInfo
                case .episodes:
                    Rectangle().foregroundColor(.clear)
                case .details:
                    detailsInfo
                case .similar where !viewModel.model.similarShowsInfo.isLoaded:
                    Text("Loading")
                case .similar:
                    similarInfo(geometry: geometry)
                }
            }
            .padding(.horizontal, Const.horizontalPadding)
        }
        .padding(.bottom, 24)
    }
    
    func infoView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            titleView
                .opacity(opacityForTitle(geometry: geometry))
            statusView
                .opacity(opacityForStatus(geometry: geometry))
        }
    }
    
    var titleView: some View {
        VStack(spacing: 4) {
            Text(viewModel.model.name)
                .font(.medium28)
                .foregroundColor(.text100)
            Text(viewModel.model.broadcastYears)
                .font(.regular15)
                .foregroundColor(.text60)
        }
        .frame(height: 56)
    }
    
    var statusView: some View {
        HStack {
            Spacer()
            ratingView
            Spacer()
            ongoingStatusView
            Spacer()
            likeView
            Spacer()
        }
    }
    
    var ratingView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.yellowSoft)
                Text(viewModel.model.vote)
                    .font(.medium17Rounded)
                    .foregroundColor(.yellowSoft)
            }
            Text(viewModel.model.voteCount)
                .font(.medium13)
                .foregroundColor(.text40)
        }
    }
    
    var ongoingStatusView: some View {
        var args: (String, Color) {
            switch viewModel.model.status {
            case .ongoing: return (Strings.ongoing, .greenHard)
            case .ended: return (Strings.ended, .redSoft)
            case .inProduction, .planned: return (Strings.inProduction, .yellowSoft)
            }
        }
        let (name, color) = args
        
        return VStack(spacing: 4) {
            Text(name)
                .font(.medium15)
                .foregroundColor(color)
            Text(Strings.status)
                .font(.medium13)
                .foregroundColor(.text40)
        }
    }
    
    var likeView: some View {
        Button {
            viewModel.didTapLikeButton()
        } label: {
            Image(systemName: viewModel.model.isLiked ? "heart.fill" : "heart")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.bay)
        }
    }
    
    func infoTabs(geometry: GeometryProxy) -> some View {
        let tabs: [Model.InfoTab] = [.episodes, .details, .similar]
        return HStack(alignment: .top, spacing: 20) {
            ForEach(tabs, id: \.self) { tab in
                infoTab(for: tab)
                    .fixedSize(horizontal: true, vertical: false)
            }
            Spacer()
        }
        .frame(height: Const.infoTabsHeight)
        .background {
            if offsetForInfoTabs(geometry: geometry) > 0 {
                Rectangle()
                    .foregroundColor(.white)
                    .frame(height: 1000)
                    .padding(.bottom, 1000 - Const.infoTabsHeight - 8)
            }
        }
        .offset(y: offsetForInfoTabs(geometry: geometry))
        .zIndex(1)
    }
    
    func infoTab(for tab: Model.InfoTab) -> some View {
        Button {
            viewModel.didSelectInfoTab(to: tab)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(tab.rawValue)
                    .font(.medium20)
                    .foregroundColor(viewModel.model.selectedInfoTab == tab ? .bay : .text60)
                
                if viewModel.model.selectedInfoTab == tab {
                    RoundedRectangle(cornerRadius: 1)
                        .size(width: 32, height: 2)
                        .foregroundColor(.bay)
                }
            }
        }
    }
}

// MARK: - Episode Info

private extension ShowDetailsView {
    var episodesInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(Strings.season)
                    .font(.regular17)
                    .foregroundColor(.text60)
                
                ForEach(1...viewModel.model.episodesInfo.numberOfSeasons, id: \.self) { season in
                    Button {
                        viewModel.didSelectSeason(season)
                    } label: {
                        Text("\(season)")
                            .font(.regular17)
                            .foregroundColor(viewModel.model.episodesInfo.selectedSeason == season ? .bay : .text60)
                    }
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.model.episodesInfo.episodesPerSeasons[viewModel.model.episodesInfo.selectedSeason - 1], id: \.self) {
                        episodeInfo(episode: $0)
                    }
                }
                Spacer()
            }
        }
    }
    
    func episodeInfo(episode: Model.EpisodesInfo.Episode) -> some View {
        HStack(spacing: 24) {
            Text("\(episode.episodeNumber)")
                .font(.medium32)
                .foregroundColor(.text40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(episode.name)
                    .font(.medium17)
                    .foregroundColor(.text100)
                    .lineLimit(1)
                Text(episode.date)
                    .font(.regular13)
                    .foregroundColor(.text40)
            }
        }
        .onTapGesture {
            if !episode.overview.isEmpty {
                episodeDetails = episode.overview
                episodeDetailsShown = true
            } else {
                if episodeDetailsErrorState == .shown {
                    episodeDetailsErrorState = .hidden
                }
                withAnimation(FloatingErrorView.State.animation) {
                    episodeDetailsErrorState = .shown
                }
            }
        }
    }
    
    var detailsInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            tagsView
            VStack(alignment: .leading, spacing: 8) {
                Text(Strings.description)
                    .font(.semibold17)
                    .foregroundColor(.text100)
                ScrollView(.vertical, showsIndicators: false) {
                    Text(viewModel.model.detailsInfo.overview)
                        .font(.regular17)
                        .foregroundColor(.text100)
                }
            }
        }
    }
    
    var tagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 26) {
                ForEach(viewModel.model.detailsInfo.tags, id: \.self) {
                    tagView(for: $0)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
        }
    }
    
    func tagView(for tag: String) -> some View {
        Text(tag)
            .font(.regular13)
            .foregroundColor(.text100)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.separators)
                    .padding(.vertical, -5)
                    .padding(.horizontal, -8)
            }
            .frame(height: 24)
    }
    
    func similarInfo(geometry: GeometryProxy) -> some View {
        let spacing: CGFloat = 14
        let itemWidth = (geometry.size.width - 2 * spacing - 2 * Const.horizontalPadding) / 3
        return LazyVGrid(
            columns: [
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .topLeading),
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .topLeading),
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .topLeading)
            ],
            alignment: .leading,
            spacing: 16,
            pinnedViews: []) {
                ForEach(viewModel.model.similarShowsInfo.models, id: \.self) { model in
                    ShowView(model: model, itemWidth: itemWidth) { showID in
                        sheetNavigator.sheetDestination = .showDetails(showID: showID)
                    }
                }
            }
    }
    
    var episodeDetailsView: some View {
        ZStack {
            Color.backgroundDark.opacity(0.7)
                .onTapGesture {
                    episodeDetailsShown = false
                }
            
            VStack(spacing: 16) {
                Text(Strings.description)
                    .font(.semibold17)
                    .foregroundColor(.text100)
                
                Text(episodeDetails)
                    .font(.regular17)
                    .foregroundColor(.text100)
                    .padding(.horizontal, 32)
            }
            .background(
                RoundedRectangle(cornerRadius: DesignConst.normalCornerRadius)
                    .padding(.horizontal, 16)
                    .padding(.vertical, -16)
                    .foregroundColor(.white100)
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Calculations & Helpers

private extension ShowDetailsView {
    func offsetForOverlay(geometry: GeometryProxy) -> CGFloat {
        let maxSpacingFromTopToOverlay = spacingFromTopToOverlay(geometry: geometry)
        if (maxSpacingFromTopToOverlay - Const.minSpacingFromTopToOverlay - contentOffset) > 0 {
            return 0
        } else {
            return contentOffset - (maxSpacingFromTopToOverlay - Const.minSpacingFromTopToOverlay)
        }
    }
    
    func scaleForImage(geometry: GeometryProxy) -> CGFloat {
        min(1, max(0.5, 1 - contentOffset / spacingFromTopToOverlay(geometry: geometry)))
    }
    
    func offsetForImage(geometry: GeometryProxy) -> CGFloat {
        let imageHeight = imageWidthHeight(for: geometry).height
        let scale = scaleForImage(geometry: geometry)
        let maxOffset = spacingFromTopToOverlay(geometry: geometry) - imageHeight * scale
        return contentOffset <= maxOffset ? 0 : contentOffset - maxOffset
    }
    
    func spacingFromTopToOverlay(geometry: GeometryProxy) -> CGFloat {
        geometry.size.width * 0.42 + 8
    }
    
    func imageWidthHeight(for geometry: GeometryProxy) -> (width: CGFloat, height: CGFloat) {
        (geometry.size.width * 0.3, geometry.size.width * 0.45)
    }
    
    func opacityForTitle(geometry: GeometryProxy) -> CGFloat {
        let offsetForOverlay = offsetForOverlay(geometry: geometry)
        if offsetForOverlay.isZero {
            return 1
        } else {
            return min(1, 1 - offsetForOverlay / 10)
        }
    }
    
    func opacityForStatus(geometry: GeometryProxy) -> CGFloat {
        let offsetForOverlay = offsetForOverlay(geometry: geometry)
        let distanceToTitle = Const.spacingBeetwenTitleAndStatus + Const.titleHeight
        let offset = offsetForOverlay - distanceToTitle
        if offset <= 0 {
            return 1
        } else {
            return min(1, max(1 - offset / 10, 0))
        }
    }
    
    func offsetForInfoTabs(geometry: GeometryProxy) -> CGFloat {
        let offsetForOverlay = offsetForOverlay(geometry: geometry)
        let distanceToImage = Const.spacingBeetwenTitleAndStatus + Const.spacingBelowInfoTabs + Const.titleHeight + Const.infoTabsHeight
        let offset = offsetForOverlay - distanceToImage
        return max(0, offset)
    }
    
    func spacer(height: CGFloat) -> some View {
        Color.clear.frame(height: height)
    }
}

// MARK: - Constants

private extension ShowDetailsView {
    enum Const {
        static let horizontalPadding: CGFloat = 24
        static let minSpacingFromTopToOverlay: CGFloat = 75
        static let spacingBeetwenTitleAndStatus: CGFloat = 16
        static let spacingBelowInfoTabs: CGFloat = 24
        static let titleHeight: CGFloat = 56
        static let infoTabsHeight: CGFloat = 32
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
    }
    
    func sheetView() -> AnyView {
        switch sheetDestination {
        case .none:
            return AnyView(Text(""))
        case .showDetails(let showID):
            return AnyView(ShowDetailsView(showID: showID))
        }
    }
}

extension ShowDetailsView {
    struct Routing: Equatable {
        var showID: Int = 0
    }
}

// MARK: - Model

extension ShowDetailsView {
    struct Model: Equatable {
        var isLoaded = false
        var posterPath = ""
        var name = ""
        var broadcastYears = ""
        var vote = ""
        var voteCount = ""
        var status: Status = .inProduction
        var isLiked = false
        var selectedInfoTab: InfoTab = .episodes
        var detailsInfo = DetailsInfo()
        var episodesInfo = EpisodesInfo()
        var similarShowsInfo = SimilarShowsInfo()
        
        enum Status {
            case ongoing
            case ended
            case inProduction
            case planned
        }
        
        enum InfoTab: String {
            case episodes
            case details
            case similar
            
            var rawValue: String {
                switch self {
                case .episodes: return Strings.episodes
                case .details: return Strings.details
                case .similar: return Strings.similar
                }
            }
        }
        
        struct DetailsInfo: Equatable {
            var tags: [String] = []
            var overview: String = ""
        }
        
        struct EpisodesInfo: Equatable {
            var numberOfSeasons: Int = 0
            var selectedSeason = 0
            var episodesPerSeasons: [[Episode]] = []
            
            struct Episode: Equatable, Hashable {
                var episodeNumber = 0
                var name = ""
                var date = ""
                var overview = ""
            }
        }
        
        struct SimilarShowsInfo: Equatable {
            var isLoaded = false
            var models: [ShowView.Model] = []
        }
    }
}

struct ShowDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsView(showID: 0)
    }
}
