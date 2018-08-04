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
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
       if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
        
        guard let ciImage = CIImage(image: pickedImage) else {
            fatalError("Could not convert to CIImage")
        }
        
        detectImage(image: ciImage)
        
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    
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
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "HotDog!"
                    
                }
                else {
                    self.navigationItem.title = "Not HotDog!"
                }
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
    

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)

    }
    

}

