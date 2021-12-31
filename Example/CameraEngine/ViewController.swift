//
//  ViewController.swift
//  CameraEngine2
//
//  Created by Remi Robert on 24/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import FCFileManager
import AVFoundation
import CameraEngine

enum ModeCapture {
    case Photo
    case Video
    case GIF
}

class ViewController: UIViewController {

    let cameraEngine = CameraEngine()
    
    @IBOutlet weak var buttonSwitch: UIButton!
    @IBOutlet weak var buttonTrigger: UIButton!
    @IBOutlet weak var buttonTorch: UIButton!
    @IBOutlet weak var buttonFlash: UIButton!
    @IBOutlet weak var buttonSessionPresset: UIButton!
    @IBOutlet weak var buttonModeCapture: UIButton!
    @IBOutlet weak var labelModeCapture: UILabel!
    @IBOutlet weak var labelDuration: UILabel!
    
    private var currentModeCapture: ModeCapture = .Photo
    private var frames = Array<UIImage>()
    
    @IBAction func changeModeCapture(sender: AnyObject) {
        let alertController = UIAlertController(title: "Mode capture", message: "Change the capture mode photo / video", preferredStyle: UIAlertController.Style.actionSheet)

        alertController.addAction(UIAlertAction(title: "Photo", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            self.labelModeCapture.text = "Photo"
            self.labelDuration.isHidden = true
            self.currentModeCapture = .Photo
        }))
        
        alertController.addAction(UIAlertAction(title: "Video", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            self.labelModeCapture.text = "Video"
            self.currentModeCapture = .Video
        }))
        
        alertController.addAction(UIAlertAction(title: "GIF", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            self.labelModeCapture.text = "GIF"
            self.currentModeCapture = .GIF
            self.frames.removeAll()
            self.labelDuration.text = "5"
        }))

        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeDetectionMode(sender: AnyObject) {
        let detectionCompatible = self.cameraEngine.compatibleDetectionMetadata()
        
        let alertController = UIAlertController(title: "Metadata Detection", message: "Change the metadata detection type", preferredStyle: UIAlertController.Style.actionSheet)
        
        for currentDetectionMode in detectionCompatible {
            alertController.addAction(UIAlertAction(title: currentDetectionMode.description(), style: UIAlertAction.Style.default, handler: { (_) -> Void in
                self.cameraEngine.metadataDetection = currentDetectionMode
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeFocusCamera(sender: AnyObject) {
        let focusCompatible = self.cameraEngine.compatibleCameraFocus()
        
        let alertController = UIAlertController(title: "Camera focus", message: "Change the focus camera mode, compatible with yours device", preferredStyle: UIAlertController.Style.actionSheet)
        
        for currentFocusMode in focusCompatible {
            alertController.addAction(UIAlertAction(title: currentFocusMode.description(), style: UIAlertAction.Style.default, handler: { (_) -> Void in
                self.cameraEngine.cameraFocus = currentFocusMode
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func changePressetCameraPhoto() {
        let pressetCompatible = self.cameraEngine.compatibleSessionPresset()
        
        let alertController = UIAlertController(title: "Session presset", message: "Change the presset of the session, compatible with yours device", preferredStyle: UIAlertController.Style.actionSheet)
        
        for currentPresset in pressetCompatible {
            alertController.addAction(UIAlertAction(title: currentPresset.foundationPreset().rawValue, style: UIAlertAction.Style.default, handler: { (_) -> Void in
                self.cameraEngine.sessionPresset = currentPresset
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func changePressetVideoEncoder() {
        let pressetCompatible = self.cameraEngine.compatibleVideoEncoderPresset()
        
        let alertController = UIAlertController(title: "Video encoder presset", message: "Change the video encoder presset, to change the resolution of the ouput video.", preferredStyle: UIAlertController.Style.actionSheet)
        
        for currentPresset in pressetCompatible {
            alertController.addAction(UIAlertAction(title: currentPresset.description(), style: UIAlertAction.Style.default, handler: { (_) -> Void in
                self.cameraEngine.videoEncoderPresset = currentPresset
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changePressetSession(sender: AnyObject) {
        switch self.currentModeCapture {
        case .Photo, .GIF: self.changePressetCameraPhoto()
        case .Video: self.changePressetVideoEncoder()
        }
    }
    
    @IBAction func changeTorchMode(sender: AnyObject) {
        let alertController = UIAlertController(title: "Torch mode", message: "Change the torch mode", preferredStyle: UIAlertController.Style.actionSheet)

        alertController.addAction(UIAlertAction(title: "On", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            self.cameraEngine.torchMode = .on
        }))
        alertController.addAction(UIAlertAction(title: "Off", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            self.cameraEngine.torchMode = .off
        }))
        alertController.addAction(UIAlertAction(title: "Auto", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            self.cameraEngine.torchMode = .auto
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeFlashMode(sender: AnyObject) {
        let alertController = UIAlertController(title: "Flash mode", message: "Change the flash mode", preferredStyle: UIAlertController.Style.actionSheet)

        alertController.addAction(UIAlertAction(title: "On", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            self.cameraEngine.flashMode = .on
        }))
        alertController.addAction(UIAlertAction(title: "Off", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            self.cameraEngine.flashMode = .off
        }))
        alertController.addAction(UIAlertAction(title: "Auto", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            self.cameraEngine.flashMode = .auto
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func captureVideo() {
        print("record video")
        if self.cameraEngine.isRecording == false {
            guard let url = CameraEngineFileManager.documentPath(file: "video.mp4") else {
                return
            }
            
            self.cameraEngine.startRecordingVideo(url: url, blockCompletion: { (url, error) -> (Void) in
                print("url movie : \(url)")
                
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "previewController")
                
                CameraEngineFileManager.saveVideo(url: url!, blockCompletion: { (success, error) -> (Void) in
                    print("error saving video : \(error)")
                })
                
                (controller as! PreviewViewController).media = Media.Video(url: url!)
                self.present(controller, animated: true, completion: nil)
            })
        }
        else {
            self.cameraEngine.stopRecordingVideo()
        }
    }
    
    private func capturePhoto() {
        self.cameraEngine.capturePhoto { (image: UIImage?, error: Error?) -> (Void) in
            DispatchQueue.main.async {
                if let image = image {
                    
                    if self.currentModeCapture == .GIF {
                        self.frames.append(image)
                        if (self.frames.count == 5) {
                            guard let url = CameraEngineFileManager.documentPath(file: "animated.gif") else {
                                return
                            }
                            self.cameraEngine.createGif(fileUrl: url, frames: self.frames, delayTime: 0.1, completionGif: { (success, url) -> (Void) in
                                if let url = url {
                                    DispatchQueue.main.async {
                                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "previewController")
                                        (controller as! PreviewViewController).media = Media.GIF(url: url)
                                        self.present(controller, animated: true, completion: nil)
                                        self.frames.removeAll()
                                        self.labelModeCapture.text = "0"
                                    }
                                }
                            })
                            return
                        }
                        self.labelModeCapture.isHidden = false
                        self.labelModeCapture.text = "\(5 - self.frames.count)"
                    }
                    else {
                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "previewController")
                        
                        CameraEngineFileManager.savePhoto(image: image, blockCompletion: { (success, error) -> (Void) in
                            print("error save image : \(error)")
                        })
                        
                        (controller as! PreviewViewController).media = Media.Photo(image: image)
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func capturePhoto(sender: AnyObject) {
        switch self.currentModeCapture {
        case .Photo, .GIF: self.capturePhoto()
        case .Video: self.captureVideo()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event!.allTouches?.first {
            let position = touch.location(in: self.view)
            self.cameraEngine.focus(atPoint: position)
        }
    }
    
    @IBAction func switchCamera(sender: AnyObject) {
        self.cameraEngine.switchCurrentDevice()
    }
    
    override func viewDidLayoutSubviews() {
        let layer = self.cameraEngine.previewLayer
        
        layer!.frame = self.view.bounds
        self.view.layer.insertSublayer(layer!, at: 0)
        self.view.layer.insertSublayer(layer!, at: 0)
        self.view.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        self.labelDuration.isHidden = true
        
        self.cameraEngine.startSession()
        cameraEngine.sessionPresset = .photo
        
        self.cameraEngine.blockCompletionProgress = { progress in
            DispatchQueue.main.async {
                self.labelDuration.isHidden = false
                self.labelDuration.text = "\(progress)"
            }
            print("progress duration : \(progress)")
        }
        
        self.cameraEngine.blockCompletionFaceDetection = { faceObject in
            print("face Object")
            
            (faceObject as AVMetadataObject).bounds
        }
        
        self.cameraEngine.blockCompletionCodeDetection = { codeObject in
            print("code object value : \(codeObject.stringValue)")
        }
        
        let twoFingerPinch = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.onTwoFingerPinch(recognizer:)))
        self.view.addGestureRecognizer(twoFingerPinch)
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cameraEngine.rotationCamera = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        cameraEngine.rotationCamera = false
    }
    
    @objc func onTwoFingerPinch(recognizer: UIPinchGestureRecognizer) {
        let maxZoom: CGFloat = 6.0
        let pinchVelocityDividerFactor: CGFloat = 5.0
        if recognizer.state == .changed {
            let desiredZoomFactor = min(maxZoom, cameraEngine.cameraZoomFactor + atan2(recognizer.velocity, pinchVelocityDividerFactor))
            cameraEngine.cameraZoomFactor = desiredZoomFactor
        }
    }
}
