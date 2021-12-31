//
//  CameraEngineCaptureOutput.swift
//  CameraEngine2
//
//  Created by Remi Robert on 24/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public typealias blockCompletionCapturePhoto = (_ image: UIImage?, _ error: Error?) -> (Void)
public typealias blockCompletionCapturePhotoBuffer = (_ sampleBuffer: CMSampleBuffer?, _ error: Error?) -> (Void)
public typealias blockCompletionCaptureVideo = (_ url: URL?, _ error: Error?) -> (Void)
public typealias blockCompletionOutputBuffer = (_ sampleBuffer: CMSampleBuffer) -> (Void)
public typealias blockCompletionProgressRecording = (_ duration: Float64) -> (Void)

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

class CameraEngineCaptureOutput: NSObject {
    
    private let stillCameraOutput = AVCaptureStillImageOutput()
    private let movieFileOutput = AVCaptureMovieFileOutput()
    private var captureVideoOutput = AVCaptureVideoDataOutput()
    private var captureAudioOutput = AVCaptureAudioDataOutput()
    private var blockCompletionVideo: blockCompletionCaptureVideo?
    
    private let videoEncoder = CameraEngineVideoEncoder()
    
    var isRecording = false
    var blockCompletionBuffer: blockCompletionOutputBuffer?
    var blockCompletionProgress: blockCompletionProgressRecording?
	
    func capturePhotoBuffer(blockCompletion: @escaping blockCompletionCapturePhotoBuffer) {
        guard let connectionVideo  = self.stillCameraOutput.connection(with: AVMediaType.video) else {
            blockCompletion(nil, nil)
			return
		}
        connectionVideo.videoOrientation = AVCaptureVideoOrientation.orientationFromUIDeviceOrientation(orientation: UIDevice.current.orientation)
		
        self.stillCameraOutput.captureStillImageAsynchronously(from: connectionVideo) { buffer, error in
            blockCompletion(buffer,error)
        }
    }
	
    func capturePhoto(blockCompletion: @escaping blockCompletionCapturePhoto) {
        guard let connectionVideo  = self.stillCameraOutput.connection(with: AVMediaType.video) else {
            blockCompletion(nil, nil)
            return
        }
        connectionVideo.videoOrientation = AVCaptureVideoOrientation.orientationFromUIDeviceOrientation(orientation: UIDevice.current.orientation)
        
        
        self.stillCameraOutput.captureStillImageAsynchronously(from: connectionVideo) { buffer, error in
            if let err = error {
                blockCompletion(nil,err)
            } else {
                if let sampleBuffer = buffer, let dataImage = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) {
                    let image = UIImage(data: dataImage)
                    blockCompletion(image,nil)
                }
                else {
                    blockCompletion(nil, nil)
                }
            }
        }
    }
    
    func setPressetVideoEncoder(videoEncoderPresset: CameraEngineVideoEncoderEncoderSettings) {
        self.videoEncoder.presetSettingEncoder = videoEncoderPresset.configuration()
    }
    
    func startRecordVideo(blockCompletion: @escaping blockCompletionCaptureVideo, url: URL) {
        if self.isRecording == false {
            self.videoEncoder.startWriting(url: url)
            self.isRecording = true
        }
        else {
            self.isRecording = false
            self.stopRecordVideo()
        }
        self.blockCompletionVideo = blockCompletion
    }
    
    func stopRecordVideo() {
        self.isRecording = false
        self.videoEncoder.stopWriting(blockCompletion: self.blockCompletionVideo)
    }
    
    func configureCaptureOutput(session: AVCaptureSession, sessionQueue: DispatchQueue) {
        if session.canAddOutput(self.captureVideoOutput) {
            session.addOutput(self.captureVideoOutput)
            self.captureVideoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        }
        if session.canAddOutput(self.captureAudioOutput) {
            session.addOutput(self.captureAudioOutput)
            self.captureAudioOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        }
        if session.canAddOutput(self.stillCameraOutput) {
            session.addOutput(self.stillCameraOutput)
        }
        
    }
}

extension CameraEngineCaptureOutput: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    private func progressCurrentBuffer(sampleBuffer: CMSampleBuffer) {
        if let block = self.blockCompletionProgress, self.isRecording {
            block(self.videoEncoder.progressCurrentBuffer(sampleBuffer: sampleBuffer))
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        self.progressCurrentBuffer(sampleBuffer: sampleBuffer)
        if let block = self.blockCompletionBuffer {
            block(sampleBuffer)
        }
        if CMSampleBufferDataIsReady(sampleBuffer) == false || self.isRecording == false {
            return
        }
        if captureOutput == self.captureVideoOutput {
            self.videoEncoder.appendBuffer(sampleBuffer: sampleBuffer, isVideo: true)
        }
        else if captureOutput == self.captureAudioOutput {
            self.videoEncoder.appendBuffer(sampleBuffer: sampleBuffer, isVideo: false)
        }
    }
}

extension CameraEngineCaptureOutput: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("end recording video ... \(outputFileURL)")
        print("error : \(error)")
        if let blockCompletionVideo = self.blockCompletionVideo {
            blockCompletionVideo(outputFileURL, error)
        }
    }
    
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: URL!, fromConnections connections: [AnyObject]!) {
        print("start recording ...")
    }
    
}
