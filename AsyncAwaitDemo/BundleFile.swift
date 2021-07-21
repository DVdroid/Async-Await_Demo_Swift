//
//  Bundle+Extension.swift
//  AsyncAwaitDemo
//
//  Created by Vikash Anand on 24/06/21.
//

import Foundation

enum FileError: Error {
    case missing
}

struct BundleFile {
    let fileName: String

    init(fileName: String) async {
        self.fileName = fileName
    }

    //Only read-only properties can be async
    //Property getters can also throw
    var contents: URL {
        get async throws {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "jpeg") else {
                throw FileError.missing
            }
            return url
        }
    }
}

////Block based code
//struct SomeStruct {
//
//    // Level - 1
//    func someMethod(with completionHandler: @escaping((Bool) -> ())) {
//
//        // Level - 2
//        self.someMethod_1 { boolValue_1 in
//
//            //Level - 3
//            self.someMethod_2 { boolValue_2 in
//                completionHandler(boolValue_1 && boolValue_2)
//            }
//        }
//    }
//
//    private func someMethod_1(with completionHandler: @escaping((Bool) -> ())) {
//        DispatchQueue.global().async {
//            sleep(2)
//            completionHandler(true)
//        }
//    }
//
//    private func someMethod_2(with completionHandler: @escaping((Bool) -> ())) {
//        DispatchQueue.global().async {
//            sleep(2)
//            completionHandler(false)
//        }
//    }
//}


// Synchronous method - Not allowed to suspend
struct SomeStruct {

    // Entry point
    func start() {

        // Step - 1
        // Since synchronous methods are not allowed to suspend so calling a async function within
        // an synchronous will result in an compile time error
        // Task{} - Used for calling async method inside a synchronous method context
        Task {
            let result = await method_1()
            print(result)
        }
    }

    // Step - 2
    private func method_1() async -> Bool {

        // Step - 3
        let value = await method_2()
        return value
    }

    // Step - 4
    private func method_2() async -> Bool {
        return false
    }
}
