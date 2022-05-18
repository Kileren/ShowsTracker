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
    
    @InjectedObject var appState: AppState
    @Injected var interactor: ShowDetailsViewInteractor
    
    @State private var model: Model = Model()
    @State private var detailsShown: Bool = false
    
    @AnimatedState(
        value: false,
        animation: .easeInOut(duration: 0.25)
    ) private var episodeDetailsShown: Bool
    @State private var episodeDetails = ""
    
    var body: some View {
        GeometryReader { geometry in
            if model.isLoaded {
                ZStack(alignment: .top) {
                    blurBackground(geometry: geometry)
                    overlayView(geometry: geometry)
                    
                    VStack(spacing: 0) {
                        imageView(geometry: geometry)
                        spacer(height: 12)
                        mainInfoView
                    }
                }
            } else {
                ShowDetailsSkeletonView()
            }
        }
        .onAppear { interactor.viewAppeared() }
        .onReceive(modelUpdates) { self.model = $0 }
        .sheet(isPresented: $detailsShown) { ShowDetailsView() }
        .overlay {
            if episodeDetailsShown {
                episodeDetailsView
            }
        }
    }
    
    func overlayView(geometry: GeometryProxy) -> some View {
        Rectangle()
            .cornerRadius(DesignConst.normalCornerRadius,
                          corners: [.topLeft, .topRight])
            .foregroundColor(.white100)
            .ignoresSafeArea(edges: .bottom)
            .padding(.top, geometry.size.width * 0.42 + 8)
    }
    
    func imageView(geometry: GeometryProxy) -> some View {
        LoadableImageView(path: model.posterPath, width: 500)
            .frame(width: geometry.size.width * 0.3,
                   height: geometry.size.width * 0.45)
            .cornerRadius(DesignConst.normalCornerRadius)
            .padding(.top, 40)
    }
    
    var mainInfoView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text(model.name)
                        .font(.medium28)
                        .foregroundColor(.text100)
                    Text(model.broadcastYears)
                        .font(.regular15)
                        .foregroundColor(.text60)
                }
                Spacer()
            }
            spacer(height: 16)
            HStack {
                Spacer()
                ratingView
                Spacer()
                statusView
                Spacer()
                likeView
                Spacer()
            }
            spacer(height: 24)
            Group {
                infoTabs
                spacer(height: 16)
                
                switch model.selectedInfoTab {
                case .episodes where model.episodesInfo.numberOfSeasons > 0: episodesInfo
                case .episodes:
                    Rectangle().foregroundColor(.clear)
                case .details:
                    detailsInfo
                case .similar where !model.similarShowsInfo.isLoaded:
                    Text("Loading")
                case .similar:
                    GeometryReader { geometry in
                        ScrollView(showsIndicators: false) {
                            similarInfo(geometry: geometry)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    var ratingView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.yellowSoft)
                Text(model.vote)
                    .font(.medium17Rounded)
                    .foregroundColor(.yellowSoft)
            }
            Text(model.voteCount)
                .font(.medium13)
                .foregroundColor(.text40)
        }
    }
    
    var statusView: some View {
        VStack(spacing: 4) {
            Text(model.inProduction ? "Продолжается" : "Закончен")
                .font(.medium15)
                .foregroundColor(model.inProduction ? .greenHard : .redSoft)
            Text("Статус")
                .font(.medium13)
                .foregroundColor(.text40)
        }
    }
    
    var likeView: some View {
        Button {
            interactor.didTapLikeButton()
        } label: {
            Image(systemName: model.isLiked ? "heart.fill" : "heart")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.bay)
        }
    }
    
    func blurBackground(geometry: GeometryProxy) -> some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {
            backgroundImage(geometry: geometry)
            backgroundImageGradient(geometry: geometry)
        })
        .background(
            Color.backgroundLight.edgesIgnoringSafeArea(.all)
        )
    }
    
    func backgroundImage(geometry: GeometryProxy) -> some View {
        LoadableImageView(path: model.posterPath, width: 500)
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
    
    var infoTabs: some View {
        let tabs: [Model.InfoTab] = [.episodes, .details, .similar]
        return HStack(alignment: .top, spacing: 20) {
            ForEach(tabs, id: \.self) { tab in
                infoTab(for: tab)
                    .fixedSize(horizontal: true, vertical: false)
            }
            Spacer()
        }
        .frame(height: 32)
    }
    
    func infoTab(for tab: Model.InfoTab) -> some View {
        Button {
            if model.selectedInfoTab != tab {
                interactor.didChangeInfoTab(to: tab)
            }
            if tab == .similar, !model.similarShowsInfo.isLoaded {
                interactor.loadSimilarShows()
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(tab.rawValue)
                    .font(.medium20)
                    .foregroundColor(model.selectedInfoTab == tab ? .bay : .text60)
                
                if model.selectedInfoTab == tab {
                    RoundedRectangle(cornerRadius: 1)
                        .size(width: 32, height: 2)
                        .foregroundColor(.bay)
                }
            }
        }
    }
    
    var episodesInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("Сезон:")
                    .font(.regular17)
                    .foregroundColor(.text60)
                
                ForEach(1...model.episodesInfo.numberOfSeasons, id: \.self) { season in
                    Button {
                        interactor.didSelectSeason(season)
                    } label: {
                        Text("\(season)")
                            .font(.regular17)
                            .foregroundColor(model.episodesInfo.selectedSeason == season ? .bay : .text60)
                    }
                }
            }
            
            ScrollView(showsIndicators: false) {
                HStack {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(model.episodesInfo.episodesPerSeasons[model.episodesInfo.selectedSeason - 1], id: \.self) {
                            episodeInfo(episode: $0)
                        }
                    }
                    Spacer()
                }
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
            episodeDetails = episode.overview
            episodeDetailsShown = true
        }
    }
    
    var detailsInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            tagsView
            VStack(alignment: .leading, spacing: 8) {
                Text("Описание")
                    .font(.semibold17)
                    .foregroundColor(.text100)
                ScrollView(.vertical, showsIndicators: false) {
                    Text(model.detailsInfo.overview)
                        .font(.regular17)
                        .foregroundColor(.text100)
                }
            }
        }
    }
    
    var tagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 26) {
                ForEach(model.detailsInfo.tags, id: \.self) {
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
        let gridWidth = (geometry.size.width - 2 * spacing) / 3
        return LazyVGrid(
            columns: [
                GridItem(.fixed(gridWidth), spacing: spacing, alignment: .topLeading),
                GridItem(.fixed(gridWidth), spacing: spacing, alignment: .topLeading),
                GridItem(.fixed(gridWidth), spacing: spacing, alignment: .topLeading)
            ],
            alignment: .leading,
            spacing: 16,
            pinnedViews: []) {
                ForEach(model.similarShowsInfo.models, id: \.self) { model in
                    ShowView(model: model) { showID in
                        appState.routing.value.showDetails.showID = showID
                        detailsShown = true
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
                Text("Описание")
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
    
    func spacer(height: CGFloat) -> some View {
        Rectangle()
            .frame(height: height)
            .foregroundColor(.clear)
    }
}

// MARK: - State Updates

extension ShowDetailsView {
    
    var modelUpdates: AnyPublisher<Model, Never> {
        let showID = interactor.showID == 0 ? appState.routing.value.showDetails.showID : interactor.showID
        if appState.info[\.showDetails[showID]] == nil {
            appState.info[\.showDetails[showID]] = .init()
        }
        return appState.info.updates(for: \.showDetails[showID])
    }
}

// MARK: - Routing

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
        var inProduction = true
        var isLiked = true
        var selectedInfoTab: InfoTab = .episodes
        var detailsInfo = DetailsInfo()
        var episodesInfo = EpisodesInfo()
        var similarShowsInfo = SimilarShowsInfo()
        
        enum InfoTab: String {
            case episodes
            case details
            case similar
            
            var rawValue: String {
                switch self {
                case .episodes: return "Эпизоды"
                case .details: return "Детали"
                case .similar: return "Похожее"
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
        Resolver.registerPreview()
        Resolver.registerViewPreview()
        
        return ShowDetailsView()
    }
}

#if DEBUG
fileprivate extension Resolver {
    static func registerViewPreview() {
        register { ShowDetailsViewInteractor() }
    }
}
#endif
