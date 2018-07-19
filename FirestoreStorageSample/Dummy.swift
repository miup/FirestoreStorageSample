//
//  Dummy.swift
//  FirestoreStorageSample
//
//  Created by kazuya-miura on 2018/07/19.
//  Copyright © 2018 kazuya-miura. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Dummy {
    let id: String
    let imageRef: DocumentReference

    init(id: String, imageRef: DocumentReference) {
        self.id = id
        self.imageRef = imageRef
    }

    func getImage(completion: ((Image?, Error?) -> Void)?) {
        imageRef.getDocument { (snapshot, error) in
            if let error = error { completion?(nil, error); return }
            let image = Image(id: snapshot!.documentID, data: snapshot!.data()!)
            completion?(image, nil)
        }
    }
}
