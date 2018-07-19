//
//  ImageViewController.swift
//  FirestoreStorageSample
//
//  Created by kazuya-miura on 2018/07/19.
//  Copyright © 2018 kazuya-miura. All rights reserved.
//

import UIKit
import Instantiate

class ImageViewController: UIViewController, StoryboardInstantiatable {
    typealias Dependency = Dummy

    private var dummy: Dummy!
    @IBOutlet weak var imageView: UIImageView!

    func inject(_ dependency: Dummy) {
        self.dummy = dependency
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.load(firebaseImageID: dummy.imageRef.documentID, size: .large)
    }
}
