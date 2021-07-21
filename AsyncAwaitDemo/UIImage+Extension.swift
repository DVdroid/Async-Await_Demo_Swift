//
//  UIImage+Extension.swift
//  AsyncAwaitDemo
//
//  Created by Vikash Anand on 24/06/21.
//

import UIKit

extension UIImage {

    //Async property
    var thumbnail: UIImage? {
        get async {
            let size = CGSize(width: 40, height: 40)
            return await byPreparingThumbnail(ofSize: size)
        }
    }
}
