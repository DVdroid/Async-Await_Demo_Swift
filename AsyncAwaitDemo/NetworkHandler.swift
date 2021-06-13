//
//  NetworkHandler.swift
//  AsyncAwaitDemo
//
//  Created by Vikash Anand on 13/06/21.
//

import UIKit

enum FetchError: Error {
    case badImage
}

protocol NetworkProtocol {
    func fetchThumbnail(for id: String, completion: @escaping (UIImage?, Error?) -> Void)
    func fetchThumbnail(for id: String) async throws -> UIImage
}

extension NetworkProtocol {
    func fetchThumbnail(for id: String, completion: @escaping (UIImage?, Error?) -> Void) {
        completion(nil, nil)
    }

    func fetchThumbnail(for id: String) async throws -> UIImage {
        throw FetchError.badImage
    }
}

struct NetworkHandler: NetworkProtocol {

    func fetchThumbnail(for id: String, completion: @escaping (UIImage?, Error?) -> Void) {
        let request = thumbnailURLRequest(for: id)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(nil, error)
            } else {
                guard let image = UIImage(data: data!) else {
                    completion(nil, FetchError.badImage)
                    return
                }

                image.prepareThumbnail(of: CGSize(width: 40, height: 40)) { thumbnail in
                    guard let thumbnail = thumbnail else {
                        completion(nil, FetchError.badImage)
                        return
                    }
                    completion(thumbnail, nil)
                }
            }
        }
        task.resume()
    }

    private func thumbnailURLRequest(for id: String) -> URLRequest {
        let imageUrl = Bundle.main.url(forResource: id, withExtension: "jpeg")!
        return URLRequest(url: imageUrl)
    }
}

extension NetworkHandler {

    func fetchThumbnail(for id: String) async throws -> UIImage {
        let request = thumbnailURLRequest(for: id)
        let (data, _) = try await URLSession.shared.data(for: request)
        let unwrappedImage = UIImage(data: data)
        guard let thumbnail = await unwrappedImage?.thumbnail else { throw FetchError.badImage }
        return thumbnail
    }
}

