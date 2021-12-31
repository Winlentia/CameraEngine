//
//  CameraEngineMetadataOutput.swift
//  CameraEngine2
//
//  Created by Remi Robert on 03/02/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public typealias blockCompletionDetectionFace = (_ faceObject: AVMetadataFaceObject) -> (Void)
public typealias blockCompletionDetectionCode = (_ codeObject: AVMetadataMachineReadableCodeObject) -> (Void)

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

class CameraEngineMetadataOutput: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    private var metadataOutput:AVCaptureMetadataOutput?
    private var currentMetadataOutput: CameraEngineCaptureOutputDetection = .none
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var blockCompletionFaceDetection: blockCompletionDetectionFace?
    var blockCompletionCodeDetection: blockCompletionDetectionCode?
    
    var shapeLayer = CAShapeLayer()
    var layer2 = CALayer()
    
    func configureMetadataOutput(session: AVCaptureSession, sessionQueue: DispatchQueue, metadataType: CameraEngineCaptureOutputDetection) {
        if self.metadataOutput == nil {
            self.metadataOutput = AVCaptureMetadataOutput()
            self.metadataOutput?.setMetadataObjectsDelegate(self, queue: sessionQueue)
            if let metadataOutput = self.metadataOutput {
                if session.canAddOutput(metadataOutput) {
                    session.addOutput(metadataOutput)
                }
            }
            
        }
        self.metadataOutput!.metadataObjectTypes = metadataType.foundationCaptureOutputDetection()
        self.currentMetadataOutput = metadataType
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        guard let previewLayer = self.previewLayer else {
            return
        }
        
        for metadataObject in metadataObjects as! [AVMetadataObject] {
            switch metadataObject.type {
            case AVMetadataObject.ObjectType.face:
                if let block = self.blockCompletionFaceDetection, self.currentMetadataOutput == .face {
                    let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject)
                    block(transformedMetadataObject as! AVMetadataFaceObject)
                }
            case AVMetadataObject.ObjectType.qr:
                if let block = self.blockCompletionCodeDetection, self.currentMetadataOutput == .qrCode {
                    let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject)
                    block(transformedMetadataObject as! AVMetadataMachineReadableCodeObject)
                }
//            case AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode:
//                if let block = self.blockCompletionCodeDetection where self.currentMetadataOutput == .BareCode {
//                    let transformedMetadataObject = previewLayer.transformedMetadataObjectForMetadataObject(metadataObject)
//                    block(codeObject: transformedMetadataObject as! AVMetadataMachineReadableCodeObject)
//                }
            default:break
            }
        }
    }
}
