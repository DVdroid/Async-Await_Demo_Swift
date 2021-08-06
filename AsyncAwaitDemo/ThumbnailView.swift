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
    private var placeholder: UIImage { UIImage(named: "placeholder")! }

    var body: some View {
        HStack {
            Image(uiImage: self.image ?? placeholder)
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(80 / 2)
                .onAppear(perform: {
                    ///Task - Used to call an async function in a synchronous function context
                    if #available(iOS 15.0, *) {
                        Task {
                            self.image = try? await self.viewModel.fetchImage(for: post.id)
                        }
                    } else {
                        self.viewModel.fetchImage(for: post.id) { image, error in
                            guard let unwrappedImage = image else { return }
                            self.image = unwrappedImage
                        }
                    }
                })
            Text(post.title)
            NavigationLink("\(post.id)", destination: PostDetailView(post: post))
            Spacer()
        }
    }

    private func loadImages() {
        ///Async - Await approach
        ///Task - Used to call an async function in a synchronous function context
        if #available(iOS 15.0, *) {
            Task {
                self.image = try? await self.viewModel.fetchImage(for: post.id)
            }
        } else {
            // Fallback on earlier versions
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

