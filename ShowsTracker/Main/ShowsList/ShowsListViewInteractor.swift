//
//  ShowsListViewInteractor.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 09.05.2022.
//

import SwiftUI
import Resolver

final class ShowsListViewInteractor {
    
    @InjectedObject private var appState: AppState
    @Injected private var tvService: ITVService
    @Injected private var searchService: ISearchService
    @Injected private var genresService: IGenresService
    
    func viewAppeared() {
        Task {
            do {
                await preloadGenres()
                let popularShows = try await tvService.getPopular().map {
                    ShowView.Model(
                        id: $0.id,
                        posterPath: $0.posterPath ?? "",
                        name: $0.name ?? "",
                        accessory: .vote(STNumberFormatter.format($0.vote ?? 0, format: .vote))
                    )
                }
                let model = ShowsListView.Model(
                    isLoaded: true,
                    chosenTab: .popular,
                    popularShows: popularShows)
                self.setModel(model)
            } catch {
                Logger.log(warning: "Popular shows not loaded and not handled")
            }
        }
    }
    
    func searchShows(query: String) {
        Task {
            do {
                let shows = try await searchService.searchTVShows(query: query)
            } catch {
                Logger.log(warning: "Shows not loaded after search and not handled")
            }
        }
    }
    
    func getMorePopular() {
        Task {
            do {
                let shows = try await tvService.getMorePopular().map {
                    ShowView.Model(withVoteFrom: $0)
                }
                addPopularShows(shows)
            } catch {
                Logger.log(warning: "Additional popular shows not loaded and not handled")
            }
        }
    }
    
    func preloadGenres() async {
        guard appState.service.value.genres.isEmpty,
              let genres = try? await genresService.getTVGenres() else { return }
        
        appState.service[\.genres] = genres
    }
    
    func getShowsByFilter() {
        Task {
            do {
                let filterModel = appState.info[\.showsList.filter]
                let shows = try await tvService.getByFilter(.init(from: filterModel)).map {
                    ShowView.Model(withVoteFrom: $0)
                }
                setFilterShows(shows)
            } catch {
                Logger.log(warning: "Filter shows not loaded and not handled")
            }
        }
    }
    
    func getMoreShowsByFilter() {
        Task {        
            do {
                let filterModel = appState.info[\.showsList.filter]
                let shows = try await tvService.getMoreByFilter(.init(from: filterModel)).map {
                    ShowView.Model(withVoteFrom: $0)
                }
                addFilterShows(shows)
            } catch {
                Logger.log(warning: "More filter shows not loaded and not handled")
            }
        }
    }
    
    func filterSelected(_ filter: FilterView.Model) {
        appState.info[\.showsList.filter] = filter
    }
    
    func didSelectTab(_ tab: ShowsListView.Model.Tab) {
        appState.info[\.showsList.chosenTab] = tab
    }
    
    func getUpcoming() {
        Task {
            do {
                let shows = try await tvService.getUpcoming().map {
                    ShowView.Model(withDateFrom: $0)
                }
                addUpcomingShows(shows)
            } catch {
                Logger.log(warning: "Upcoming shows not loaded and not handled")
            }
        }
    }
    
    func getMoreUpcoming() {
        Task {
            do {
                let shows = try await tvService.getMoreUpcoming().map {
                    ShowView.Model(withDateFrom: $0)
                }
                addUpcomingShows(shows)
            } catch {
                Logger.log(warning: "Upcoming shows not loaded and not handled")
            }
        }
    }
}

// MARK: - Private

private extension ShowsListViewInteractor {
    @MainActor
    func setModel(_ model: ShowsListView.Model) {
        appState.info[\.showsList] = model
    }
    
    @MainActor
    func addPopularShows(_ shows: [ShowView.Model]) {
        appState.info[\.showsList.popularShows].append(contentsOf: shows)
    }
    
    @MainActor
    func setFilterShows(_ shows: [ShowView.Model]) {
        appState.info[\.showsList.filterShows] = shows
    }
    
    @MainActor
    func addFilterShows(_ shows: [ShowView.Model]) {
        appState.info[\.showsList.filterShows].append(contentsOf: shows)
    }
    
    @MainActor
    func addUpcomingShows(_ shows: [ShowView.Model]) {
        appState.info[\.showsList.upcomingShows].append(contentsOf: shows)
    }
}

private extension ShowView.Model {
    init(withVoteFrom plainShow: PlainShow) {
        self.id = plainShow.id
        self.posterPath = plainShow.posterPath ?? ""
        self.name = plainShow.name ?? ""
        self.accessory = .vote(STNumberFormatter.format(plainShow.vote ?? 0, format: .vote))
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
        self.genres = Set(model.selectedGenres.map { $0.id })
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
