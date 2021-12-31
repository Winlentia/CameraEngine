//
//  CameraEngineDeviceInput.swift
//  CameraEngine2
//
//  Created by Remi Robert on 01/02/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public enum CameraEngineDeviceInputErrorType: Error {
    case UnableToAddCamera
    case UnableToAddMic
}

class CameraEngineDeviceInput {

    private var cameraDeviceInput: AVCaptureDeviceInput?
    private var micDeviceInput: AVCaptureDeviceInput?
    
    func configureInputCamera(session: AVCaptureSession, device: AVCaptureDevice) throws {
		session.beginConfiguration()
        let possibleCameraInput: AnyObject? = try AVCaptureDeviceInput(device: device)
        if let cameraInput = possibleCameraInput as? AVCaptureDeviceInput {
            if let currentDeviceInput = self.cameraDeviceInput {
                session.removeInput(currentDeviceInput)
            }
            self.cameraDeviceInput = cameraInput
            if let cameraInput = self.cameraDeviceInput {
                if session.canAddInput(cameraInput) {
                    session.addInput(cameraInput)
                }
            }
            
            else {
                throw CameraEngineDeviceInputErrorType.UnableToAddCamera
            }
        }
		session.commitConfiguration()
    }
    
    func configureInputMic(session: AVCaptureSession, device: AVCaptureDevice) throws {
        if self.micDeviceInput != nil {
            return
        }
        try self.micDeviceInput = AVCaptureDeviceInput(device: device)
        if let micDevice = micDeviceInput {
            if session.canAddInput(micDevice) {
                session.addInput(micDevice)
            }
        }
        else {
            throw CameraEngineDeviceInputErrorType.UnableToAddMic
        }
    }
}
