//
//  CameraServer.swift
//  iPhone Client
//
//  Created by Nick Barkas on 2016-02-06.
//  Copyright © 2016 Sarv AI. All rights reserved.
//

import Foundation
import AVFoundation

class CameraServer {
  internal let webServer: GCDWebServer
  private let cameraSession: AVCaptureSession?
  private let imageOutput: AVCaptureStillImageOutput?

  init() {
    webServer = GCDWebServer()
    cameraSession = AVCaptureSession()
    imageOutput = AVCaptureStillImageOutput()

    cameraSession!.sessionPreset = AVCaptureSessionPresetPhoto
    let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    let input: AVCaptureDeviceInput!
    do {
      input = try AVCaptureDeviceInput(device: backCamera)
    } catch _ as NSError {
      input = nil
    }

    if input != nil && cameraSession!.canAddInput(input) {
      cameraSession!.addInput(input)

      imageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
      if cameraSession!.canAddOutput(imageOutput) {
        cameraSession!.addOutput(imageOutput)
        cameraSession!.startRunning()
      }
    }

    webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self) {(request, completionBlock) in
      self.captureImage(completionBlock)
    }
    webServer.startWithPort(8080, bonjourName: "Camera server")
  }

  // Asynchronously captures an image from the camera and invokes the web servers completion block with
  // jpeg data when it's available. We'll instead send the block nil if anything is wrong, which will
  // cause the server to reply with a 500 error.
  func captureImage(completion: GCDWebServerCompletionBlock) {
    if imageOutput == nil {
      // Fail, camera wasn't correctly intialized for some reason
      completion(nil)
      return
    }

    if let videoConnection = imageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
      videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
      imageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
        if (sampleBuffer != nil) {
          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
          completion(GCDWebServerDataResponse(data: imageData, contentType: "image/jpeg"))
        } else {
          // Fail, no data
          completion(nil)
        }
      })
    } else {
      // Fail, couldn't get AVMediaTypeVideo I guess
      completion(nil)
    }
  }
}
