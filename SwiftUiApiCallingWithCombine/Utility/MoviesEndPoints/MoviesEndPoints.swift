

import Foundation

enum MoviesEndPoints {
    case movies(moviesModelRequest:MovieModelRequest) // GET API WITH URL ENCODING
    case moviesDescriptions(movieInfoModelRequest:MovieInfoModelRequest,movieId:String)
}

// https://fakestoreapi.com/products

extension MoviesEndPoints: EndPointType {
    var pathExtensions: String? {
        switch self {
        case .movies:
            return nil
        case .moviesDescriptions(_,let movieId):
            return movieId
        }
    }
    
    
    var path: String {
        switch self {
        case .movies:
            return "3/discover/movie"
        case .moviesDescriptions:
            return "3/movie/"
        }
    }
    
    var baseURL: String {
        switch self {
        case .movies:
            return "https://api.themoviedb.org/"
        case .moviesDescriptions:
            return "https://api.themoviedb.org/"
        }
    }
    
    var url: URL? {
        return URL(string: "\(baseURL)\(path)")
    }
    
    var method: HTTPMethods {
        switch self {
        case .movies:
            return .get
        case .moviesDescriptions:
            return .get
        }
    }
    
    var body: Encodable? {
        switch self {
        case .movies:
            return nil
        case .moviesDescriptions:
            return nil
        }
    }
    
    var headers: [String : String]? {
        APIManager.commonHeaders
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .movies(let moviesModelRequest):
            return moviesModelRequest.dictionary
        case .moviesDescriptions:
            return nil
        }
    }
}

