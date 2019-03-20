/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller for selecting images and applying Vision + Core ML processing.
*/

import UIKit
import CoreML
import Vision
import ImageIO
import Photos

class ImageClassificationViewController: UIViewController {
    
    func updateClassifications(for image: UIImage) {
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                let model = try VNCoreMLModel(for: Note().model)
                let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                    self?.processClassifications(for: request, image: image, error: error)
                })
                try handler.perform([request])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, image : UIImage, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                if topClassifications[0].identifier == "notes" {
                    let defaults = UserDefaults.standard
                    
                    if let albumId = defaults.string(forKey: "notesAlbumId") {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", albumId)
                        let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions).firstObject
                        PHPhotoLibrary.shared().performChanges({

                            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album!)
                            let assetEnumeration:NSArray = [assetPlaceholder!]
                            albumChangeRequest!.addAssets(assetEnumeration)
                        })
                    } else {
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Notes")
                        }) { success, error in
                            if success {
                                
                                let fetchOptions = PHFetchOptions()
                                fetchOptions.predicate = NSPredicate(format: "title = %@", "Notes")
                                let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                                let album = collection.firstObject
                                UserDefaults.standard.set(album!.localIdentifier, forKey: "notesAlbumId")

                                PHPhotoLibrary.shared().performChanges({
                                    
                                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                                    let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album!)
                                    let assetEnumeration:NSArray = [assetPlaceholder!]
                                    albumChangeRequest!.addAssets(assetEnumeration)
                                    
                                })
                            } else {
                                print("error \(String(describing: error))")
                            }
                        }
                    }
                } else {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
                }
            }
        }
    }
    
    func sortPhoto (image : UIImage) {
        updateClassifications(for: image)
    }
}
