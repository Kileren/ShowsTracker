//
//  LikedShowsListViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 31.10.2022.
//

import SwiftUI
import Resolver

final class LikedShowsListViewModel: ObservableObject {
    
    @Injected private var coreDataStorage: ICoreDataStorage
    @Injected private var imageService: IImageService
    
    @Published var model: FavoritesShowsListModel = .init(shows: [])
    
    func viewAppeared() {
        reload()
    }
    
    func reload() {
        Task {        
            var shows: [FavoritesShowsListModel.Show] = []
            for likedShow in savedLikedShows {
                let image: Image
                if let uiImage = try? await imageService.loadImage(path: likedShow.posterPath ?? "") {
                    image = Image(uiImage: uiImage)
                } else {
                    image = Image("noImage")
                }
                
                let description: String
                if let airDate = likedShow.airDate {
                    let yearOfRelease = STDateFormatter.format(airDate, format: .year)
                    description = "Год выпуска: \(yearOfRelease)"
                } else {
                    description = ""
                }
                let show = FavoritesShowsListModel.Show(
                    id: likedShow.id,
                    image: image,
                    title: likedShow.name ?? "",
                    description: description)
                shows.append(show)
            }
            await set(shows: shows)
        }
    }
    
    func moveShow(indexSet: IndexSet, index newIndex: Int) {
        guard let oldIndex = indexSet.map({ $0 }).first,
              oldIndex != newIndex else { return }
        
        var likedShows = savedLikedShows
        let show = likedShows[oldIndex]
        if oldIndex > newIndex {
            // Move upper
            likedShows.remove(at: oldIndex)
            likedShows.insert(show, at: newIndex)
        } else {
            // Move lower
            likedShows.remove(at: oldIndex)
            likedShows.insert(show, at: newIndex - 1)
        }
        save(likedShows: likedShows)
    }
    
    func delete(indexSet: IndexSet) {
        guard let index = indexSet.map({ $0 }).first else { return }
        var likedShows = savedLikedShows
        likedShows.remove(at: index)
        save(likedShows: likedShows)
    }
}

private extension LikedShowsListViewModel {
    var savedLikedShows: [PlainShow] {
        savedShows?.likedShows ?? []
    }
    
    var savedShows: Shows? {
        coreDataStorage.get(objectsOfType: Shows.self).first
    }
    
    func save(likedShows: [PlainShow]) {
        guard var shows = savedShows else { return }
        shows.likedShows = likedShows
        coreDataStorage.save(object: shows)
    }
    
    @MainActor
    func set(shows: [FavoritesShowsListModel.Show]) {
        model = .init(shows: shows)
    }
}
