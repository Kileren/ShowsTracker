//
//  ShowDetailsViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 25.07.2022.
//

import SwiftUI
import Resolver

final class ShowDetailsViewModel: ObservableObject {
    
    @Published var model: ShowDetailsView.Model = .init()
    
    @Injected var tvService: ITVService
    @Injected var coreDataStorage: ICoreDataStorage
    @Injected var imageService: IImageService
    
    private var showID: Int = 0
    
    func viewAppeared(withShowID showID: Int) {
        self.showID = showID
        
        Task {
            do {
                let show = try await tvService.getDetails(for: showID)
                let episodesInfo = await getEpisodesInfo(for: show)
                let shows = coreDataStorage.get(objectsOfType: PlainShow.self)
                let isLiked = shows.contains(where: { $0.id == showID })
                let model = ShowDetailsView.Model(
                    isLoaded: true,
                    posterPath: show.posterPath ?? "",
                    name: show.name ?? "",
                    broadcastYears: show.broadcastYears,
                    vote: show.vote,
                    voteCount: show.voteCount,
                    status: show.status?.modelStatus ?? .ongoing,
                    isLiked: isLiked,
                    detailsInfo: .init(
                        tags: show.genres?.compactMap { $0.name } ?? [],
                        overview: show.overview ?? ""),
                    episodesInfo: .init(
                        numberOfSeasons: show.numberOfSeasons ?? 0,
                        selectedSeason: min(1, show.numberOfSeasons ?? 0),
                        episodesPerSeasons: episodesInfo)
                )
                await set(model: model)
            } catch {
                Logger.log(warning: "Detailed show not loaded and not handled")
            }
        }
    }
    
    @MainActor
    func set(model: ShowDetailsView.Model) {
        self.model = model
    }
    
    func didTapLikeButton() {
        if model.isLiked {
            coreDataStorage.remove(objectOfType: PlainShow.self, id: showID)
            model.isLiked = false
        } else {
            if let show = tvService.cachedShow(for: showID) {
                coreDataStorage.save(object: show)
            }
            model.isLiked = true
        }
    }
    
    func didChangeInfoTab(to tab: ShowDetailsView.Model.InfoTab) {
        model.selectedInfoTab = tab
    }
    
    func didSelectSeason(_ season: Int) {
        model.episodesInfo.selectedSeason = season
    }
    
    func loadSimilarShows() {
        Task {
            do {
                let similarShows = try await tvService.getSimilar(for: showID)
                let similarShowsViewModels = similarShows
                    .map {
                        ShowView.Model(
                            id: $0.id,
                            posterPath: $0.posterPath ?? "",
                            name: $0.name ?? "",
                            accessory: .vote(STNumberFormatter.format($0.vote ?? 0, format: .vote))
                        )
                    }
                await set(similarShows: similarShowsViewModels)
            } catch {
                Logger.log(warning: "Similar show not loaded and not handled", error: error)
            }
        }
    }
}

private extension ShowDetailsViewModel {
    func getEpisodesInfo(for show: DetailedShow) async -> [[ShowDetailsView.Model.EpisodesInfo.Episode]] {
        var seasonsDetails: [SeasonDetails] = []
        guard let seasonsCount = show.seasons?.count, seasonsCount > 0 else { return [] }
        for season in 1...seasonsCount {
            do {
                let details = try await tvService.getSeasonDetails(for: show.id ?? showID, season: season)
                seasonsDetails.append(details)
            } catch {
                Logger.log(error: error)
            }
        }
        return seasonsDetails.compactMap { seasonDetails in
            seasonDetails.episodes?.compactMap { episode in
                ShowDetailsView.Model.EpisodesInfo.Episode(
                    episodeNumber: episode.episodeNumber ?? 0,
                    name: episode.name ?? "",
                    date: STDateFormatter.format(
                        episode.airDate ?? "",
                        format: .full),
                    overview: episode.overview ?? "")
            }
        }
    }
    
    @MainActor
    func set(similarShows: [ShowView.Model]) {
        model.similarShowsInfo = .init(isLoaded: true, models: similarShows)
    }
}

private extension DetailedShow.Status {
    var modelStatus: ShowDetailsView.Model.Status {
        switch self {
        case .ongoing: return .ongoing
        case .ended: return .ended
        case .inProduction: return .inProduction
        case .planned: return .planned
        case .unknown: return .ongoing
        }
    }
}
