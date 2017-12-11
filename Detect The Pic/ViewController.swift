//
//  ViewController.swift
//  Detect The Pic
//
//  Created by admin on 12/10/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    
    let resnetModel = Resnet50()
    var imagePicker = UIImagePickerController()
    var observations : [VNClassificationObservation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        
    }
    
    func processPic(image:UIImage) {
        if let model = try? VNCoreMLModel(for: resnetModel.model) {
            let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    self.observations = results
                    self.tableView.reloadData()
//                    for result in results {
//                        print("ID: \(result.identifier) Confidence: \(result.confidence)")
//                    }
                }
            })
            
            if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            processPic(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func photosTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return observations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let observation = observations[indexPath.row]
        
        cell.textLabel?.text = "ID: \(observation.identifier) Confidence: \(observation.confidence * 100.0)"
        
        return cell
    }
}

