//
//  UIDevice+Ext.swift
//  CameraEngine
//
//  Created by Winlentia on 2.01.2022.
//

import Foundation

extension UIDevice {
    static func orientationTransformation() -> CGFloat {
        switch UIDevice.current.orientation {
        case .portrait: return CGFloat(CGFloat.pi / 2)
        case .portraitUpsideDown: return CGFloat(CGFloat.pi / 4)
        case .landscapeRight: return CGFloat.pi
        case .landscapeLeft: return CGFloat(CGFloat.pi * 2)
        default: return 0
        }
    }
}
