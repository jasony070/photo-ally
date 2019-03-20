//
//  CustomCameraController.swift
//  good photo
//
//  Created by apple on 3/2/19.
//  Copyright © 2019 tonyjiang. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CustomCameraViewController: UIViewController, UITextFieldDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var seachTagTextField: UITextField!
    
    @IBAction func leftGesture(sender: UISwipeGestureRecognizer) {

        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        if let tagVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TagViewController") as? TagViewController {
            self.view.window!.layer.add(transition, forKey: kCATransition)
            present(tagVC, animated: false, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let tagText = seachTagTextField.text, !tagText.isEmpty else {
            textField.resignFirstResponder()
            return true
        }
        var userSearchTag = seachTagTextField.text!
        userSearchTag = userSearchTag.replacingOccurrences(of: " ", with: "")
        userSearchTag = userSearchTag.lowercased()
        var searchedPhotoArray = UserDefaults.standard.object(forKey: userSearchTag)
       
        if searchedPhotoArray == nil {
            let photoArray = NSMutableArray()
            print("display nil")
            sendAppContainerViewController(for: photoArray)
        } else {
            //print(searchedPhotoArray as? NSMutableArray)
            print("display photos")
            searchedPhotoArray = (searchedPhotoArray as! NSArray).mutableCopy() as! NSMutableArray
            //print(searchedPhotoArray)
            sendAppContainerViewController(for: searchedPhotoArray as! NSMutableArray)
        }
        textField.resignFirstResponder()
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            fatalError("No video device found")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            
            captureSession?.addOutput(capturePhotoOutput!)
            
        } catch {
            print(error)
        }
    }
    
    private func sendAppContainerViewController(for photoArray: NSMutableArray) {
        
        guard let appContainerVC =
            self.storyboard?.instantiateViewController(withIdentifier: "AppContainerViewController") as? AppContainerViewController else {
                fatalError("AppContainerViewController not found")
        }
        
        appContainerVC.photoArray = photoArray
        self.addChildController(appContainerVC)

    }
    
    
    @IBAction func captureButton(_ sender: Any) {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self as! AVCapturePhotoCaptureDelegate)
    }
}

extension CustomCameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        
        // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        
        // Initialise an UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            ImageClassificationViewController().sortPhoto(image: image)
        }
    }
}

