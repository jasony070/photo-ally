//
//  AppContainerViewController.swift
//  good photo
//
//  Created by apple on 3/1/19.
//  Copyright © 2019 tonyjiang. All rights reserved.
//

import Foundation
import UIKit
import Photos

class AppContainerViewController: UIViewController,
    PhotoListCollectionViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    var photoArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let photoListCVC = self.children.first as?
            PhotoListControllerViewController else {
            return
        }
        photoListCVC.delegate = self
        photoListCVC.photoArray = self.photoArray
    }
    
    @IBAction func leftGesture(sender: UISwipeGestureRecognizer) {
        
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        if let customCameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomCameraViewController") as? CustomCameraViewController {
            self.view.window!.layer.add(transition, forKey: kCATransition)
            present(customCameraVC, animated: false, completion: nil)
        }
    }
    
    
    func photoListDidSelectImage(selectedImage: UIImage, photo_array: NSMutableArray) {
        showImagePreview(previewImage: selectedImage, photo_array: photo_array)
    }
    
    private func showImagePreview(previewImage: UIImage, photo_array: NSMutableArray) {
        guard let photoPreviewVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoPreviewViewController") as? PhotoPreviewViewController else{
            fatalError("we can't find photopreviewviewcontroller")
        }
        print("hello")
        photoPreviewVC.previewImage = previewImage
        photoPreviewVC.photoArray = photo_array
        self.addChildController(photoPreviewVC)
        
        
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        let originalImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//        showPhotoFilterViewController(for: originalImage)
//        picker.dismiss(animated:true, completion: nil)
//
//    }
    
//    private func showPhotoFilterViewController(for image: UIImage) {
//
//        guard let cameraVC =
//            self.storyboard?.instantiateViewController(withIdentifier:
//                "CameraViewController") as? CameraViewController else {
//                    fatalError("CameraViewController not found")
//        }
//
//        cameraVC.image = image
//        self.addChildController(cameraVC)
//
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
}
