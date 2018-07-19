//
//  ImagesViewController.swift
//  FirestoreStorageSample
//
//  Created by kazuya-miura on 2018/07/19.
//  Copyright © 2018 kazuya-miura. All rights reserved.
//

import UIKit
import FirebaseAuth
import Instantiate

class ImagesViewController: UIViewController {
    private static let cellMargin: CGFloat = 1

    private let viewModel = ImagesViewModel()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cellWidth = (view.frame.width - ImagesViewController.cellMargin * 2) / 3
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        layout.minimumLineSpacing = ImagesViewController.cellMargin
        layout.minimumInteritemSpacing = ImagesViewController.cellMargin
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(type: ImageCell.self)
        return collectionView
    }()

    override func loadView() {
        super.loadView()
        view.addSubview(collectionView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationButton()
        if let _ = Auth.auth().currentUser {
            bind()
        } else {
            Auth.auth().signInAnonymously { [weak self] (result, error) in
                self?.bind()
            }
        }

    }

    private func bind() {
        viewModel.imageUpdatedHandler = { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    private func addNavigationButton() {
        let addButton = UIBarButtonItem(title: "add", style: .plain, target: self, action: #selector(didTapAdd(_:)))
        navigationItem.rightBarButtonItem = addButton
    }

    @objc func didTapAdd(_ sender: Any) {
        present(UINavigationController(rootViewController: PostImageViewController.instantiate()), animated: true, completion: nil)
    }
}

extension ImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(viewModel.dummies.count)
        return viewModel.dummies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ImageCell.dequeue(from: collectionView, for: indexPath, with: viewModel.dummies[indexPath.item])
        return cell
    }
}

extension ImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(ImageViewController.instantiate(with: viewModel.dummies[indexPath.item]), animated: true)
    }
}
