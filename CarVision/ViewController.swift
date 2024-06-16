//
//  ViewController.swift
//  CarVision
//
//  Created by Mariana Dekhtiarenko on 16.06.2024.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let recognizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Recognize", for: .normal)
        button.addTarget(self, action: #selector(recognizeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gray
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(recognizeButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            recognizeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recognizeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            recognizeButton.widthAnchor.constraint(equalToConstant: 200),
            recognizeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc func recognizeButtonTapped() {
        let alert = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.openPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
    }

    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            recognizeCar(in: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func recognizeCar(in image: UIImage) {
        guard let model = try? VNCoreMLModel(for: CarsImgClassifier().model) else {
            fatalError("Could not load model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let results = request.results as? [VNClassificationObservation] {
                if let topResult = results.first {
                    let carModel = topResult.identifier
                    print("Recognized car model: \(carModel)")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Recognition Result", message: "Car: \(carModel)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("Could not convert UIImage to CIImage")
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform request: \(error)")
            }
        }
    }
}

