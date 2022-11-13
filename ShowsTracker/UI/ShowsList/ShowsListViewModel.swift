//
//  ShowsListViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.07.2022.
//

import SwiftUI
import Resolver

final class ShowsListViewModel: ObservableObject {
    
    @Published var model: ShowsListModel = .init()
    
    @Injected private var tvService: ITVService
    @Injected private var searchService: ISearchService
    @Injected private var genresService: IGenresService
    
    private var popularShows: [ShowView.Model] = []
    private var upcomingShows: [ShowView.Model] = []
    private var lastSearchQuery: String = ""
    
    private var tasks: [TaskType: (task: Task<(), Never>?, inProgress: Bool)] = Dictionary(uniqueKeysWithValues: TaskType.allCases.map { ($0, (nil, false)) })

    func viewAppeared() {
        Task {
            await preloadGenresIfNeeded()
            await getPopular()
        }
    }
    
    func getPopular() async {
        do {
            await changeModel { $0.currentRepresentation = .popular(state: .loading) }
            let popularShows = try await tvService.getPopular().map {
                ShowView.Model(
                    id: $0.id,
                    posterPath: $0.posterPath ?? "",
                    name: $0.name ?? "",
                    accessory: .vote(STNumberFormatter.format($0.vote ?? 0, format: .vote))
                )
            }
            self.popularShows = popularShows
            
            await self.changeModel {
                $0.chosenTab = .popular
                $0.initiallyLoaded = true
                $0.currentRepresentation = .popular(state: .loaded)
                $0.shows = popularShows
                $0.loadMoreAvailable = tvService.canLoadMorePopular
            }
        } catch {
            await changeModel {
                $0.initiallyLoaded = true
                $0.currentRepresentation = .popular(state: .error)
            }
        }
    }
    
    func searchShows(query: String) {
        lastSearchQuery = query
        guard !query.isEmpty else {
            Task {
                if model.chosenTab == .soon {
                    await setNewRepresentation(.upcoming(state: .loaded), with: upcomingShows)
                } else {
                    await setNewRepresentation(.popular(state: .loaded), with: popularShows)
                }
            }
            tasks[.search]?.task?.cancel()
            tasks[.search] = (nil, false)
            return
        }
        
        if tasks[.search]?.inProgress == true {
            tasks[.search]?.task?.cancel()
            tasks[.search] = (nil, false)
        }
        
        let task = Task {
            do {
                let shows = try await searchService.searchTVShows(query: query).map {
                    ShowView.Model(withVoteFrom: $0)
                }
                try Task.checkCancellation()
                await setNewRepresentation(.search(state: .loaded), with: shows)
                if !searchService.canLoadMoreTVShows() {
                    await changeModel { $0.loadMoreAvailable = false }
                }
            } catch {
                await changeModel { $0.currentRepresentation = .search(state: .error) }
            }
            tasks[.search] = (nil, false)
        }
        tasks[.search] = (task, true)
    }
    
    func getMore() {
        switch model.currentRepresentation {
        case .popular: getMorePopular()
        case .filter: getMoreShowsByFilter()
        case .upcoming: getMoreUpcoming()
        case .search: getMoreBySearch()
        }
    }
    
    func getMorePopular() {
        guard tasks[.morePopular]?.inProgress == false else { return }
        
        let task = Task {
            do {
                let shows = try await tvService.getMorePopular().map {
                    ShowView.Model(withVoteFrom: $0)
                }
                popularShows.append(contentsOf: shows)
                await addShows(shows, loadMoreAvailable: tvService.canLoadMorePopular)
            } catch {
                if case TVService.InternalError.allShowsLoaded = error {
                    await changeModel { $0.loadMoreAvailable = false }
                } else {
                    Logger.log(warning: "Additional popular shows not loaded and not handled")
                }
            }
            tasks[.morePopular] = (nil, false)
        }
        tasks[.morePopular] = (task, true)
    }
    
    func preloadGenresIfNeeded() async {
        if genresService.cachedGenres.isEmpty {
            _ = try? await genresService.getTVGenres()
        }
        await changeModel { $0.filter.allGenres = genresService.cachedGenres }
    }
    
    func getShowsByFilter() {
        guard !model.filter.isEmpty else {
            Task {
                if model.chosenTab == .soon {
                    await setNewRepresentation(.upcoming(state: .loaded), with: upcomingShows)
                    if !tvService.canLoadMoreUpcoming {
                        await changeModel { $0.loadMoreAvailable = false }
                    }
                } else {
                    await setNewRepresentation(.popular(state: .loaded), with: popularShows)
                    if !tvService.canLoadMorePopular {
                        await changeModel { $0.loadMoreAvailable = false }
                    }
                }
            }
            tasks[.showsByFilter]?.task?.cancel()
            tasks[.showsByFilter] = (nil, false)
            return
        }
        
        if tasks[.showsByFilter]?.inProgress == true {
            tasks[.showsByFilter]?.task?.cancel()
            tasks[.showsByFilter] = (nil, false)
        }
        
        let task = Task {
            do {
                let shows = try await tvService.getByFilter(.init(from: model.filter)).map {
                    ShowView.Model(withVoteFrom: $0)
                }
                await setNewRepresentation(.filter(state: .loaded), with: shows)
                if !tvService.canLoadMoreByFilter {
                    await changeModel { $0.loadMoreAvailable = false }
                }
            } catch {
                if case TVService.InternalError.allShowsLoaded = error {
                    await changeModel { $0.loadMoreAvailable = false }
                } else {
                    await changeModel { $0.currentRepresentation = .filter(state: .error) }
                }
            }
            tasks[.showsByFilter] = (nil, false)
        }
        tasks[.showsByFilter] = (task, true)
    }
    
    func getMoreShowsByFilter() {
        guard tasks[.moreShowsByFilter]?.inProgress == false else { return }
        
        let task = Task {
            do {
                let shows = try await tvService.getMoreByFilter().map {
                    ShowView.Model(withVoteFrom: $0)
                }
                await addShows(shows, loadMoreAvailable: tvService.canLoadMoreByFilter)
            } catch {
                if case TVService.InternalError.allShowsLoaded = error {
                    await changeModel { $0.loadMoreAvailable = false }
                } else {
                    Logger.log(warning: "More filter shows not loaded and not handled")
                }
            }
            tasks[.moreShowsByFilter] = (nil, false)
        }
        tasks[.moreShowsByFilter] = (task, true)
    }
    
    @MainActor
    func filterSelected(_ filter: FilterView.Model) {
        model.filter = filter
        setNewRepresentation(.filter(state: .loading), with: [])
    }
    
    @MainActor
    func didSelectTab(_ tab: ShowsListModel.Tab) {
        model.chosenTab = tab
        switch tab {
        case .popular:
            setNewRepresentation(.popular(state: .loaded), with: popularShows)
            model.loadMoreAvailable = tvService.canLoadMorePopular
            
            if popularShows.isEmpty {
                Task { await getPopular() }
            }
        case .soon:
            setNewRepresentation(.upcoming(state: .loaded), with: upcomingShows)
            model.loadMoreAvailable = tvService.canLoadMoreUpcoming
            
            if upcomingShows.isEmpty {
                getUpcoming()
            }
        }
    }
    
    func getUpcoming() {
        guard tasks[.upcoming]?.inProgress == false else { return }

        let task = Task {
            do {
                let shows = try await tvService.getUpcoming().map {
                    ShowView.Model(withDateFrom: $0)
                }
                upcomingShows = shows
                await addShows(shows, loadMoreAvailable: tvService.canLoadMoreUpcoming)
            } catch {
                if case TVService.InternalError.allShowsLoaded = error {
                    await changeModel { $0.loadMoreAvailable = false }
                } else {
                    await changeModel { $0.currentRepresentation = .upcoming(state: .error) }
                }
            }
            tasks[.upcoming] = (nil, false)
        }
        tasks[.upcoming] = (task, true)
    }
    
    func getMoreUpcoming() {
        guard tasks[.moreUpcoming]?.inProgress == false else { return }
        
        let task = Task {
            do {
                let shows = try await tvService.getMoreUpcoming().map {
                    ShowView.Model(withDateFrom: $0)
                }
                upcomingShows.append(contentsOf: shows)
                await addShows(shows, loadMoreAvailable: tvService.canLoadMoreUpcoming)
            } catch {
                if case TVService.InternalError.allShowsLoaded = error {
                    await changeModel { $0.loadMoreAvailable = false }
                } else {
                    Logger.log(warning: "Upcoming shows not loaded and not handled")
                }
            }
            tasks[.moreUpcoming] = (nil, false)
        }
        tasks[.moreUpcoming] = (task, true)
    }
    
    func getMoreBySearch() {
        guard tasks[.search]?.inProgress == false else { return }
        
        let task = Task {
            do {
                let shows = try await searchService.loadMoreTVShows().map { ShowView.Model(withDateFrom: $0) }
                try Task.checkCancellation()
                await addShows(shows, loadMoreAvailable: searchService.canLoadMoreTVShows())
            } catch {
                if case SearchService.InternalError.allShowsLoaded = error {
                    await changeModel { $0.loadMoreAvailable = false }
                } else {
                    Logger.log(warning: "Shows not loaded after search and not handled")
                }
            }
            tasks[.search] = (nil, false)
        }
        tasks[.search] = (task, true)
    }
    
    func retryAfterError() {
        Task {
            switch model.currentRepresentation {
            case .popular:
                await changeModel { $0.currentRepresentation = .popular(state: .loading) }
                await getPopular()
            case .upcoming:
                await changeModel { $0.currentRepresentation = .upcoming(state: .loading) }
                getUpcoming()
            case .search:
                await changeModel { $0.currentRepresentation = .search(state: .loading) }
                searchShows(query: lastSearchQuery)
            case .filter:
                await changeModel { $0.currentRepresentation = .filter(state: .loading) }
                getShowsByFilter()
            }
        }
    }
}

// MARK: - Private

private extension ShowsListViewModel {
    @MainActor
    func setModel(_ model: ShowsListModel) {
        self.model = model
    }
    
    @MainActor
    func changeModel(handler: (inout ShowsListModel) -> Void) {
        handler(&model)
    }
    
    @MainActor
    func setNewRepresentation(_ representation: ShowsListModel.Representation, with shows: [ShowView.Model]) {
        guard model.currentRepresentation != representation else {
            model.shows = shows
            model.loadMoreAvailable = true
            model.currentRepresentation = representation
            return
        }
        
        model.currentRepresentation = representation
        model.shows = shows
        model.loadMoreAvailable = true
        
        if case .filter = representation { } else {
            model.filter.clear()
        }
        
        withAnimation(.easeInOut(duration: Const.animationDuration), animateCompletion: true) {
            // Tab with popular and upcoming shows should be visible only if search or filter is inactive
            var isTabVisible: Bool {
                switch representation {
                case .popular, .upcoming: return true
                default: return false
                }
            }
            model.tabIsVisible = isTabVisible
        } completion: { [weak self] in
            if case .search = representation {
                // If current representation is search then filter shouldn't be visible and current filter should be resetted
                self?.model.filterButtonIsVisible = false
            } else {
                // Filter button should be visible on any representation except search
                self?.model.filterButtonIsVisible = true
            }
        }
    }
    
    @MainActor
    func addShows(_ shows: [ShowView.Model], loadMoreAvailable: Bool) {
        model.shows.append(contentsOf: shows)
        model.loadMoreAvailable = loadMoreAvailable
    }
}

// MARK: - Models

private extension ShowsListViewModel {
    enum TaskType: CaseIterable {
        case search
        case morePopular
        case showsByFilter
        case moreShowsByFilter
        case upcoming
        case moreUpcoming
    }
}

// MARK: - Extension

private extension ShowView.Model {
    init(withVoteFrom plainShow: PlainShow) {
        self.id = plainShow.id
        self.posterPath = plainShow.posterPath ?? ""
        self.name = plainShow.name ?? ""
        
        let voteValue = plainShow.vote ?? 0
        let vote = voteValue > 0 ? STNumberFormatter.format(voteValue, format: .vote) : "-"
        self.accessory = .vote(vote)
    }
    
    init(withDateFrom plainShow: PlainShow) {
        self.id = plainShow.id
        self.posterPath = plainShow.posterPath ?? ""
        self.name = plainShow.name ?? ""
        
        if let airDate = plainShow.airDate {
            let day = STDateFormatter.format(airDate, format: .day)
            var month = STDateFormatter.format(airDate, format: .shortMonth)
            month = month.last == "." ? String(month.dropLast()) : month
            self.accessory = .date(day: day,month: month)
        } else {
            self.accessory = .date(day: "", month: "")
        }
    }
}

private extension DiscoverTarget.Filter {
    init(from model: FilterView.Model) {
        self.sortType = .init(from: model.sorting)
        self.genres = Set(model.selectedGenres.map { $0.id ?? 0 })
        self.originalLanguage = model.selectedOriginalLanguage
        self.minAirDate = "\(model.minYear)-01-01"
        self.maxAirDate = "\(model.maxYear)-01-01"
    }
}

private extension DiscoverTarget.SortType {
    init(from sorting: FilterView.Model.Sorting) {
        switch sorting {
        case .popularity: self = .popularity
        case .airDate: self = .airDate
        case .votes: self = .votes
        }
    }
}

private extension ShowsListViewModel {
    enum Const {
        static let animationDuration: TimeInterval = 0.25
    }
}
