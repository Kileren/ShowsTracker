//
//  UpdatesViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 06.05.2023.
//

import Foundation
import Resolver
import SwiftUI

final class UpdatesViewModel: ObservableObject {
    
    @Injected private var coreDataStorage: ICoreDataStorage
    @Injected private var tvService: ITVService
    @Injected private var imageService: IImageService
    
    @Published var model = UpdatesModel()
    
    @AppSettings<LastUpdatesCheckKey> private var lastUpdatesCheck
    
    func onAppear() async {
        let showsIDs = await getShowsIDs()
        let rawShows = await getDetails(showsIDs: showsIDs)
        let shows = filterShowsByLastAirDate(rawShows)
        let mainInfo = await loadSeasonsDetails(for: shows)
            .map { show, season in (show, season, getEpisodesFromSeasonByAirDate(season: season)) }
            .filter { _, _, episodes in !episodes.isEmpty }
        let images = await loadImages(for: mainInfo.map { $0.0 })
        let loadedData: [LoadedData] = mainInfo.compactMap { show, season, episodes in
            let image = images[show.id ?? 0] ?? Image("")
            return LoadedData(show: show, image: image, seasonDetails: season, episodes: episodes)
        }
        
        if !loadedData.isEmpty {
            let model = buildModel(from: loadedData)
            await setup(loadedModels: model)
        } else {
            await setUpdatesNotFoundState()
        }
        setLastUpdatesCheck()
    }
}

// MARK: - Setup

private extension UpdatesViewModel {
    @MainActor
    func setup(loadedModels: [UpdatedShowsView.Model]) {
        model.state = .updated(models: loadedModels)
    }
    
    @MainActor
    func setUpdatesNotFoundState() {
        var lastCheck: String {
            if let lastUpdatesCheck {
                return STDateFormatter.format(lastUpdatesCheck, format: .mid)
            }
            return ""
        }
        model.state = .updatesNotFound(lastCheck: lastCheck)
    }
    
    func setLastUpdatesCheck() {
        lastUpdatesCheck = Date()
    }
}

// MARK: - Private API

private extension UpdatesViewModel {
    
    func getShowsIDs() async -> [Int] {
        guard let shows = coreDataStorage.get(objectsOfType: Shows.self).first else { return [] }
        return (shows.likedShows + shows.archivedShows).map { $0.id }
    }
    
    func getDetails(showsIDs ids: [Int]) async -> [DetailedShow] {
        await withTaskGroup(of: DetailedShow?.self) { taskGroup in
            ids.forEach { id in
                taskGroup.addTask(priority: .userInitiated) {
                    try? await self.tvService.getDetails(for: id)
                }
            }
            var details: [DetailedShow] = []
            for await result in taskGroup.compactMap({ $0 }) {
                details.append(result)
            }
            return details
        }
    }
    
    func filterShowsByLastAirDate(_ details: [DetailedShow]) -> [DetailedShow] {
        guard let lastUpdatesCheck = lastUpdatesCheck else { return details}
        
        return details.filter { show in
            guard let lastAirDate = show.lastAirDate,
                  let date = STDateFormatter.date(from: lastAirDate, format: .airDate) else { return true }
            return date > lastUpdatesCheck
        }
    }
    
    func loadSeasonsDetails(for details: [DetailedShow]) async -> [(DetailedShow, SeasonDetails)] {
        await withTaskGroup(of: (DetailedShow, SeasonDetails)?.self) { taskGroup in
            details.forEach { detailedShow in
                guard let showID = detailedShow.id,
                      let seasons = detailedShow.seasons else { return }
                let sortedSeasons = seasons.sorted { ($0.seasonNumber ?? 0) > ($1.seasonNumber ?? 0) }
                guard let season = sortedSeasons.first,
                      let seasonNumber = season.seasonNumber else { return }
                
                taskGroup.addTask {
                    if let seasonDetails = try? await self.tvService.getSeasonDetails(for: showID, season: seasonNumber) {
                        return (detailedShow, seasonDetails)
                    } else {
                        return nil
                    }
                }
            }
            var details: [(DetailedShow, SeasonDetails)] = []
            for await result in taskGroup.compactMap({ $0 }) {
                details.append(result)
            }
            return details
        }
    }
    
    func getEpisodesFromSeasonByAirDate(season: SeasonDetails) -> [SeasonDetails.Episode] {
        guard let lastUpdatesCheck = lastUpdatesCheck,
              let episodes = season.episodes else { return season.episodes ?? [] }
        
        return episodes
            .compactMap { episode -> (SeasonDetails.Episode, Date)? in
                guard let airDate = episode.airDate,
                      let date = STDateFormatter.date(from: airDate, format: .airDate) else { return nil }
                
                return (episode, date)
            }
            .filter { _, airDate in airDate > lastUpdatesCheck && airDate < Date() }
            .map { $0.0 }
    }
    
    func loadImages(for shows: [DetailedShow]) async -> [Int: Image] {
        guard !shows.isEmpty else { return [:] }
        return await withTaskGroup(of: (show: DetailedShow, image: Image).self) { taskGroup in
            shows.forEach { show in
                taskGroup.addTask(priority: .userInitiated) {
                    if let path = show.posterPath, let uiImage = try? await self.imageService.loadImage(path: path) {
                        return (show, Image(uiImage: uiImage))
                    } else {
                        return (show, Image("Icons/EmptyList"))
                    }
                }
            }
            var result: [Int: Image] = [:]
            for await info in taskGroup {
                result[info.show.id ?? 0] = info.image
            }
            return result
        }
    }

    func buildModel(from info: [LoadedData]) -> [UpdatedShowsView.Model] {
        let seasonInfo: (SeasonDetails) -> String? = { [weak self] seasonDetails in
            guard let self = self,
                  let lastUpdatesCheck = self.lastUpdatesCheck,
                  let seasonAirDateStr = seasonDetails.airDate,
                  let airDate = STDateFormatter.date(from: seasonAirDateStr, format: .airDate) else { return nil }
            
            if airDate > lastUpdatesCheck {
                return seasonDetails.name
            }
            return nil
        }
        
        return info.map { info -> UpdatedShowsView.Model in
            let id = info.show.id ?? 0
            let season = seasonInfo(info.seasonDetails)
            let episodes = info.episodes.map { $0.name ?? $0.episodeNumber?.description ?? "" }
            return UpdatedShowsView.Model(
                image: info.image,
                id: id,
                changes: TappableCardView.Model(
                    id: id,
                    image: info.image,
                    title: info.show.name ?? "",
                    season: season,
                    episodes: episodes
                )
            )
        }
    }
    
    struct LoadedData {
        let show: DetailedShow
        let image: Image
        let seasonDetails: SeasonDetails
        let episodes: [SeasonDetails.Episode]
    }
}

private extension Array where Element == UpdatesViewModel.LoadedData {
    mutating func sorted() -> [Element] {
        sorted(by: { lhs, rhs in
            guard let lhsAirDateStr = lhs.show.lastAirDate,
                  let rhsAirDateStr = rhs.show.lastAirDate,
                  let lhsAirDate = STDateFormatter.date(from: lhsAirDateStr, format: .airDate),
                  let rhsAirDate = STDateFormatter.date(from: rhsAirDateStr, format: .airDate) else { return false }
            return lhsAirDate > rhsAirDate
        })
    }
}
