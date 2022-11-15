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
        self.model.loading = .loading
        
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
        if tab == .similar, model.similarShowsInfo.state == .initial {
            model.similarShowsInfo.state = .loading
            loadSimilarShows()
        }
        
        if model.selectedInfoTab != tab {
            withAnimation(.easeIn) {
                model.selectedInfoTab = tab
            }
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
    
    func reloadSimilarShows() {
        model.similarShowsInfo.state = .loading
        loadSimilarShows()
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
                loading: .done,
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
            await set(model: .init(loading: .error))
        }
    }
    
    func seasonsInfo(from show: DetailedShow) async -> [ShowDetailsModel.SeasonInfo] {
        guard let seasons = show.seasons, seasons.count > 0 else { return [] }
        
        let seasonsDetails: [SeasonDetails] = await withTaskGroup(of: SeasonDetails?.self) { taskGroup in
            seasons.compactMap { $0.seasonNumber }.forEach { season in
                taskGroup.addTask {
                    try? await self.tvService.getSeasonDetails(for: show.id ?? self.showID, season: season)
                }
            }
            var details: [SeasonDetails] = []
            for await result in taskGroup.compactMap({ $0 }) {
                details.append(result)
            }
            return details
        }
        
        var seasonsInfo: [ShowDetailsModel.SeasonInfo] = []
        for details in seasonsDetails.sorted(by: { ($0.seasonNumber ?? 0) < ($1.seasonNumber ?? 0) }) {
            guard let seasonNumber = details.seasonNumber else { continue }
            var title = details.name ?? "\(Strings.season) \(seasonNumber)"
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
                await changeModel { $0.similarShowsInfo.state = .error }
            }
        }
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

private extension ShowDetailsViewModel {
    @MainActor
    func set(model: ShowDetailsModel) {
        self.model = model
    }
    
    @MainActor
    func changeModel(completion: (inout ShowDetailsModel) -> Void) {
        completion(&model)
    }
    
    @MainActor
    func set(similarShows: [ShowView.Model]) {
        model.similarShowsInfo = .init(state: .loaded(models: similarShows))
    }
}

private extension DetailedShow.Status {
    var modelStatus: ShowDetailsModel.Status {
        switch self {
        case .ongoing: return .ongoing
        case .ended: return .ended
        case .inProduction: return .inProduction
        case .planned: return .planned
        case .canceled: return .canceled
        case .unknown: return .ongoing
        }
    }
}
