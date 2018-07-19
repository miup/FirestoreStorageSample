//
//  ImageCell.swift
//  FirestoreStorageSample
//
//  Created by kazuya-miura on 2018/07/19.
//  Copyright © 2018 kazuya-miura. All rights reserved.
//

import UIKit
import Instantiate
import ImageStore

class ImageCell: UICollectionViewCell, Reusable, NibType {
    typealias Dependency = Dummy

    private var id: String?

    @IBOutlet private weak var imageView: UIImageView!

    func inject(_ dependency: Dummy) {
        id = dependency.id
        imageView.load(firebaseImageID: dependency.imageRef.documentID, size: .small)
//        dependency.getImage{ [weak self] (image, error) in
//            if let _ = error { return }
//            self?.imageView.load(image!.getRef(of: .small)!) { self?.id == dependency.id }
//        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        id = nil
        imageView.image = nil
    }
}
