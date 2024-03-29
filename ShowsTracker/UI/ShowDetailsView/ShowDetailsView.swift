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
    
    @StateObject private var viewModel = ShowDetailsViewModel()
    @ObservedObject private var sheetNavigator: SheetNavigator = SheetNavigator()
    @Injected private var analyticsService: AnalyticsService
    
    @AppSettings<EpisodesTrackingKey> private var episodesTrackingEnabled
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @AnimatedState(
        value: false,
        animation: .easeInOut(duration: 0.25)
    ) private var episodeDetailsShown: Bool
    @State private var episodeTitle = ""
    @State private var episodeDetails = ""
    @State private var episodeDetailsErrorState: FloatingErrorView.State = .hidden
    @State private var seasonNumberInfoShown: Int? = nil
    @State private var seasonInfoAdditionalYOffset: CGFloat = 0
    
    @AnimatedState(
        value: false,
        animation: .spring(response: 0.65)
    ) private var imageScaled: Bool
    
    @AnimatedState(
        value: .defaultScaledSeasonPoster,
        animation: .easeInOut(duration: 0.25)
    ) private var scaledSeasonPoster: Int
    
    var showID: Int
    
    @State private var contentOffset: CGFloat = 0
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            switch viewModel.model.loading {
            case .done:
                ZStack(alignment: .top) {
                    blurBackground(geometry: geometry)
                    detailsInfoScrollView(geometry: geometry)
                    closeButton
                }
            case .loading:
                ShowDetailsSkeletonView()
            case .error:
                unexpectedErrorView(geometry: geometry)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear { viewModel.viewAppeared(withShowID: showID) }
        .sheet(isPresented: $sheetNavigator.showSheet, content: sheetNavigator.sheetView)
        .blur(radius: episodeDetailsShown ? 5 : 0)
        .confirmationDialog(
            "",
            isPresented: $viewModel.model.removeShowAlertIsShown,
            titleVisibility: .visible,
            actions: confirmationDialogRemoveShowButtons,
            message: { Text(Strings.addToArchiveHint) }
        )
        .confirmationDialog(
            "",
            isPresented: $viewModel.model.archiveShowAlertIsShown,
            actions: confirmationDialogArchiveButtons
        )
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
    
    func confirmationDialogRemoveShowButtons() -> some View {
        Group {
            Button { viewModel.didTapAddToArchiveButton() } label: { Text(Strings.addToArchive) }
            Button(role: .destructive) { viewModel.didTapRemoveButton() } label: { Text(Strings.removeFromFavourites) }
            Button(role: .cancel) { } label: { Text(Strings.cancel) }
        }
    }
    
    func confirmationDialogArchiveButtons() -> some View {
        Group {
            Button { viewModel.didTapLikeButton() } label: { Text(Strings.backToFavourites) }
            Button(role: .destructive) { viewModel.didTapRemoveButton() } label: { Text(Strings.removeFromArchive) }
            Button(role: .cancel) { } label: { Text(Strings.cancel) }
        }
    }
    
    func detailsInfoScrollView(geometry: GeometryProxy) -> some View {
        TrackableScrollView(
            showIndicators: false,
            contentOffset: $contentOffset
        ) { geometry in
            ZStack(alignment: .top) {
                // View which visually contains main info
                overlayView(geometry: geometry)
                    .blur(radius: imageScaled ? 5 : 0)
                
                // Stack with main info
                VStack(spacing: 12) {
                    Color.clear
                        .frame(height: imageWidthHeight(for: geometry).height)
                        .padding(.top, 40)
                    mainInfoView(geometry: geometry)
                    Spacer()
                }
                .frame(minHeight: geometry.size.height)
                .blur(radius: imageScaled ? 5 : 0)
                
                // Blur background
                blurBackground(geometry: geometry)
                    .mask {
                        Rectangle()
                            .frame(width: geometry.size.width, height: Const.minSpacingFromTopToOverlay)
                        Spacer()
                    }
                    .offset(y: contentOffset)
                    .allowsHitTesting(false)
                    .blur(radius: imageScaled ? 5 : 0)
                
                // Background dimmer while image view zoomed
                Color.backgroundDark
                    .opacity(imageScaled ? 0.7 : 0)
                    .onTapGesture { imageScaled = false }
                
                // Serial image
                imageView(geometry: geometry)
            }
        }
        .modifier(DisabledScroll(flag: imageScaled))
    }
    
    func overlayView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            spacer(height: spacingFromTopToOverlay(geometry: geometry))
            Rectangle()
                .cornerRadius(DesignConst.normalCornerRadius,
                              corners: [.topLeft, .topRight])
                .foregroundColor(.dynamic.background)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: offsetForOverlay(geometry: geometry))
        }
    }
    
    func imageView(geometry: GeometryProxy) -> some View {
        let (width, height) = imageWidthHeight(for: geometry)
        let (scale, anchor) = imageScaleParams(for: geometry, width: width)
        let offset: CGFloat = scale > 1
            ? (geometry.size.height - height * scale) / 2 + contentOffset
            : offsetForImage(geometry: geometry) + 40
        
        return LoadableImageView(path: viewModel.model.posterPath)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(DesignConst.normalCornerRadius)
            .scaleEffect(scale, anchor: anchor)
            .offset(y: offset)
            .onTapGesture { imageScaled.toggle() }
    }
    
    var closeButton: some View {
        HStack {
            Button {
                dismiss.callAsFunction()
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.text60)
                    .overlay {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .rotationEffect(.degrees(45))
                            .foregroundColor(.white100)
                    }
                    .frame(width: 32, height: 32)
                    .padding([.leading, .top], 24)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
        }
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
            Color.dynamic.background.edgesIgnoringSafeArea(.all)
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
            .background(backgroundImageGradientLinearGradient)
            .ignoresSafeArea(edges: .top)
    }
    
    var backgroundImageGradientLinearGradient: LinearGradient {
        let colors: [Color] = [
            .dynamic.background,
            .dynamic.background.opacity(0),
        ]
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .bottom,
            endPoint: .top)
    }
}

// MARK: - Main Info

private extension ShowDetailsView {
    
    func mainInfoView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .center, spacing: 0) {
            infoView(geometry: geometry)
            spacer(height: 24)
            Group {
                infoTabs(geometry: geometry)
                spacer(height: 16)
                
                switch viewModel.model.selectedInfoTab {
                case .episodes where viewModel.model.seasonsInfo.count > 0:
                    episodesInfo(geometry: geometry)
                case .episodes:
                    Rectangle().foregroundColor(.clear)
                case .details:
                    detailsInfo
                case .similar:
                    switch viewModel.model.similarShowsInfo.state {
                    case .initial:
                        Text("") // Initial state not shown
                    case .loading:
                        STSpinner()
                    case .loaded(let models) where !models.isEmpty:
                        similarInfo(models: models, geometry: geometry)
                    case .loaded:
                        noSimilarInfo(geometry: geometry)
                    case .error:
                        errorView {
                            viewModel.reloadSimilarShows()
                        }
                        .padding(.top, 24)
                    }
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
                .foregroundColor(.dynamic.text100)
            Text(viewModel.model.broadcastYears)
                .font(.regular15)
                .foregroundColor(.dynamic.text60)
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
            if viewModel.model.isArchived {
                archiveView
            } else {
                likeView
            }
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
                .foregroundColor(.dynamic.text40)
        }
    }
    
    var ongoingStatusView: some View {
        var args: (String, Color) {
            switch viewModel.model.status {
            case .ongoing: return (Strings.ongoing, .greenHard)
            case .ended: return (Strings.ended, .redSoft)
            case .canceled: return (Strings.canceled, .redSoft)
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
                .foregroundColor(.dynamic.text40)
        }
    }
    
    var likeView: some View {
        Button {
            viewModel.didTapLikeButton()
        } label: {
            Image(systemName: viewModel.model.isLiked ? "heart.fill" : "heart")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.dynamic.bay)
        }
    }
    
    var archiveView: some View {
        Button {
            viewModel.didTapArchiveButton()
        } label: {
            Image("Icons/Settings/archive")
                .resizable()
                .frame(width: 32, height: 32)
        }
    }
    
    func infoTabs(geometry: GeometryProxy) -> some View {
        let tabs: [ShowDetailsModel.InfoTab] = [.episodes, .details, .similar]
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
                    .foregroundColor(.dynamic.background)
                    .frame(height: 1000)
                    .padding(.bottom, 1000 - Const.infoTabsHeight - 8)
                    .padding(.horizontal, -8)
            }
        }
        .offset(y: offsetForInfoTabs(geometry: geometry))
        .zIndex(1)
    }
    
    func infoTab(for tab: ShowDetailsModel.InfoTab) -> some View {
        Button {
            viewModel.didSelectInfoTab(to: tab)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(tab.rawValue)
                    .font(.medium20)
                    .foregroundColor(viewModel.model.selectedInfoTab == tab ? .dynamic.bay : .dynamic.text60)
                
                if viewModel.model.selectedInfoTab == tab {
                    RoundedRectangle(cornerRadius: 1)
                        .size(width: 32, height: 2)
                        .foregroundColor(.dynamic.bay)
                }
            }
        }
    }
    
    func unexpectedErrorView(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            Rectangle()
                .cornerRadius(DesignConst.normalCornerRadius,
                              corners: [.topLeft, .topRight])
                .foregroundColor(.dynamic.background)
                .ignoresSafeArea(edges: .bottom)
                .padding(.top, geometry.size.width * 0.42 + 8)
            
            LinearGradient(gradient: .darkBackground, startPoint: .leading, endPoint: .trailing)
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                Rectangle()
                    .cornerRadius(DesignConst.normalCornerRadius,
                                  corners: [.topLeft, .topRight])
                    .foregroundColor(.dynamic.background)
                    .ignoresSafeArea(edges: .bottom)
                    .padding(.top, geometry.size.width * 0.42 + 8)
                errorView {
                    viewModel.viewAppeared(withShowID: showID)
                }
                .padding(.horizontal, Const.horizontalPadding)
            }
        }
    }
}

// MARK: - Episode Info

private extension ShowDetailsView {
    func episodesInfo(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            ForEach(viewModel.model.seasonsInfo, id: \.self) { info in
                seasonInfoView(info: info, geometry: geometry)
            }
        }
    }
    
    func seasonInfoView(info: ShowDetailsModel.SeasonInfo, geometry: GeometryProxy) -> some View {
        let seasonIsSelected = seasonNumberInfoShown == info.seasonNumber
        let posterIsScaled = scaledSeasonPoster == info.seasonNumber
        let defaultPosterWidth: CGFloat = 66
        let defaultPosterHeight: CGFloat = 100
        let scaledPosterWidth = geometry.size.width - 12 * 2 - 24 * 2
        let scaledPosterHeight = (scaledPosterWidth / defaultPosterWidth) * defaultPosterHeight
        var backgroundRectangleHeight: CGFloat {
            if seasonIsSelected {
                let extraHeightForScaledPoster = posterIsScaled ? (scaledPosterHeight - defaultPosterHeight) : 0
                return CGFloat(130 + info.episodes.count * (40 + 16)) + seasonInfoAdditionalYOffset + extraHeightForScaledPoster
            }
            if posterIsScaled {
                return scaledPosterHeight + 12 * 2
            }
            return info.overview.isEmpty ? 92 : 130
        }
        return ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                if !seasonIsSelected {
                    spacer(height: 20)
                }
                
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundColor(Color(light: .separators, dark: .backgroundDarkEl1))
                        .frame(height: backgroundRectangleHeight)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(info.title)
                                .font(.medium17Rounded)
                                .foregroundColor(.dynamic.text100)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            
                            if info.notificationStatus != .none {
                                Button {
                                    viewModel.didTapNotification(seasonInfo: info)
                                } label: {
                                    if info.notificationStatus == .on {
                                        activeNotification
                                    } else if info.notificationStatus == .off {
                                        inactiveNotification
                                    }
                                }
                            }
                        }
                        
                        if !info.overview.isEmpty {
                            Text(info.overview)
                                .font(.regular11)
                                .foregroundColor(.dynamic.text40)
                                .lineLimit(seasonIsSelected ? nil : 4)
                                .readSize { size in
                                    let defaultHeight: CGFloat = 64
                                    seasonInfoAdditionalYOffset = max(size.height - defaultHeight, 0)
                                }
                        }
                        
                        if !seasonIsSelected {
                            Text(Strings.episodes)
                                .font(.regular11)
                                .foregroundColor(.dynamic.bay)
                                .transition(.opacity.combined(with: .offset(y: -20)))
                        }
                    }
                    .padding(.top, 12)
                    .padding(.leading, 90)
                    .padding(.trailing, 16)
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                LoadableImageView(path: info.posterPath)
                    .frame(width: posterIsScaled ? scaledPosterWidth : defaultPosterWidth,
                           height: posterIsScaled ? scaledPosterHeight : defaultPosterHeight)
                    .cornerRadius(12)
                    .padding(.top, seasonIsSelected ? 12 : (posterIsScaled ? 32 : 0))
                    .onTapGesture {
                        if scaledSeasonPoster == info.seasonNumber {
                            scaledSeasonPoster = .defaultScaledSeasonPoster
                        } else {
                            scaledSeasonPoster = info.seasonNumber
                        }
                    }
                
                if seasonIsSelected {
                    VStack(alignment: .leading, spacing: 16) {
                        let maxEpisodeNumberInSeason = info.episodes
                            .max(by: { $0.episodeNumber < $1.episodeNumber })?
                            .episodeNumber ?? 10
                        ForEach(info.episodes, id: \.self) {
                            episodeInfo(
                                episode: $0,
                                seasonNumber: info.seasonNumber,
                                maxEpisodeNumberInSeason: maxEpisodeNumberInSeason)
                        }
                    }
                    .padding(.top, seasonInfoAdditionalYOffset)
                }
            }
            .padding(.leading, 12)
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                if seasonIsSelected {
                    seasonNumberInfoShown = nil
                } else {
                    seasonNumberInfoShown = info.seasonNumber
                }
                scaledSeasonPoster = .defaultScaledSeasonPoster
            }
        }
    }
    
    func episodeInfo(
        episode: ShowDetailsModel.Episode,
        seasonNumber: Int,
        maxEpisodeNumberInSeason: Int
    ) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 24) {            
                Text("\(episode.episodeNumber)")
                    .font(.medium32)
                    .foregroundColor(.dynamic.text40)
                    .frame(width: widthForEpisodeNumber(maxEpisodeNumberInSeason))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(episode.name)
                        .font(.medium17)
                        .foregroundColor(.dynamic.text100)
                        .lineLimit(1)
                    Text(episode.date)
                        .font(.regular13)
                        .foregroundColor(.dynamic.text40)
                }
            }
            .layoutPriority(1)
            
            Rectangle()
                .foregroundColor(Color(light: .separators, dark: .backgroundDarkEl1))
            
            if episodesTrackingEnabled {
                Image("checkmark")
                    .renderingMode(.template)
                    .foregroundColor(
                        episode.isWatched ? .dynamic.bay : .dynamic.text20
                    )
                    .padding(.trailing, 16)
                    .onTapGesture {
                        viewModel.didTapEpisodeWatched(
                            seasonNumber: seasonNumber,
                            episodeNumber: episode.episodeNumber)
                    }
            }
        }
        .frame(height: 40)
        .onTapGesture {
            if !episode.overview.isEmpty {
                episodeTitle = episode.name
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
            
            if viewModel.model.detailsInfo.overview.isEmpty {
                Text(Strings.noShowDescription)
                    .font(.regular17)
                    .foregroundColor(.dynamic.text100)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(Strings.description)
                        .font(.semibold17)
                        .foregroundColor(.dynamic.text100)
                    ScrollView(.vertical, showsIndicators: false) {
                        Text(viewModel.model.detailsInfo.overview)
                            .font(.regular17)
                            .foregroundColor(.dynamic.text100)
                    }
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
            .foregroundColor(.dynamic.text100)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.dynamic.separators)
                    .padding(.vertical, -5)
                    .padding(.horizontal, -8)
            }
            .frame(height: 24)
    }
    
    func similarInfo(models: [ShowView.Model], geometry: GeometryProxy) -> some View {
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
                ForEach(models, id: \.self) { model in
                    ShowView(model: model, itemWidth: itemWidth) { showID in
                        sheetNavigator.sheetDestination = .showDetails(showID: showID)
                        analyticsService.logShowDetailsTapSimilarShow()
                    }
                }
            }
    }
    
    func noSimilarInfo(geometry: GeometryProxy) -> some View {
        VStack(spacing: 8) {
            Text(Strings.noSimilarShows)
                .multilineTextAlignment(.center)
            Image("Icons/EmptyList")
                .renderingMode(.template)
                .resizable()
                .frame(width: geometry.size.width * 0.4,
                       height: geometry.size.width * 0.4)
                .foregroundColor(.dynamic.text100)
        }
        .padding(.top, 16)
    }
    
    func errorView(retryAction: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Text(Strings.errorOccured)
                .font(.regular17)
                .foregroundColor(.text100)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            STButton(title: Strings.retry,
                     style: .medium,
                     action: retryAction)
        }
    }
    
    var episodeDetailsView: some View {
        ZStack {
            Color.backgroundDark.opacity(0.7)
                .onTapGesture { episodeDetailsShown = false }
            
            VStack(spacing: 16) {
                Text(episodeTitle)
                    .font(.semibold17)
                    .multilineTextAlignment(.center)
                Text(episodeDetails)
                    .font(.regular17)
            }
            .foregroundColor(.dynamic.text100)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: DesignConst.normalCornerRadius)
                    .padding(.horizontal, 16)
                    .padding(.vertical, -16)
                    .foregroundColor(.dynamic.backgroundEl1)
            )
        }
        .ignoresSafeArea()
    }
    
    var activeNotification: some View {
        Circle()
            .foregroundColor(Color(light: .dynamic.bay.opacity(0.15),
                                   dark: .dynamic.bay.opacity(0.25)))
            .frame(width: 20, height: 20)
            .overlay {
                Image("Icons/Settings/notificationOn")
                    .resizable()
                    .frame(width: 12, height: 12)
            }
    }
    
    var inactiveNotification: some View {
        Circle()
            .trim()
            .stroke(lineWidth: 1)
            .fill(Color.dynamic.bay)
            .frame(width: 20, height: 20)
            .overlay {
                Image("Icons/Settings/notificationOn")
                    .resizable()
                    .frame(width: 12, height: 12)
            }
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
    
    func imageScaleParams(
        for geometry: GeometryProxy,
        width: CGFloat
    ) -> (scale: CGFloat, anchor: UnitPoint) {
        if imageScaled {
            return ((geometry.size.width - 48) / width, .top)
        } else {
            return (scaleForImage(geometry: geometry), .bottom)
        }
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
    
    func widthForEpisodeNumber(_ episodeNumber: Int) -> CGFloat {
        if episodeNumber < 10 {
            return 21
        } else if episodeNumber < 100 {
            return 42
        } else if episodeNumber < 1000 {
            return 63
        } else {
            return 84
        }
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

struct ShowDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerAllServices()
        return ShowDetailsView(showID: 0)
    }
}

private extension Int {
    static var defaultScaledSeasonPoster: Int = -1
}
