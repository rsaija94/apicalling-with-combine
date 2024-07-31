//
//  MovieResponse.swift
//  ViperTestingDemo
//
//  Created by mind on 07/03/24.
//

import Foundation

// MARK: - MoveResponse
struct MovieResponse: Codable {
    let page: Int?
    let results: [ResultMovie]
    let totalPages, totalResults: Int?
}

// MARK: - Result
struct ResultMovie: Codable,Equatable {
    let adult: Bool?
    let backdrop_path: String?
    let genre_ids: [Int]?
    let id: Int?
    let original_language: String?
    let original_title, overview: String?
    let popularity: Double?
    let poster_path, release_date, title: String?
    let video: Bool?
    let vote_average: Double?
    let vote_count: Int?
}

