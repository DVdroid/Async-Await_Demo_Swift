//
//  ThumbnailView.swift
//  AsyncAwaitDemo
//
//  Created by Vikash Anand on 13/06/21.
//

import SwiftUI

struct ThumbnailView: View {
    @ObservedObject var viewModel: ViewModel
    var post: Post
    @State private var image: UIImage?
    private var isAsyncAwaitFlow: Bool { true }
    private var placeholder: UIImage { UIImage(named: "placeholder")! }

    var body: some View {
        HStack {
            Image(uiImage: self.image ?? placeholder)
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(10.0)
                .onAppear(perform: loadImages)
            Text(post.title)
            Spacer()
        }
    }

    private func loadImages() {
        if isAsyncAwaitFlow {
            print(Thread.isMainThread)
            async {
                print(Thread.isMainThread)
                self.image = try? await self.viewModel.fetchImage(for: post.id)
                print(Thread.isMainThread)
            }
        } else {
            self.viewModel.fetchImage(for: post.id) { result, _ in
                self.image = result
            }
        }
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ViewModel(with: NetworkHandler())
        let post = Post(id: "4", title: "Preview")
        ThumbnailView(viewModel: viewModel, post: post)
    }
}

