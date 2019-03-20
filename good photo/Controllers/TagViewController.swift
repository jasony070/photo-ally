//
//  TagViewController.swfit.swift
//  good photo
//
//  Created by apple on 3/2/19.
//  Copyright © 2019 tonyjiang. All rights reserved.
//

import Foundation
import UIKit
import Photos

class TagViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tagTextField: UITextField!
    var lastImageID: String!
    
    @IBOutlet weak var selectedPhotoImageView: UIImageView!
    
    @IBAction func rightGesture(sender: UISwipeGestureRecognizer) {
        self.returnToCamera()
    }
    
    @IBAction func taggedPhotoSaveButtonPressed() {
        guard var tagText = tagTextField.text, !tagText.isEmpty else {
            return
        }
        tagText = tagText.replacingOccurrences(of: " ", with: "")
        tagText = tagText.lowercased()
        let tag_photo_array = UserDefaults.standard.object(forKey: tagText)  // as? NSMutableArray
        var photo_array = NSMutableArray()
        if tag_photo_array == nil {
            photo_array.add(self.lastImageID!)
            UserDefaults.standard.set(photo_array, forKey: tagText)
        }
        else {
            let photo_array = (tag_photo_array as! NSArray).mutableCopy() as! NSMutableArray
            if photo_array.contains(self.lastImageID){
            }
            else{
                photo_array.add(self.lastImageID!)
                UserDefaults.standard.set(photo_array, forKey: tagText)
            }
        }
        //UserDefaults.standard.set(photo_array, forKey: tagText)
        returnToCamera()
        let tag_photo_array_after = UserDefaults.standard.object(forKey: tagText)
    }

    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.taggedPhotoSaveButtonPressed()
        textField.resignFirstResponder()
        return true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    private func returnToCamera() {
        
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        if let customCameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomCameraViewController") as? CustomCameraViewController {
            self.view.window!.layer.add(transition, forKey: kCATransition)
            present(customCameraVC, animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //to test whether tag is saved
        displayLastImageTaken()
    }
    
    
    private func displayLastImageTaken() {
        
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        let lastImage = assets.lastObject
        self.lastImageID = lastImage?.localIdentifier
        let manager = PHImageManager.default()
        
        manager.requestImage(for: lastImage!, targetSize: CGSize(width:100, height: 100),
                             contentMode: .aspectFill, options: nil) {(image, _) in
            DispatchQueue.main.async {
                self.selectedPhotoImageView.image = image
            }
        }
        
    }
    
}
