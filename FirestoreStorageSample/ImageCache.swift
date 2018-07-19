//
//  ImageCache.swift
//  FirestoreStorageSample
//
//  Created by kazuya-miura on 2018/07/19.
//  Copyright © 2018 kazuya-miura. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

final class FirebaseImageCache: NSObject {
    private class CacheData {
        var id: String = ""
        var originalFullPath: String?
        var largeRefPath: String?
        var mediumRefPath: String?
        var smallRefPath: String?
        var thumbnailRefPath: String?

        func getRef(of size: Image.Size) -> StorageReference? {
            let path: String?
            switch size {
            case .large:
                path = largeRefPath
            case .medium:
                path = mediumRefPath
            case .small:
                path = smallRefPath
            case .thumbnail:
                path = thumbnailRefPath
            case .original:
                path = originalFullPath
            }
            return path.map(Storage.storage().reference().root().child)
        }
    }

    enum CacheOption {
        case useCache
        case storeCache

        static var `default`: [CacheOption] = [.useCache, .storeCache]
    }

    static let shared = FirebaseImageCache()

    private lazy var cache: NSCache<NSString, CacheData> = {
        let cache = NSCache<NSString, CacheData>()
        cache.name = "sample.firebaseimage.cache"
        cache.countLimit = 200
        return cache
    }()

    private override init() {}

    func retrieveImageReference(imageID: String, of size: Image.Size) -> StorageReference? {
        return cache.object(forKey: imageID as NSString)?.getRef(of: size)
    }

    func setImageReferences(imageID: String, image: Image) {
        let data = CacheData()
        data.id = imageID

        data.originalFullPath = image.originalRefPath
        data.largeRefPath = image.largeRefPath
        data.mediumRefPath = image.mediumRefPath
        data.smallRefPath = image.smallRefPath
        data.thumbnailRefPath = image.thumbnailRefPath
        cache.setObject(data, forKey: imageID as NSString)
    }
}

extension Array where Element == FirebaseImageCache.CacheOption {
    var shouldUseCache: Bool {
        return self.contains(.useCache)
    }

    var shouldStoreCache: Bool {
        return self.contains(.storeCache)
    }
}

extension UIImageView {
    func load(firebaseImageID imageID: String, size: Image.Size) {
        if imageID.isEmpty { return }
        if let storageRef = FirebaseImageCache.shared.retrieveImageReference(imageID: imageID, of: size) {
            load(storageRef)
        } else {
            Firestore.firestore().document("images/\(imageID)").getDocument { [weak self] snapshot, _ in
                guard let snapshot = snapshot else {
                    return
                }
                let image = Image(id: snapshot.documentID, data: snapshot.data()!)
                FirebaseImageCache.shared.setImageReferences(imageID: imageID, image: image)
                if let storageRef = image.getRef(of: size) {
                    self?.load(storageRef)
                }
            }
        }
    }
}
