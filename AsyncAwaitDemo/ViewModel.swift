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
        let someStructure = SomeStruct()
        someStructure.start()
    }

    // Synchronous method call to fetch an image and return a thumbnail of that image
//    func fetchImage(for filename: String) throws -> UIImage {
//        let image = UIImage(contentsOfFile: filename)
//        guard let unwrappedThumbnailImage = image?.preparingThumbnail(of: CGSize(width: 40, height: 40)) else {
//            throw FetchError.badImage
//        }
//        return unwrappedThumbnailImage
//    }

    //Block based approach
    //Level - 1
    func fetchImage(for id: String,
                    _ completion: @escaping (UIImage?, Error?) -> Void) {

        //Level - 2
        networkHandler.fetchThumbnail(for: id) { image, error in
            guard let unwrappedImage = image else {
                //completion(nil, FetchError.badImage)
                return
            }

            //Level - 3 - Call to one of the block based method provided by UIKit framework
            unwrappedImage.prepareThumbnailPreservingAspectRatio(of: CGSize(width: 40, height: 40)) { thumbnail in
                guard let unwrappedThumbnail = thumbnail else {
                    //completion(nil, FetchError.badImage)
                    return
                }
                completion(unwrappedThumbnail, nil)
            }
        }
    }

    //Async - Await approach
    //Level - 1
    @available(iOS 15.0, *)
    func fetchImage(for id: String) async throws -> UIImage {
        //Level - 2
        let image = try await networkHandler.fetchThumbnail(for: id)
        //Level - 3
        let thumbnailSize: CGSize = .init(width: 40, height: 40)
        let thumbnail = try await prepareThumbnail(from: image, ofSize: thumbnailSize)
        return thumbnail
    }

    @available(iOS 15.0, *)
    private func prepareThumbnail(from image: UIImage, ofSize: CGSize) async throws -> UIImage {
        do {
            return try await withCheckedThrowingContinuation { continuation in

                //System API which can't be changed to async-await syntax, hence it is
                //unwrapped inside 'withCheckedThrowingContinuation'
                //image.preparingThumbnail(of: ofSize)
                image.prepareThumbnail(of: ofSize) { thumbnail in
                    if let unwrappedThumbnail = thumbnail {
                        continuation.resume(returning: unwrappedThumbnail)
                    } else {
                        continuation.resume(throwing: FetchError.badImage)
                    }
                }
            }
        } catch {
            throw error
        }
    }
}

extension ViewModel {
    @available(*, deprecated, message: "Prefer async alternative instead")
    func someMethod(with completionHandler: @escaping(Bool)-> Void) {
        if #available(iOS 15.0, *) {
            Task {
                let result = await someMethod()
                completionHandler(result)
            }
        } else {
            // Fallback on earlier versions
        }
    }

    func someMethod() async -> Bool {
        return true
    }
}
