import Foundation

struct MovieDetails: Codable {
    let adult: Bool?
    let backdrop_path: String?
    let belongs_to_collection: BelongToCollections?
    let budget: Int?
    let genres: [Genre]?
    let homepage: String?
    let id: Int?
    let imdb_id, original_language, original_title, overview: String?
    let popularity: Double?
    let poster_path: String?
    let production_companies: [ProductionCompany]?
    let production_countries: [ProductionCountry]?
    let release_date: String?
    let revenue, runtime: Int?
    let spoken_languages: [SpokenLanguage]?
    let status, tagline, title: String?
    let video: Bool?
    let vote_average: Double?
    let vote_count: Int?
}

struct BelongToCollections:Codable {
    let id:Double?
    let name:String?
    let poster_path:String?
    let backdrop_path:String?
}

struct Genre: Codable {
    let id: Int?
    let name: String?
}

struct ProductionCompany: Codable {
    let id: Int?
    let logo_path: String?
    let name, origin_country: String?
}

struct ProductionCountry: Codable {
    let iso_3166_1, name: String?
}

struct SpokenLanguage: Codable {
    let english_name, iso_639_1, name: String?
}
