//
//  CameraEngineVideoEncoder.swift
//  CameraEngine2
//
//  Created by Remi Robert on 11/02/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

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

class CameraEngineVideoEncoder {
    
    private var assetWriter: AVAssetWriter!
    private var videoInputWriter: AVAssetWriterInput!
    private var audioInputWriter: AVAssetWriterInput!
    private var startTime: CMTime!
    
    lazy var presetSettingEncoder: AVOutputSettingsAssistant? = {
        return CameraEngineVideoEncoderEncoderSettings.preset1920x1080.configuration()
    }()
    
    private func initVideoEncoder(url: URL) {
        guard let presetSettingEncoder = self.presetSettingEncoder else {
            print("[Camera engine] presetSettingEncoder = nil")
            return
        }

        do {
            self.assetWriter = try AVAssetWriter(outputURL: url, fileType: AVFileType.mp4)
        }
        catch {
            fatalError("error init assetWriter")
        }
        
        let videoOutputSettings = presetSettingEncoder.videoSettings
        let audioOutputSettings = presetSettingEncoder.audioSettings
        
        guard self.assetWriter.canApply(outputSettings: videoOutputSettings, forMediaType: AVMediaType.video) else {
            fatalError("Negative [VIDEO] : Can't apply the Output settings...")
        }
        guard self.assetWriter.canApply(outputSettings: audioOutputSettings, forMediaType: AVMediaType.audio) else {
            fatalError("Negative [AUDIO] : Can't apply the Output settings...")
        }

        self.videoInputWriter = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        self.videoInputWriter.expectsMediaDataInRealTime = true
        self.videoInputWriter.transform = CGAffineTransform(rotationAngle: UIDevice.orientationTransformation())
        
        self.audioInputWriter = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        self.audioInputWriter.expectsMediaDataInRealTime = true
        
        if self.assetWriter.canAdd(self.videoInputWriter) {
            self.assetWriter.add(self.videoInputWriter)
        }
        if self.assetWriter.canAdd(self.audioInputWriter) {
            self.assetWriter.add(self.audioInputWriter)
        }
    }
    
    func startWriting(url: URL) {
        self.startTime = CMClockGetTime(CMClockGetHostTimeClock())
        self.initVideoEncoder(url: url)
    }
    
    func stopWriting(blockCompletion: blockCompletionCaptureVideo?) {
        self.videoInputWriter.markAsFinished()
        self.audioInputWriter.markAsFinished()
        
        self.assetWriter.finishWriting { () -> Void in
            if let blockCompletion = blockCompletion {
                blockCompletion(self.assetWriter.outputURL, nil)
            }
        }
    }
    
    func appendBuffer(sampleBuffer: CMSampleBuffer!, isVideo: Bool) {
	
	if CMSampleBufferDataIsReady(sampleBuffer) {
        if self.assetWriter.status == AVAssetWriter.Status.unknown {
                let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                self.assetWriter.startWriting()
            self.assetWriter.startSession(atSourceTime: startTime)
	    }
            if isVideo {
                if self.videoInputWriter.isReadyForMoreMediaData {
                    self.videoInputWriter.append(sampleBuffer)
                }
            }
            else {
                if self.audioInputWriter.isReadyForMoreMediaData {
                    self.audioInputWriter.append(sampleBuffer)
                }
            }
	}
    }
    
    func progressCurrentBuffer(sampleBuffer: CMSampleBuffer) -> Float64 {
        let currentTimestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let currentTime = CMTimeGetSeconds(CMTimeSubtract(currentTimestamp, self.startTime))
        return currentTime
    }
}
