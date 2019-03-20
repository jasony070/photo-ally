//
//  PhotoPreviewViewController.swift
//  good photo
//
//  Created by apple on 3/1/19.
//  Copyright © 2019 tonyjiang. All rights reserved.
//

import Foundation
import UIKit

class PhotoPreviewViewController: UIViewController {
    
    var photoArray = NSMutableArray()
    @IBOutlet weak var photoImageView: UIImageView!
    var previewImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoImageView.image = self.previewImage
    }
    
    @IBAction func leftGesture(sender: UISwipeGestureRecognizer) {
        
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        if let appContainerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppContainerViewController") as? AppContainerViewController {
            self.view.window!.layer.add(transition, forKey: kCATransition)
            appContainerVC.photoArray = photoArray
            present(appContainerVC, animated: false, completion: nil)
        }
        
    }
    
}
