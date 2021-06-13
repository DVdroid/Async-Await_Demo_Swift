//
//  ContentView.swift
//  AsyncAwaitDemo
//
//  Created by Vikash Anand on 13/06/21.
//

import SwiftUI

struct ContentView: View {

    let viewModel = ViewModel(with: NetworkHandler())
    var posts: [Post] = [.init(id: "1", title: "Sunrise"),
                         .init(id: "2", title: "Beach"),
                         .init(id: "3", title: "Coffee"),
                         .init(id: "4", title: "Sunset")]

    var body: some View {
        NavigationView {
            List(posts) { post in
                ThumbnailView(viewModel: viewModel, post: post)
            }
            .navigationTitle("Posts")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let posts: [Post] = [.init(id: "1", title: "Sunrise"),
                             .init(id: "2", title: "Beach"),
                             .init(id: "3", title: "Coffee"),
                             .init(id: "4", title: "Sunset")]
        ContentView(posts: posts)
    }
}
