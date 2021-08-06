//
//  NetworkHandler.swift
//  AsyncAwaitDemo
//
//  Created by Vikash Anand on 13/06/21.
//

import UIKit

enum FetchError: Error {
    case invalidServerResponse
    case badData
    case badImage
}

protocol NetworkProtocol {
    func fetchThumbnail(for id: String, completion: @escaping (UIImage?, Error?) -> Void)
    @available(iOS 15.0, *)
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

    //Block based approach
    func fetchThumbnail(for id: String, completion: @escaping (UIImage?, Error?) -> Void) {
        let request = thumbnailURLRequest(for: id)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(nil, error)
            } else {

//                guard let httpResponse = response as? HTTPURLResponse,
//                      httpResponse.statusCode == 200 else {
//                          //completion(nil, FetchError.invalidServerResponse)
//                          return
//                      }

                guard let unwrappedData = data else {
                    completion(nil, FetchError.badData)
                    return
                }

                completion(UIImage(data: unwrappedData), nil)
            }
        }

        task.resume()
    }

    //Async - Await approach
    @available(iOS 15.0, *)
    func fetchThumbnail(for id: String) async throws -> UIImage {
        let request = thumbnailURLRequest(for: id)
        let (data, _) = try await URLSession.shared.data(for: request)

//        guard let httpResponse = response as? HTTPURLResponse,
//              httpResponse.statusCode == 200 else {
//                 throw FetchError.invalidServerResponse
//              }

        guard let unwrappedThumbnail = UIImage(data: data) else {
            throw FetchError.badImage
        }

        return unwrappedThumbnail
    }
}

extension NetworkHandler {
    private func thumbnailURLRequest(for id: String) -> URLRequest {
        let imageUrl = Bundle.main.url(forResource: id, withExtension: "jpeg")!
        return URLRequest(url: imageUrl)
    }
}

///Assuming - Conversion of following asynchronous function with completion handler will be a
///complex, error prone and time consuming process
///'continuation' can be used to mix and match async function with existing asynchronous function with completion handlers
final class TIAANetworking {}
final class NetworkAdapter {}

extension NetworkAdapter {
    class func sessionTaskWith(with request: URLRequest,
                   completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
}

/*
 class                 function
 TIAANetworking    ->  execute(... ,completion: ...)
 NetworkUtilities  ->  execute(... ,completion: ...)
 NetworkUtilities  ->  baseExecute(... ,completion: ...)
 RestAdapter       ->  sessionTaskWith(... ,completion: ...)
*/
extension TIAANetworking {

    class func execute<T: Decodable>(request: URLRequest,
                                     offlineFileURL: URL?,
                                     completion: @escaping (_ data: T?, _ error: Error?) -> Void) {

        // NetworkAdapter.execute(... ,completion: ...)

        // NetworkAdapter.baseExecute(... ,completion: ...)

        NetworkAdapter.sessionTaskWith(with: request) { data, response, error in

            if let error = error {
                completion(nil, error)
            } else {

                guard let unwrappedData = data else {
                    completion(nil, FetchError.badData)
                    return
                }
                
                let decoder = JSONDecoder()
                do {
                    let modelObject = try decoder.decode(T.self, from: unwrappedData)
                    completion(modelObject, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }

    //Step - 3
    @available(iOS 15.0, *)
    class func execute<T: Decodable>(request: URLRequest,
                                     offlineFileURL: URL?) async throws -> T {

        return try await withCheckedThrowingContinuation { continuation in
            execute(request: request, offlineFileURL: offlineFileURL) { (data: T?, error: Error?) in

                if let error = error {
                    continuation.resume(throwing: error)

                } else {

                    if let unwrappedData = data {
                        continuation.resume(returning: unwrappedData)

                    } else {
                        continuation.resume(throwing: FetchError.badData)
                    }
                }
            }
        }
    }

}


































class SyncClass {
    func rootFunction() { level1Function() }

    func level1Function() { level2Function() }

    func level2Function() { print("Execution done. Return.")}
}
