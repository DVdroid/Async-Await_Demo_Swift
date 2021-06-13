//
//  ViewModel.swift
//  AsyncAwaitDemo
//
//  Created by Vikash Anand on 13/06/21.
//

import UIKit

final class ViewModel: ObservableObject {
    let networkHandler: NetworkProtocol
    init(with networkHandler: NetworkProtocol) {
        self.networkHandler = networkHandler
    }

    func fetchImage(for id: String,
                    _ completion: @escaping (UIImage?, Error?) -> Void) {
        networkHandler.fetchThumbnail(for: id, completion: completion)
    }

    func fetchImage(for id: String) async throws -> UIImage {
        let image = try await networkHandler.fetchThumbnail(for: id)
        return image
    }
}

extension UIImage {

    var thumbnail: UIImage? {
        get async {
            let size = CGSize(width: 40, height: 40)
            return await self.byPreparingThumbnail(ofSize: size)
        }
    }
}
