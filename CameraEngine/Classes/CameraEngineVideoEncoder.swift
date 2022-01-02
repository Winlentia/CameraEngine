//
//  CameraEngineVideoEncoder.swift
//  CameraEngine2
//
//  Created by Remi Robert on 11/02/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation




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
