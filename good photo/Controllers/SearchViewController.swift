//
//  SearchViewController.swift
//  good photo
//
//  Created by apple on 3/2/19.
//  Copyright © 2019 tonyjiang. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var searchTag: UITextField! //need to take care of keyboard dropping when pressed
    
    @IBAction func searchButtonPressed() {
        
        //UserDefaults.standard.set(["hello"], forKey: "test_tag")
        
        let userSearchTag = searchTag.text!
        
        //test first then actual
        let searchedPhotoArray = UserDefaults.standard.object(forKey: userSearchTag)

        sendAppContainerViewController(for: searchedPhotoArray as! NSMutableArray)
        
    }
    
    //private func sendPhotoListControllerViewController(for photoArray: NSMutableArray) {
    private func sendAppContainerViewController(for photoArray: NSMutableArray) {
        
        
        guard let appContainerVC =
            self.storyboard?.instantiateViewController(withIdentifier: "AppContainerViewController") as? AppContainerViewController else {
                fatalError("AppContainerViewController not found")
        }
        
        appContainerVC.photoArray = photoArray
        self.addChildController(appContainerVC)

        
    }
    
    @IBAction func cameraButtonPressed() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {

            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .camera
            imagePickerVC.delegate = self
            self.present(imagePickerVC, animated: true, completion: nil)

        }
    }
}
