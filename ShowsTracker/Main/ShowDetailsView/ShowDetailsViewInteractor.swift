//
//  ShowDetailsViewInteractor.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 30.05.2021.
//

import SwiftUI
import Resolver

final class ShowDetailsViewInteractor {
    
    @InjectedObject var appState: AppState
    @Injected var tvService: ITVService
    
    private(set) var showID: Int = 0
    
    deinit {
        appState.service.value.shownDetailsIDs.remove(showID)
    }
    
    func viewAppeared() {
        showID = appState.routing[\.showDetails.showID]
        appState.service.value.shownDetailsIDs.insert(showID)
        
        Task {
            do {
                let show = try await tvService.getDetails(for: showID)
                let episodesInfo = await getEpisodesInfo(for: show)
                let model = ShowDetailsView.Model(
                    isLoaded: true,
                    posterPath: show.posterPath ?? "",
                    name: show.name ?? "",
                    broadcastYears: show.broadcastYears,
                    vote: show.vote,
                    voteCount: show.voteCount,
                    inProduction: show.inProduction ?? true,
                    isLiked: true,
                    detailsInfo: .init(
                        tags: show.genres?.compactMap { $0.name } ?? [],
                        overview: show.overview ?? ""),
                    episodesInfo: .init(
                        numberOfSeasons: show.numberOfSeasons ?? 0,
                        selectedSeason: min(1, show.numberOfSeasons ?? 0),
                        episodesPerSeasons: episodesInfo)
                )
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.appState.info[\.showDetails[self.showID]] = model
                }
            } catch {
                Logger.log(warning: "Detailed show not loaded and not handled")
            }
        }
    }
    
    func didTapLikeButton() {
        appState.info.value.showDetails[showID]?.isLiked.toggle()
    }
    
    func didChangeInfoTab(to tab: ShowDetailsView.Model.InfoTab) {
        appState.info.value.showDetails[showID]?.selectedInfoTab = tab
    }
    
    func didSelectSeason(_ season: Int) {
        appState.info.value.showDetails[showID]?.episodesInfo.selectedSeason = season
    }
    
    func loadSimilarShows() {
        Task {
            do {
                let similarShows = try await tvService.getSimilar(for: showID)
                let similarShowsViewModels = similarShows
                    .filter { !appState.service.value.shownDetailsIDs.contains($0.id) }
                    .map {
                        SimilarShowView.Model(
                            id: $0.id,
                            posterPath: $0.posterPath ?? "",
                            name: $0.name ?? "",
                            vote: STNumberFormatter.format($0.vote ?? 0, format: .vote))
                    }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.appState.info.value.showDetails[self.showID]?.similarShowsInfo = .init(
                        isLoaded: true,
                        models: similarShowsViewModels)
                }
            } catch {
                Logger.log(warning: "Similar show not loaded and not handled", error: error)
            }
        }
    }
}

private extension ShowDetailsViewInteractor {
    
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
}
