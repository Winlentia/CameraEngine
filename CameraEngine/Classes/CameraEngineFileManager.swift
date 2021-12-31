//
//  CameraEngineFileManager.swift
//  CameraEngine2
//
//  Created by Remi Robert on 11/02/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import Photos
import ImageIO

public typealias blockCompletionSaveMedia = (_ success: Bool, _ error: Error?) -> (Void)

public class CameraEngineFileManager {
    
    private class func removeItemAtPath(path: String) {
        let filemanager = FileManager.default
        if filemanager.fileExists(atPath: path) {
            do {
                try filemanager.removeItem(atPath: path)
            }
            catch {
                print("[Camera engine] Error remove path :\(path)")
            }
        }
    }
    
    private class func appendPath(rootPath: String, pathFile: String) -> String {
        let destinationPath = rootPath.appending("/\(pathFile)")
        self.removeItemAtPath(path: destinationPath)
        return destinationPath
    }
    
    public class func savePhoto(image: UIImage, blockCompletion: blockCompletionSaveMedia?) {

//        PHPhotoLibrary.shared().performChanges {
//            PHAssetChangeRequest.creationRequestForAsset(from: image)
//        } completionHandler: { success, error in
//            blockCompletionSaveMedia(success,error)
//        }
        
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: blockCompletion)
    }
    
    public class func saveVideo(url: URL, blockCompletion: blockCompletionSaveMedia?) {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }, completionHandler: blockCompletion)
    }
    
    public class func documentPath() -> String? {
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last {
            return path
        }
        return nil
    }
    
    public class func temporaryPath() -> String {
        return NSTemporaryDirectory()
    }
    
    public class func documentPath(file: String) -> URL? {
        if let path = self.documentPath() {
            return URL(fileURLWithPath: self.appendPath(rootPath: path, pathFile: file))
        }
        return nil
    }
    
    public class func temporaryPath(file: String) -> URL? {
        return URL(fileURLWithPath: self.appendPath(rootPath: self.temporaryPath(), pathFile: file))
    }
}
