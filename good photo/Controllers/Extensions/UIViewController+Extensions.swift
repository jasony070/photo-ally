//
//  UIViewController+Extensions.swift
//  good photo
//
//  Created by apple on 3/1/19.
//  Copyright © 2019 tonyjiang. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func addChildController(_ childVC: UIViewController){
        
        self.addChild(childVC)
        childVC.view.frame = self.view.frame
        self.view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
        
    }
}
