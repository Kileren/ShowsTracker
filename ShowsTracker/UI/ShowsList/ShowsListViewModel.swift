//
//  ShowsListViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.07.2022.
//

import SwiftUI
import Resolver

final class ShowsListViewModel: ObservableObject {
    
    @Published var model: ShowsListView.Model = .init()
    
    @Injected private var tvService: ITVService
    @Injected private var searchService: ISearchService
    @Injected private var genresService: IGenresService
    
    private var popularShows: [ShowView.Model] = []
    private var upcomingShows: [ShowView.Model] = []
    private var filterShows: [ShowView.Model] = []
    private var searchedShows: [ShowView.Model] = []
    
    private var tasks: [TaskType: (task: Task<(), Never>?, inProgress: Bool)] = Dictionary(uniqueKeysWithValues: TaskType.allCases.map { ($0, (nil, false)) })

    func viewAppeared() {
        Task {
            do {
                await preloadGenresIfNeeded()
                let popularShows = try await tvService.getPopular().map {
                    ShowView.Model(
                        id: $0.id,
                        posterPath: $0.posterPath ?? "",
                        name: $0.name ?? "",
                        accessory: .vote(STNumberFormatter.format($0.vote ?? 0, format: .vote))
                    )
                }
                self.popularShows = popularShows
                let model = ShowsListView.Model(
                    isLoaded: true,
                    chosenTab: .popular,
                    filter: .init(allGenres: genresService.cachedGenres),
                    currentRepresentation: .popular,
                    shows: popularShows)
                await self.setModel(model)
            } catch {
                Logger.log(warning: "Popular shows not loaded and not handled")
            }
        }
    }
    
    func searchShows(query: String) {
        guard !query.isEmpty else {
            Task {
                if model.chosenTab == .soon {
                    await setNewRepresentation(.upcoming, with: upcomingShows)
                } else {
                    await setNewRepresentation(.popular, with: popularShows)
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
                searchedShows = shows
                await setNewRepresentation(.search, with: shows)
            } catch {
                Logger.log(warning: "Shows not loaded after search and not handled")
            }
            tasks[.search] = (nil, false)
        }
        tasks[.search] = (task, true)
    }
    
    func getMorePopular() {
        guard tasks[.morePopular]?.inProgress == false else { return }
        
        let task = Task {
            do {
                let shows = try await tvService.getMorePopular().map {
                    ShowView.Model(withVoteFrom: $0)
                }
                popularShows.append(contentsOf: shows)
                await addShows(shows)
            } catch {
                Logger.log(warning: "Additional popular shows not loaded and not handled")
            }
            tasks[.morePopular] = (nil, false)
        }
        tasks[.morePopular] = (task, true)
    }
    
    func preloadGenresIfNeeded() async {
        if genresService.cachedGenres.isEmpty {
            _ = try? await genresService.getTVGenres()
        }
    }
    
    func getShowsByFilter() {
        guard !model.filter.isEmpty else {
            Task {
                if model.chosenTab == .soon {
                    await setNewRepresentation(.upcoming, with: upcomingShows)
                } else {
                    await setNewRepresentation(.popular, with: popularShows)
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
                let filterModel = model.filter
                let shows = try await tvService.getByFilter(.init(from: filterModel)).map {
                    ShowView.Model(withVoteFrom: $0)
                }
                filterShows = shows
                await setNewRepresentation(.filter, with: shows)
            } catch {
                Logger.log(warning: "Filter shows not loaded and not handled")
            }
            tasks[.showsByFilter] = (nil, false)
        }
        tasks[.showsByFilter] = (task, true)
    }
    
    func getMoreShowsByFilter() {
        guard tasks[.moreShowsByFilter]?.inProgress == false else { return }
        
        let task = Task {
            do {
                let filterModel = model.filter
                let shows = try await tvService.getMoreByFilter(.init(from: filterModel)).map {
                    ShowView.Model(withVoteFrom: $0)
                }
                filterShows.append(contentsOf: shows)
                await addShows(shows)
            } catch {
                Logger.log(warning: "More filter shows not loaded and not handled")
            }
            tasks[.moreShowsByFilter] = (nil, false)
        }
        tasks[.moreShowsByFilter] = (task, true)
    }
    
    @MainActor
    func filterSelected(_ filter: FilterView.Model) {
        model.filter = filter
        setNewRepresentation(.filter, with: [])
    }
    
    @MainActor
    func didSelectTab(_ tab: ShowsListView.Model.Tab) {
        model.chosenTab = tab
        switch tab {
        case .popular:
            setNewRepresentation(.popular, with: popularShows)
        case .soon:
            setNewRepresentation(.upcoming, with: upcomingShows)
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
                await addShows(shows)
            } catch {
                Logger.log(warning: "Upcoming shows not loaded and not handled")
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
                await addShows(shows)
            } catch {
                Logger.log(warning: "Upcoming shows not loaded and not handled")
            }
            tasks[.moreUpcoming] = (nil, false)
        }
        tasks[.moreUpcoming] = (task, true)
    }
}

// MARK: - Private

private extension ShowsListViewModel {
    @MainActor
    func setModel(_ model: ShowsListView.Model) {
        self.model = model
    }
    
    @MainActor
    func setNewRepresentation(_ representation: ShowsListView.Model.Representation, with shows: [ShowView.Model]) {
        guard model.currentRepresentation != representation else {
            model.shows = shows
            return
        }
        
        model.currentRepresentation = representation
        model.shows = shows
        
        withAnimation(.easeInOut(duration: Const.animationDuration), animateCompletion: true) {
            // Tab with popular and upcoming shows should be visible only if search or filter is inactive
            model.tabIsVisible = representation == .popular || representation == .upcoming
        } completion: { [weak self] in
            if representation == .search {
                // If current representation is search then filter shouldn't be visible and current filter should be resetted
                self?.model.filterButtonIsVisible = false
                self?.model.filter = .empty
            } else {
                // Filter button should be visible on any representation except search
                self?.model.filterButtonIsVisible = true
            }
        }
    }
    
    @MainActor
    func addShows(_ shows: [ShowView.Model]) {
        model.shows.append(contentsOf: shows)
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
