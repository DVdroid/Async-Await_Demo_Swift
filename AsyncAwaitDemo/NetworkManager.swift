//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by Vikash Anand on 07/08/21.
//

import Foundation

final class NetworkManager {

    class func execute<T: Decodable>(request: URLRequest,
                                     offlineFileURL: URL?,
                                     completion: @escaping (_ data: T?, _ error: Error?) -> Void) {
        if #available(iOS 15.0, *) {
        } else {
            TIAANetworking.execute(request: request, offlineFileURL: offlineFileURL, completion: completion)
        }
    }
}
