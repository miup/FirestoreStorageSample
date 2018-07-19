//
//  ImagesViewModel.swift
//  FirestoreStorageSample
//
//  Created by kazuya-miura on 2018/07/19.
//  Copyright © 2018 kazuya-miura. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ImagesViewModel {
    private(set) var dummies: [Dummy] = [] {
        didSet {
            imageUpdatedHandler?()
        }
    }

    var imageUpdatedHandler: (() -> Void)? = nil
    private var listenerRegistration: ListenerRegistration?

    init() {
        listenerRegistration = Firestore.firestore()
            .collection("dummy")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] (snapshot, error) in
                if let _ = error { return }
                let dummies = (snapshot?.documents ?? []).map { Dummy(id: $0.documentID, imageRef: $0.data()["image"] as! DocumentReference) }
                self?.dummies = dummies
        }
    }

    deinit {
        listenerRegistration?.remove()
    }
}
