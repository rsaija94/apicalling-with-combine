

import Foundation
import Combine
// Singleton Design Pattern

enum DataError: Error {
    case invalidResponse
    case invalidURL
    case invalidData
    case responseError
    case decodingError
    case unknown
    case network(Error?)
    case decoding(Error?)
}

typealias ResultHandler<T> = (Result<T, DataError>) -> Void

private var cancellables = Set<AnyCancellable>()

class APIManager {
    
    static let shared = APIManager()
    private let networkHandler: NetworkHandler
    private let responseHandler: ResponseHandler
    
    private var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "AuthToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "AuthToken")
        }
    }
    
    init(networkHandler: NetworkHandler = NetworkHandler(),
         responseHandler: ResponseHandler = ResponseHandler()) {
        self.networkHandler = networkHandler
        self.responseHandler = responseHandler
        token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3Y2FiYWQyYWVjNDQxYTA1MDdhMzI0MzIwM2VhYjlkOCIsInN1YiI6IjY1YzlhODZhYWFkOWMyMDE3ZGI5NGZkZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.mXcnQzVRIHz3unZYgKfWztcdXdC6sWrK0qCq7lHtdRQ"
    }
    
    func request<T: Codable>(
        modelType: T.Type,
        type: EndPointType) -> Future<T, DataError> {
            return Future<T,DataError> { [weak self] promise in
                guard let url = type.url else {
                    return promise(.failure(.invalidURL))
                }
                
                var urlString = url.absoluteString
                
                if (type.pathExtensions) != nil {
                    urlString = "\(urlString)\(type.pathExtensions ?? "")"
                }
                
                // Append query parameters if available
                if let parameters = type.parameters {
                    let queryItems = parameters.map { URLQueryItem(name: $0, value: "\($1)") }
                    if var urlComponents = URLComponents(string: urlString) {
                        urlComponents.queryItems = queryItems
                        urlString = urlComponents.string ?? urlString
                    }
                }
                
                guard let requestURL = URL(string: urlString) else {
                    return promise(.failure(.invalidURL))
                }
                
                var request = URLRequest(url: requestURL)
                request.httpMethod = type.method.rawValue
                
                if let parameters = type.body {
                    request.httpBody = try? JSONEncoder().encode(parameters)
                }
                
                if let token = self?.token {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                
                request.allHTTPHeaderFields = type.headers
                
                // Network Request - URL TO DATA
                
                self?.networkHandler.requestDataAPI(url: request).sink { completion in
                    switch completion {
                    case .failure(let err):
                        print("Error is \(err.localizedDescription)")
                    case .finished:
                        print("Finished")
                    }

                } receiveValue: { [weak self] data in
                    self?.responseHandler.parseResonseDecode(data: data,modelType: modelType).sink { completion in
                        switch completion {
                        case .failure(let err):
                            print("Error is \(err.localizedDescription)")
                        case .finished:
                            print("Finished")
                        }
                    } receiveValue: { [weak self] responseModel in
                        return promise(.success(responseModel))
                    }
                    .store(in: &cancellables)

                }
                .store(in: &cancellables)
            }
        }
    
    
    
    static var commonHeaders: [String: String] {
        return [
            "Content-Type": "application/json"
        ]
    }
    
    func setAuthToken(token: String?) {
        self.token = token
    }
}


class NetworkHandler {
    func requestDataAPI(url: URLRequest) -> Future<Data,DataError> {
        return Future<Data,DataError> { [weak self] promise in
            let session = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let response = response as? HTTPURLResponse,
                      200 ... 299 ~= response.statusCode else {
                    promise(.failure(.invalidResponse))
                    return
                }
                guard let data, error == nil else {
                    promise(.failure(.invalidData))
                    return
                }
                promise(.success(data))
            }
            session.resume()
        }
    }
}

class ResponseHandler {
    func parseResonseDecode<T: Decodable>(data: Data,modelType: T.Type) -> Future<T,DataError> {
        return Future<T,DataError> { [weak self] promise in
            do {
                let userResponse = try JSONDecoder().decode(modelType, from: data)
                return promise(.success(userResponse))
            }catch {
                return promise(.failure(.decoding(error)))
            }
        }
    }
}

//// Image Upload
//import UIKit
//
//class ImageUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    // Present UIImagePickerController to select image from camera or gallery
//    func pickImage() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary // or .camera to capture from camera
//        present(imagePicker, animated: true, completion: nil)
//    }
//
//    // MARK: - UIImagePickerControllerDelegate
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let pickedImage = info[.originalImage] as? UIImage {
//            // Dismiss UIImagePickerController
//            picker.dismiss(animated: true, completion: nil)
//
//            // Upload picked image
//            uploadImage(image: pickedImage)
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    // Upload image to server
//    func uploadImage(image: UIImage) {
//        // Convert image to Data
//        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
//            return
//        }
//
//        // Create URL request
//        let serverURL = URL(string: "https://example.com/upload")! // Replace with your server's endpoint URL
//        var request = URLRequest(url: serverURL)
//        request.httpMethod = "POST"
//        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type") // Set appropriate Content-Type
//
//        // Attach token if needed
//        let token = "your_access_token_here"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        // Create URLSessionDataTask
//        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
//            if let error = error {
//                print("Error uploading image: \(error)")
//                return
//            }
//
//            // Check if response contains any error
//            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
//                let statusCode = httpResponse.statusCode
//                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
//                print("HTTP Error: \(statusCode) - \(errorMessage)")
//                return
//            }
//
//            // Handle successful response
//            print("Image uploaded successfully!")
//        }
//
//        // Execute the task
//        task.resume()
//    }
//}
//
