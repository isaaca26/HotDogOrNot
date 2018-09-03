//
//  ViewController.swift
//  HotDogOrNot
//
//  Created by Anand Nigam on 26/07/18.
//  Copyright © 2018 Anand Nigam. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var pictureLabel: UILabel!
    
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self

        imagePicker.allowsEditing = false
    
    }

    // MARK:- Configure Image Picking
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
       if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
        
        // Need to convert image to CIImage(CoreImageImage) to be used by the coreml model
        guard let ciImage = CIImage(image: pickedImage) else {
            fatalError("Could not convert to CIImage")
        }
        
        // To call the CoreML Model function in the background thread
        DispatchQueue.main.async {
             self.detectImage(image: ciImage)
        }
       
        
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK:- CoreML Model Function
    func detectImage( image: CIImage) {
        
        // Loading the Model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading Core ML Model Failed")
        }
        
        // Request to Model to classify the data passed to it
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process the image")
            }
            print(results)
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "HotDog!"
                }
                else {
                    self.navigationItem.title = "Not HotDog!"
                }
                self.pictureLabel.text = firstResult.identifier
            }
            
            
        }
        
        
        // Handler use to complete the process of classifying the image
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request]) }
        catch {
            print(error)
        }
    }
    

    // MARK:- Camera Tapped Actions
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Choose Image Source", message: "", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { ( alertAction) in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            alert.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            alert.addAction(photoLibraryAction)
        }
        
        alert.addAction(cancelAction)
        
        
        
        present(alert, animated: true, completion: nil)

    }
    

}

