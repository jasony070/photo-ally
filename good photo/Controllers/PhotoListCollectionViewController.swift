//
//  PhotoListCollectionViewController.swift
//  good photo
//
//  Created by apple on 3/1/19.
//  Copyright © 2019 tonyjiang. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol PhotoListCollectionViewControllerDelegate {
    func photoListDidSelectImage(selectedImage: UIImage, photo_array: NSMutableArray)
}

class PhotoListControllerViewController: UICollectionViewController {
    //private array storing the images
    var photoArray = NSMutableArray()
    private var images = [PHAsset]()
    var delegate: PhotoListCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populatePhotos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: self.collectionView.bounds.width/2.15, height: self.collectionView.bounds.width/2.15)
        }
    }

    //setting up the collection view
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let asset = self.images[indexPath.row] //image identifier
        let manager = PHImageManager.default()
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true // stop the app
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 320, height: 480), contentMode: .aspectFill, options: options) { (image, _) in
            if let image = image {
                self.delegate?.photoListDidSelectImage(selectedImage: image, photo_array: self.photoArray)
            }
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
            "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else{
            fatalError("PhotoCollectionViewCell was not found")
        }
        
        let asset = self.images[indexPath.row]
        let manager = PHImageManager.default()
        
        //using the manager to retrieve the image
        manager.requestImage(for: asset, targetSize: CGSize(width:100, height: 100),
                             contentMode: .aspectFill, options: nil) {(image, _) in
        
            DispatchQueue.main.async {
                cell.photoImageView.image = image
            }
        }
    
        return cell
    }
    
    
    //standard
    public func requestPermission(completion: @escaping (PHAuthorizationStatus) -> ()){
        
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    private func populatePhotos() {
        
        requestPermission { [weak self] status in
            
            if status == .authorized {
                //assets are all searched photo objects
                //we need to do catch here
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: self?.photoArray as! [String], options: nil)

                assets.enumerateObjects { (object, count, stop) in
                    self?.images.append(object)
                }
                self?.collectionView.reloadData()
                
                //previous code
//                let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
//
//                assets.enumerateObjects { (object, count, stop) in
//                    self?.images.append(object)
//                    // need to catch whether an object is valid or not
//                }
//                self?.images.reverse()
//                self?.collectionView.reloadData()
            }
            
        }
    }
}
