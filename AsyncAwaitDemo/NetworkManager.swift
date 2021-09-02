//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by Vikash Anand on 07/08/21.
//

import Foundation
import UIKit

final class NetworkManager {

    class func execute<T: Decodable>(request: URLRequest,
                                     offlineFileURL: URL?,
                                     completion: @escaping (_ data: T?, _ error: Error?) -> Void) {
        TIAANetworking.execute(request: request, offlineFileURL: offlineFileURL, completion: completion)
    }

    @available(iOS 15.0, *)
    class func execute<T: Decodable>(request: URLRequest,
                                     offlineFileURL: URL?) async throws -> T {
        do {
            return try await withCheckedThrowingContinuation { continuation in

                execute(request: request, offlineFileURL: offlineFileURL) { (data: T?, error: Error?) in

                    guard error != nil else {
                        continuation.resume(throwing: FetchError.badImage)
                        return
                    }

                    guard let unwrappedData = data else {
                        continuation.resume(throwing: FetchError.badData)
                        return
                    }

                    continuation.resume(returning: unwrappedData)
                }
            }
        } catch {
            throw error
        }
    }
}
