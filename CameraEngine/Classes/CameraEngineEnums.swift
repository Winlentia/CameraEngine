//
//  CameraEngineEnums.swift
//  CameraEngine
//
//  Created by Winlentia on 2.01.2022.
//

import Foundation
import AVFoundation

public enum CameraEngineSessionPreset {
    case photo
    case high
    case medium
    case low
    case res352x288
    case res640x480
    case res1280x720
    case res1920x1080
    case res3840x2160
    case frame960x540
    case frame1280x720
    case inputpriority
    
    public func foundationPreset() -> AVCaptureSession.Preset {
        switch self {
        case .photo: return AVCaptureSession.Preset.photo
        case .high: return AVCaptureSession.Preset.high
        case .medium: return AVCaptureSession.Preset.medium
        case .low: return AVCaptureSession.Preset.low
        case .res352x288: return AVCaptureSession.Preset.cif352x288
        case .res640x480: return AVCaptureSession.Preset.vga640x480
        case .res1280x720: return AVCaptureSession.Preset.hd1280x720
        case .res1920x1080: return AVCaptureSession.Preset.hd1920x1080
        case .res3840x2160:
            if #available(iOS 9.0, *) {
                return AVCaptureSession.Preset.hd4K3840x2160
            }
            else {
                return AVCaptureSession.Preset.photo
            }
        case .frame960x540: return AVCaptureSession.Preset.iFrame960x540
        case .frame1280x720: return AVCaptureSession.Preset.iFrame1280x720
        default: return AVCaptureSession.Preset.photo
        }
    }
    
    public static func availablePresset() -> [CameraEngineSessionPreset] {
        return [
            .photo,
            .high,
            .medium,
            .low,
            .res352x288,
            .res640x480,
            .res1280x720,
            .res1920x1080,
            .res3840x2160,
            .frame960x540,
            .frame1280x720,
            .inputpriority
        ]
    }
}


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

public enum CameraEngineDeviceInputErrorType: Error {
    case UnableToAddCamera
    case UnableToAddMic
}

public enum CameraEngineCaptureOutputDetection {
    case face
    case qrCode
    case bareCode
    case none
    
    func foundationCaptureOutputDetection() -> [AVMetadataObject.ObjectType] {
        switch self {
        case .face: return [AVMetadataObject.ObjectType.face]
        case .qrCode: return [AVMetadataObject.ObjectType.qr]
        case .bareCode: return [
            AVMetadataObject.ObjectType.upce,
            AVMetadataObject.ObjectType.code39,
            AVMetadataObject.ObjectType.code128
//            AVMetadataObject.ObjectType.code39
//            AVMetadataObject.ObjectType.code39
//            AVMetadataObject.ObjectType.code39
//            AVMetadataObject.ObjectType.code39
//            AVMetadataObject.ObjectType.code39
//            AVMetadataObjectTypeCode39Mod43Code,
//            AVMetadataObjectTypeEAN13Code,
//            AVMetadataObjectTypeEAN8Code,
//            AVMetadataObjectTypeCode93Code,
//            AVMetadataObjectTypeCode128Code,
//            AVMetadataObjectTypePDF417Code,
//            AVMetadataObjectTypeQRCode,
//            AVMetadataObjectTypeAztecCode
            ]
        case .none: return []
        }
    }
    
    public static func availableDetection() -> [CameraEngineCaptureOutputDetection] {
        return [
            .face,
            .qrCode,
            .bareCode,
            .none
        ]
    }
    
    public func description() -> String {
        switch self {
        case .face: return "Face detection"
        case .qrCode: return "QRCode detection"
        case .bareCode: return "BareCode detection"
        case .none: return "No detection"
        }
    }
}

public enum CameraEngineVideoEncoderEncoderSettings: String {
    case preset640x480
    case preset960x540
    case preset1280x720
    case preset1920x1080
    case preset3840x2160
    case unknow
    
    private func avFoundationPresetString() -> AVOutputSettingsPreset? {
        switch self {
        case .preset640x480: return AVOutputSettingsPreset.preset640x480
        case .preset960x540: return AVOutputSettingsPreset.preset960x540
        case .preset1280x720: return AVOutputSettingsPreset.preset1280x720
        case .preset1920x1080: return AVOutputSettingsPreset.preset1920x1080
        case .preset3840x2160:
            if #available(iOS 9.0, *) {
                return AVOutputSettingsPreset.preset3840x2160
            }
            else {
                return nil
            }
        case .unknow: return nil
        }
    }
    
    func configuration() -> AVOutputSettingsAssistant? {
        if let presetSetting = self.avFoundationPresetString() {
            return AVOutputSettingsAssistant(preset: presetSetting)
        }
        return nil
    }
    
    public static func availableFocus() -> [CameraEngineVideoEncoderEncoderSettings] {
        return AVOutputSettingsAssistant.availableOutputSettingsPresets().map {
            if #available(iOS 9.0, *) {
                switch $0 {
                case AVOutputSettingsPreset.preset640x480: return .preset640x480
                case AVOutputSettingsPreset.preset960x540: return .preset960x540
                case AVOutputSettingsPreset.preset1280x720: return .preset1280x720
                case AVOutputSettingsPreset.preset1920x1080: return .preset1920x1080
                case AVOutputSettingsPreset.preset3840x2160: return .preset3840x2160
                default: return .unknow
                }
            }
            else {
                switch $0 {
                case AVOutputSettingsPreset.preset640x480: return .preset640x480
                case AVOutputSettingsPreset.preset960x540: return .preset960x540
                case AVOutputSettingsPreset.preset1280x720: return .preset1280x720
                case AVOutputSettingsPreset.preset1920x1080: return .preset1920x1080
                default: return .unknow
                }
            }
        }
    }
    
    public func description() -> String {
        switch self {
        case .preset640x480: return "preset 640x480"
        case .preset960x540: return "preset 960x540"
        case .preset1280x720: return "preset 1280x720"
        case .preset1920x1080: return "preset 1920x1080"
        case .preset3840x2160: return "preset 3840x2160"
        case .unknow: return "preset unknow"
        }
    }
}
