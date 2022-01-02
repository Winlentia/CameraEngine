//
//  AVFoundation+Ext.swift
//  CameraEngine
//
//  Created by Winlentia on 2.01.2022.
//

import Foundation
import AVFoundation

extension AVCaptureVideoOrientation {
    static func orientationFromUIDeviceOrientation(orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .portrait: return .portrait
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        case .portraitUpsideDown: return .portraitUpsideDown
        default: return .portrait
        }
    }
}
