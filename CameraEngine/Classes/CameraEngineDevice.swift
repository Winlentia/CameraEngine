//
//  CameraEngineDevice.swift
//  CameraEngine2
//
//  Created by Remi Robert on 24/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public enum CameraEngineCameraFocus {
    case Locked
    case AutoFocus
    case ContinuousAutoFocus
    
    func foundationFocus() -> AVCaptureDevice.FocusMode {
        switch self {
        case .Locked: return AVCaptureDevice.FocusMode.locked
        case .AutoFocus: return AVCaptureDevice.FocusMode.autoFocus
        case .ContinuousAutoFocus: return AVCaptureDevice.FocusMode.continuousAutoFocus
        }
    }
    
    public func description() -> String {
        switch self {
        case .Locked: return "Locked"
        case .AutoFocus: return "AutoFocus"
        case .ContinuousAutoFocus: return "ContinuousAutoFocus"
        }
    }
    
    public static func availableFocus() -> [CameraEngineCameraFocus] {
        return [
            .Locked,
            .AutoFocus,
            .ContinuousAutoFocus
        ]
    }
}

class CameraEngineDevice {

    private var backCameraDevice: AVCaptureDevice!
    private var frontCameraDevice: AVCaptureDevice!
    var micCameraDevice: AVCaptureDevice!
    var currentDevice: AVCaptureDevice?
    var currentPosition: AVCaptureDevice.Position = .unspecified
    
    func changeCameraFocusMode(focusMode: CameraEngineCameraFocus) {
        if let currentDevice = self.currentDevice {
            do {
                try currentDevice.lockForConfiguration()
                if currentDevice.isFocusModeSupported(focusMode.foundationFocus()) {
                    currentDevice.focusMode = focusMode.foundationFocus()
                }
                currentDevice.unlockForConfiguration()
            }
            catch {
                fatalError("[CameraEngine] error, impossible to lock configuration device")
            }
        }
    }
    
    func changeCurrentZoomFactor(newFactor: CGFloat) -> CGFloat {
        var zoom: CGFloat = 1.0
        if let currentDevice = self.currentDevice {
            do {
                try currentDevice.lockForConfiguration()
                zoom = max(1.0, min(newFactor, currentDevice.activeFormat.videoMaxZoomFactor))
                currentDevice.videoZoomFactor = zoom
                currentDevice.unlockForConfiguration()
            }
            catch {
                zoom = -1.0
                fatalError("[CameraEngine] error, impossible to lock configuration device")
            }
        }
        
        return zoom
    }
    
    func changeCurrentDevice(position: AVCaptureDevice.Position) {
        self.currentPosition = position
        switch position {
        case .unspecified:
            self.currentDevice = nil
        case .back:
            self.currentDevice = self.backCameraDevice
        case .front:
            self.currentDevice = self.frontCameraDevice
        @unknown default:
            self.currentDevice = nil
        }
    }
    
    private func configureDeviceCamera() {
        let availableCameraDevices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in availableCameraDevices {
            if device.position == .back {
                self.backCameraDevice = device
            }
            else if device.position == .front {
                self.frontCameraDevice = device
            }
        }        
    }
    
    private func configureDeviceMic() {
        self.micCameraDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    }
    
    init() {
        self.configureDeviceCamera()
        self.configureDeviceMic()
        self.changeCurrentDevice(position: .back)
    }
}
