//
//  MovieListFetch.swift
//  SwiftUiApiCallingWithCombine
//
//  Created by mind on 28/03/24.
//

import Foundation
import Combine

class MovieListFetch:ObservableObject,Identifiable {
    var id = UUID()
    @Published var movies = [ResultMovie]()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchMovies(movieRequest: MovieModelRequest) {
        APIManager.shared.request(modelType: MovieResponse.self, type: MoviesEndPoints.movies(moviesModelRequest: movieRequest)).sink { completion in
            switch completion {
            case .failure(let err):
                print("Error is \(err.localizedDescription)")
            case .finished:
                print("Finished")
            }
        } receiveValue: { [weak self] movieResult in
            DispatchQueue.main.async {
                self?.movies = movieResult.results
              }
           
        }
        .store(in: &cancellables)
    }
}
