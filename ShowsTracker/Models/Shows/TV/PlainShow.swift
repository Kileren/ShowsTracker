//
//  PlainShow.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 09.04.2021.
//

import Foundation
import CoreData

struct PlainShow: Codable {
    let name: String?
    let originalName: String?
    let vote: Double?
    let posterPath: String?
    let popularity: Double?
    let id: Int
    let backdropPath: String?
    let overview: String?
    let airDate: String?
    let countries: [String]?
    let genres: [Int]?
    let originalLanguage: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case originalName = "original_name"
        case vote = "vote_average"
        case posterPath = "poster_path"
        case popularity
        case id
        case backdropPath = "backdrop_path"
        case overview
        case airDate = "first_air_date"
        case countries = "origin_country"
        case genres = "genre_ids"
        case originalLanguage = "original_language"
    }
}

// TODO: Just for test, remove it
extension PlainShow {
    static func theWitcher() -> PlainShow {
        PlainShow(
            name: "The Witcher",
            originalName: "The Witcher",
            vote: 8.2,
            posterPath: "/zrPpUlehQaBf8YX2NrVrKK8IEpf.jpg",
            popularity: 79.819,
            id: 71912,
            backdropPath: "/kysKBF2CJG9qfQDSCDaboJrkZy1.jpg",
            overview: "Geralt of Rivia, a mutated monster-hunter for hire, journeys toward his destiny in a turbulent world where people often prove more wicked than beasts.",
            airDate: "2019-12-20",
            countries: ["US"],
            genres: [10765, 18, 10759],
            originalLanguage: "en"
        )
    }
    
    static func theMandalorian() -> PlainShow {
        PlainShow(
            name: "The Mandalorian",
            originalName: "The Mandalorian",
            vote: 8.5,
            posterPath: "/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg",
            popularity: 229.899,
            id: 82856,
            backdropPath: "/9ijMGlJKqcslswWUzTEwScm82Gs.jpg",
            overview: "After the fall of the Galactic Empire, lawlessness has spread throughout the galaxy. A lone gunfighter makes his way through the outer reaches, earning his keep as a bounty hunter.",
            airDate: "2019-11-12",
            countries: ["US"],
            genres: [10765, 10759, 37, 18],
            originalLanguage: "en"
        )
    }
}

extension PlainShow: ManagedObjectEncodable {
    typealias ManagedObject = PlainShowMO
    
    func encode(in context: NSManagedObjectContext) {
        let show = PlainShowMO(context: context)
        show.name = name
        show.originalName = originalName
        show.vote = vote ?? 0
        show.posterPath = posterPath
        show.popularity = popularity ?? 0
        show.id = Int64(id)
        show.backdropPath = backdropPath
        show.overview = overview
        show.airDate = airDate
        show.countries = countries
        show.genres = genres
        show.originalLanguage = originalLanguage
    }
    
    func moModel(in context: NSManagedObjectContext) -> PlainShowMO {
        let show = PlainShowMO(context: context)
        show.name = name
        show.originalName = originalName
        show.vote = vote ?? 0
        show.posterPath = posterPath
        show.popularity = popularity ?? 0
        show.id = Int64(id)
        show.backdropPath = backdropPath
        show.overview = overview
        show.airDate = airDate
        show.countries = countries
        show.genres = genres
        show.originalLanguage = originalLanguage
        return show
    }
}

extension PlainShowMO: ManagedObjectDecodable {
    typealias Object = PlainShow
    
    func decode() -> PlainShow {
        PlainShow(
            name: name,
            originalName: originalName,
            vote: vote,
            posterPath: posterPath,
            popularity: popularity,
            id: Int(id),
            backdropPath: backdropPath,
            overview: overview,
            airDate: airDate,
            countries: countries,
            genres: genres,
            originalLanguage: originalLanguage)
    }
    
    func change(with object: PlainShow, in context: NSManagedObjectContext) {
        name = object.name
        originalName = object.originalName
        vote = object.vote ?? 0
        posterPath = object.posterPath
        popularity = object.popularity ?? 0
        id = Int64(object.id)
        backdropPath = object.backdropPath
        overview = object.overview
        airDate = object.airDate
        countries = object.countries
        genres = object.genres
        originalLanguage = object.originalLanguage
    }
}
