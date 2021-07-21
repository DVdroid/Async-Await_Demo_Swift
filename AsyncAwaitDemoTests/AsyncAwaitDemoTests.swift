//
//  AsyncAwaitDemoTests.swift
//  AsyncAwaitDemoTests
//
//  Created by Vikash Anand on 13/06/21.
//

import XCTest
@testable import AsyncAwaitDemo

class AsyncAwaitDemoTests: XCTestCase {

    func testFetchThumbnail_Blocks() throws {

        //Given
        struct MockNetworkHandler: NetworkProtocol {
            func fetchThumbnail(for id: String, completion: @escaping (UIImage?, Error?) -> Void) {
                guard let unwrappedImagePath = Bundle.main.path(forResource: "\(id).jpeg", ofType: nil),
                      let image = UIImage(contentsOfFile: unwrappedImagePath) else {
                          completion(nil, FetchError.badImage)
                          return
                      }
                completion(image, nil)
            }
        }

        let vm = ViewModel(with: MockNetworkHandler())
        let expectation = XCTestExpectation(description: "mock thumbnail completion")

        //When
        vm.fetchImage(for: "1") { image, error in

            //Then
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }


    func testFetchThumbnail_AsyncAwait() async throws {

        //Given
        struct MockNetworkHandler: NetworkProtocol {
            func fetchThumbnail(for id: String) async throws -> UIImage {
                guard let unwrappedImagePath = Bundle.main.path(forResource: "\(id).jpeg", ofType: nil),
                      let image = UIImage(contentsOfFile: unwrappedImagePath) else {
                         throw FetchError.badImage
                      }
                return image
            }
        }

        let vm = ViewModel(with: MockNetworkHandler())

        //When
        let result = try await vm.fetchImage(for: "2")

        //Then
        XCTAssertNoThrow(result)

    }
}
