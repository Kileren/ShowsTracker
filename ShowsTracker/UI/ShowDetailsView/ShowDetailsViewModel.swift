//
//  ShowDetailsViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 25.07.2022.
//

import SwiftUI
import Resolver

final class ShowDetailsViewModel: ObservableObject {
    
    @Published var model: ShowDetailsModel = .init()
    
    @Injected var tvService: ITVService
    @Injected var coreDataStorage: ICoreDataStorage
    @Injected var imageService: IImageService
    @Injected private var inMemoryStorage: InMemoryStorageProtocol
    @Injected private var notificationsService: NotificationsService
    
    private var showID: Int = 0
    
    func viewAppeared(withShowID showID: Int) {
        self.showID = showID
        
        Task {
            await loadModel()
            await checkForMissedNotifications()
        }
    }
    
    func didTapLikeButton() {
        if model.isLiked {
            model.removeShowAlertIsShown = true
        } else {
            if let show = inMemoryStorage.getCachedShow(id: showID) {
                var shows = self.shows
                shows.archivedShows.removeAll { $0.id == showID }
                shows.likedShows.append(show)
                coreDataStorage.save(object: shows)
            }
            model.isLiked = true
            model.isArchived = false
        }
    }
    
    func didTapAddToArchiveButton() {
        if let show = inMemoryStorage.getCachedShow(id: showID) {
            var shows = self.shows
            shows.likedShows.removeAll { $0.id == showID }
            shows.archivedShows.append(show)
            coreDataStorage.save(object: shows)
        }
        model.isArchived = true
    }
    
    func didTapRemoveButton() {
        var shows = self.shows
        shows.likedShows.removeAll { $0.id == showID }
        shows.archivedShows.removeAll { $0.id == showID }
        coreDataStorage.save(object: shows)
        model.isLiked = false
        model.isArchived = false
    }
    
    func didTapArchiveButton() {
        model.archiveShowAlertIsShown = true
    }
    
    func didSelectInfoTab(to tab: ShowDetailsModel.InfoTab) {
        if model.selectedInfoTab != tab {
            withAnimation(.easeIn) {
                model.selectedInfoTab = tab
            }
        }
        
        if tab == .similar, !model.similarShowsInfo.isLoaded {
            loadSimilarShows()
        }
    }
    
    func didTapNotification(seasonInfo: ShowDetailsModel.SeasonInfo) {
        switch seasonInfo.notificationStatus {
        case .off:
            addNotifications(seasonInfo: seasonInfo)
        case .on:
            removeNotifications(seasonInfo: seasonInfo)
        case .none:
            break
        }
    }
}

private extension ShowDetailsViewModel {
    
    func loadModel() async {
        do {
            let show = try await tvService.getDetails(for: showID)
            let shows = coreDataStorage.get(objectsOfType: Shows.self)
            let likedShows = shows.first?.likedShows ?? []
            let archivedShows = shows.first?.archivedShows ?? []
            let isLiked = likedShows.contains(where: { $0.id == showID })
            let isArchived = archivedShows.contains(where: { $0.id == showID })
            let model = ShowDetailsModel(
                isLoaded: true,
                posterPath: show.posterPath ?? "",
                name: show.name ?? "",
                broadcastYears: show.broadcastYears,
                vote: show.vote,
                voteCount: show.voteCount,
                status: show.status?.modelStatus ?? .ongoing,
                isLiked: isLiked,
                isArchived: isArchived,
                detailsInfo: .init(
                    tags: show.genres?.compactMap { $0.name } ?? [],
                    overview: show.overview ?? ""),
                seasonsInfo: await seasonsInfo(from: show)
            )
            await set(model: model)
        } catch {
            Logger.log(warning: "Detailed show not loaded and not handled")
        }
    }
    
    @MainActor
    func set(model: ShowDetailsModel) {
        self.model = model
    }
    
    @MainActor
    func changeModel(completion: (inout ShowDetailsModel) -> Void) {
        completion(&model)
    }
    
    func seasonsInfo(from show: DetailedShow) async -> [ShowDetailsModel.SeasonInfo] {
        guard let seasons = show.seasons, seasons.count > 0 else { return [] }
        
        var seasonsInfo: [ShowDetailsModel.SeasonInfo] = []
        for season in seasons where season.seasonNumber != nil {
            guard let seasonNumber = season.seasonNumber else { continue }
            
            do {
                let details = try await tvService.getSeasonDetails(for: show.id ?? showID, season: seasonNumber)
                
                var title = details.name ?? "Сезон \(seasonNumber)"
                if let airDate = details.airDate, let releaseYear = STDateFormatter.component(.year, from: airDate, format: .airDate) {
                    title += " (\(releaseYear))"
                }
                let episodes = details.episodes?.compactMap { episode in
                    ShowDetailsModel.Episode(
                        episodeNumber: episode.episodeNumber ?? 0,
                        name: episode.name ?? "",
                        date: STDateFormatter.format(episode.airDate ?? "", format: .full),
                        overview: episode.overview ?? "")
                }
                let seasonInfo = ShowDetailsModel.SeasonInfo(
                    seasonNumber: seasonNumber,
                    posterPath: details.posterPath ?? "",
                    title: title,
                    overview: details.overview ?? "",
                    episodes: episodes ?? [],
                    notificationStatus: await notificationStatus(for: details, seasonNumber: seasonNumber))
                seasonsInfo.append(seasonInfo)
            } catch {
                Logger.log(error: error)
            }
        }
        return seasonsInfo
    }
    
    func notificationStatus(for seasonDetails: SeasonDetails, seasonNumber: Int) async -> ShowDetailsModel.NotificationStatus {
        guard let episodes = seasonDetails.episodes else { return .none }
        let currentDate = Date()
        let dates = episodes
            .compactMap { $0.airDate }
            .compactMap { STDateFormatter.date(from: $0, format: .airDate) }
        
        if dates.filter({ $0 > currentDate }).isEmpty {
            // All episodes have been released already
            return .none
        }
        
        let pendingRequests = await notificationsService.getPendingRequestsIDs()
        if pendingRequests.contains(where: { $0.starts(with: "\(showID).\(seasonNumber)") }) {
            return .on
        } else {
            return .off
        }
    }
    
    func addNotifications(seasonInfo: ShowDetailsModel.SeasonInfo) {
        guard let seasonDetails = inMemoryStorage.getCachedSeasonDetails(showID: showID, seasonNumber: seasonInfo.seasonNumber),
              let show = inMemoryStorage.getCachedShow(id: showID) else { return }
        
        Task {
            if await notificationsService.getStatus() == .notDetermined {
                await notificationsService.requestAuthorization()
            }
            await notificationsService.scheduleNotification(for: seasonDetails, seasonNumber: seasonInfo.seasonNumber, plainShow: show)
        }
        
        if let index = model.seasonsInfo.firstIndex(where: { $0.seasonNumber == seasonInfo.seasonNumber }) {
            model.seasonsInfo[index].notificationStatus = .on
        }
    }
    
    func removeNotifications(seasonInfo: ShowDetailsModel.SeasonInfo) {
        Task {
            await notificationsService.removePendingNotifications(showID: showID, seasonNumber: seasonInfo.seasonNumber)
            
            if let index = model.seasonsInfo.firstIndex(where: { $0.seasonNumber == seasonInfo.seasonNumber }) {
                await changeModel { model in
                    model.seasonsInfo[index].notificationStatus = .off
                }
            }
        }
    }
    
    func loadSimilarShows() {
        Task {
            do {
                let similarShows = try await tvService.getSimilar(for: showID)
                let similarShowsViewModels = similarShows
                    .map { ShowView.Model(plainShow: $0) }
                await set(similarShows: similarShowsViewModels)
            } catch {
                Logger.log(warning: "Similar show not loaded and not handled", error: error)
            }
        }
    }
    
    @MainActor
    func set(similarShows: [ShowView.Model]) {
        model.similarShowsInfo = .init(isLoaded: true, models: similarShows)
    }
    
    var shows: Shows {
        coreDataStorage.get(objectsOfType: Shows.self).first ?? Shows()
    }
    
    func checkForMissedNotifications() async {
        lazy var showName = inMemoryStorage.getCachedShow(id: showID)?.name
        let pendingRequestsIDs = await notificationsService.getPendingRequestsIDs().filter { $0.starts(with: "\(showID)") }
        let seasons = Set(pendingRequestsIDs.map { $0.components(separatedBy: ".")[1] })
        for season in seasons {
            guard let seasonNumber = Int(season),
                  let details = inMemoryStorage.getCachedSeasonDetails(showID: showID, seasonNumber: seasonNumber),
                  let episodes = details.episodes else { continue }
            
            let episodesWithoutNotifications = episodes
                .compactMap { episode -> (SeasonDetails.Episode, Date)? in
                    guard let airDate = episode.airDate,
                          let date = STDateFormatter.date(from: airDate, format: .airDate) else { return nil }
                    return (episode, date)
                }
                .filter { episode, date in
                    guard let episodeNumber = episode.episodeNumber else { return false }
                    return date > Date() && !pendingRequestsIDs.contains("\(showID).\(season).\(episodeNumber)")
                }
                .map { $0.0 }
            
            for episode in episodesWithoutNotifications {
                await notificationsService.scheduleNotification(for: episode, seasonNumber: seasonNumber, showID: showID, showName: showName)
            }
        }
    }
}

private extension DetailedShow.Status {
    var modelStatus: ShowDetailsModel.Status {
        switch self {
        case .ongoing: return .ongoing
        case .ended: return .ended
        case .inProduction: return .inProduction
        case .planned: return .planned
        case .unknown: return .ongoing
        }
    }
}
