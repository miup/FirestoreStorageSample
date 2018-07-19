//
//  Image.swift
//  FirestoreStorageSample
//
//  Created by kazuya-miura on 2018/07/19.
//  Copyright © 2018 kazuya-miura. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

class Image {
    enum Size {
        case large
        case medium
        case small
        case thumbnail
        case original
    }

    static func create(image: UIImage, completion: ((Image?, Error?) -> Void)? = nil) {
        let newImageRef = Firestore.firestore().collection("/images").document()
        let fileName = "\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
        let storageRefPath = "images/\(newImageRef.documentID)/\(fileName)"
        saveData(UIImageJPEGRepresentation(image, 0.75)!, path: storageRefPath) { (_, error) in
            if let error = error { completion?(nil, error); return }
            let batch = Firestore.firestore().batch()
            let image = Image(id: newImageRef.documentID, originalRefPath: storageRefPath, fileName: fileName)
            batch.setData([
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp(),
                "originalRefPath": storageRefPath,
                "fileName": fileName], forDocument: newImageRef)

            let newDummyRef = Firestore.firestore().collection("/dummy").document()
            batch.setData([
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp(),
                "image": newImageRef], forDocument: newDummyRef)

            batch.commit { error in
                if let error = error { completion?(nil, error); return }
                completion?(image, nil)
            }
        }
    }

    private static func saveData(_ data: Data, path: String, completion: ((StorageMetadata?, Error?) -> Void)? = nil) {
        let refPath = Storage.storage().reference(withPath: path)
        refPath.putData(data, metadata: nil) { (metadata, error) in
            completion?(metadata, error)
        }
    }

    let id: String
    let originalRefPath: String
    let fileName: String
    let thumbnailRefPath: String?
    let smallRefPath: String?
    let mediumRefPath: String?
    let largeRefPath: String?

    init(id: String, data: [String: Any]) {
        self.id = id
        self.originalRefPath = data["originalRefPath"] as! String
        self.fileName = data["fileName"] as! String
        self.thumbnailRefPath = data["thumbnailRefPath"] as? String
        self.smallRefPath = data["thumbnailRefPath"] as? String
        self.mediumRefPath = data["mediumRefPath"] as? String
        self.largeRefPath = data["largeRefPath"] as? String
    }

    init(id: String, originalRefPath: String, fileName: String) {
        self.id = id
        self.originalRefPath = originalRefPath
        self.fileName = fileName
        self.thumbnailRefPath = nil
        self.smallRefPath = nil
        self.mediumRefPath = nil
        self.largeRefPath = nil
    }

    func getRef(of size: Size) -> StorageReference? {
        let path: String?
        switch size {
        case .large:
            path = [largeRefPath, mediumRefPath, smallRefPath, thumbnailRefPath, originalRefPath].compactMap { $0 }.first
        case .medium:
            path = [mediumRefPath, largeRefPath, smallRefPath, thumbnailRefPath, originalRefPath].compactMap { $0 }.first
        case .small:
            path = [smallRefPath, mediumRefPath, largeRefPath, thumbnailRefPath, originalRefPath].compactMap { $0 }.first
        case .thumbnail:
            path = [thumbnailRefPath, smallRefPath, mediumRefPath, largeRefPath, originalRefPath].compactMap { $0 }.first
        case .original:
            path = originalRefPath
        }
        guard let refPath = path else { return nil }
        return Storage.storage().reference().root().child(refPath)
    }
}
