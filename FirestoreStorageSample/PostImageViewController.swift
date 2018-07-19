//
//  PostImageViewController.swift
//  FirestoreStorageSample
//
//  Created by kazuya-miura on 2018/07/19.
//  Copyright © 2018 kazuya-miura. All rights reserved.
//

import UIKit
import Instantiate
import InstantiateStandard

class PostImageViewController: UIViewController, StoryboardInstantiatable {
    private var image: UIImage? {
        didSet {
            postButton?.isEnabled = image != nil
            imageView.image = image
        }
    }

    @IBOutlet weak var postButton: UIButton! {
        didSet {
            postButton.isEnabled = false
        }
    }
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            let gr = UITapGestureRecognizer(target: self, action: #selector(pickImage(_:)))
            imageView.addGestureRecognizer(gr)
        }
    }

    override func viewDidLoad() {
        addNavigationButton()
    }

    private func addNavigationButton() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel(_:)))
        navigationItem.leftBarButtonItem = cancelButton
    }

    @objc func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func pickImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    @IBAction func didTapPost(_ sender: Any) {
        Image.create(image: image!) { [weak self] (image, error) in
            if let error = error { print(error) }
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

extension PostImageViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.image = pickedImage
            return
        }

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = pickedImage
            return
        }
    }
}
