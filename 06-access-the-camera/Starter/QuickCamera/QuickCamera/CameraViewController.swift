//
//  CameraViewController.swift
//  QuickCamera
//
//  Created by 🤨 on 1/04/21.
//

import UIKit
import AVFoundation
import os

class CameraViewController: UIViewController {
  let logger = Logger(subsystem: "com.dserweb.camera", category: "camera")

  let captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  var activeInput: AVCaptureDeviceInput!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSession()
    setupPreview()
    startSession()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    stopSession()
  }
  
  func setupSession() {
    captureSession.beginConfiguration()
    guard let camera = AVCaptureDevice.default(for: .video),
          let mic = AVCaptureDevice.default(for: .audio) else { return }
    do {
      let videoInput = try AVCaptureDeviceInput(device: camera)
      let audioInput = try AVCaptureDeviceInput(device: mic)
      for input in [videoInput, audioInput] {
        if captureSession.canAddInput(input) {
          captureSession.addInput(input)
        }
      }
      activeInput = videoInput
    } catch {
      logger.error("Error setting device input: \(error.localizedDescription)")
      return
    }
    captureSession.commitConfiguration()
  }
  
  func setupPreview() {
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.bounds
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    view.layer.addSublayer(previewLayer)
  }
  
  func startSession() {
    if !captureSession.isRunning {
      DispatchQueue.global(qos: .default).async {
        [weak self] in
        self?.captureSession.startRunning()
      }
    }
  }
  
  func stopSession() {
    if captureSession.isRunning {
      DispatchQueue.global(qos: .default).async {
        [weak self] in
        self?.captureSession.stopRunning()
      }
    }
  }
  
  func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
    let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
    let devices = discovery.devices.filter { $0.position == position }
    return devices.first
  }
  
  public func switchCamera() {
    let position: AVCaptureDevice.Position = (activeInput.device.position == .back) ? .front : .back
    guard let device = camera(for: position) else { return }
    captureSession.beginConfiguration()
    captureSession.removeInput(activeInput)
    do {
      activeInput = try AVCaptureDeviceInput(device: device)
    } catch {
      logger.error("\(error.localizedDescription)")
      return
    }
    captureSession.addInput(activeInput)
    captureSession.commitConfiguration()
  }
}
