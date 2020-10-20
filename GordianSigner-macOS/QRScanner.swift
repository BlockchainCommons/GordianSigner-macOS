//
//  QRScanner.swift
//  GordianSigner-macOS
//
//  Created by Peter on 10/15/20.
//  Copyright © 2020 Blockchain Commons. All rights reserved.
//

import Cocoa
import AVFoundation
import URKit
import CoreImage

class QRScanner: NSViewController {
    
    var doneBlock: ((String?) -> Void)?
    var decoder: URDecoder!
    var window: NSWindow?
    var avCaptureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var timer: Timer?
    
    @IBOutlet weak private var imageView: NSImageView!
    @IBOutlet weak private var completionLabel: NSTextField!
    @IBOutlet weak private var progressView: NSProgressIndicator!
    @IBOutlet weak private var backgroundView: NSVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completionLabel.stringValue = ""
        progressView.alphaValue = 0
        progressView.doubleValue = 0.0
        progressView.minValue = 0.0
        progressView.maxValue = 1.0
        backgroundView.alphaValue = 0
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = 8
        decoder = URDecoder()
        
        avCaptureSession = AVCaptureSession()
        avCaptureSession.sessionPreset = AVCaptureSession.Preset.photo
        cameraOutput = AVCapturePhotoOutput()

        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else { return }
        
        for input in avCaptureSession.inputs {
            self.avCaptureSession.removeInput(input)
        }
        
        for output in avCaptureSession.outputs {
            self.avCaptureSession.removeOutput(output)
        }
        
        avCaptureSession.addInput(avCaptureInput)
        avCaptureSession.addOutput(cameraOutput)
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = self.imageView.bounds
        let renderLayer = CALayer()
        self.imageView.wantsLayer = true
        self.imageView.layer = renderLayer
        self.imageView.layer?.addSublayer(avCaptureVideoPreviewLayer)
        self.avCaptureSession.startRunning()
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkImage), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear() {
        self.timer?.invalidate()
        self.timer = nil
        self.avCaptureSession.stopRunning()
    }
    
    @objc func checkImage() {
        cameraOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    private func process(text: String) {
        // Stop if we're already done with the decode.
        guard decoder.result == nil else {
            guard let result = try? decoder.result?.get(), let psbt = URHelper.psbtUrToBase64Text(result) else { return }
            stopScanning(psbt)
            return
        }
        
        decoder.receivePart(text.lowercased())
        
        let expectedParts = decoder.expectedPartCount ?? 0
        
        guard expectedParts != 0 else {
            guard let result = try? decoder.result?.get(), let psbt = URHelper.psbtUrToBase64Text(result) else { return }
            stopScanning(psbt)
            return
        }
        
        let percentageCompletion = "\(Int(decoder.estimatedPercentComplete * 100))% complete"
        scanSuccessFeedback(percentageCompletion)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkImage), userInfo: nil, repeats: true)
    }
    
    private func detect(_ ciImage: CIImage) {
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context:nil, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
            return
        }

        guard let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else { return }

        for feature in features {
            guard let qrString = feature.messageString else { return }
            
            self.timer?.invalidate()
            
            process(text: qrString)
        }
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        self.view.window?.title = "QR Scanner"
        askPermission()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.timer?.invalidate()
            self.timer = nil
            self.avCaptureSession.stopRunning()
            self.window?.performClose(nil)
        }
    }
    
    private func scanSuccessFeedback(_ percentageCompletion: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            NSSound(named: "Tink")?.play()
            self.progressView.doubleValue = self.decoder.estimatedPercentComplete
            self.progressView.alphaValue = 1.0
            self.completionLabel.stringValue = percentageCompletion
            self.completionLabel.alphaValue = 1
            self.backgroundView.alphaValue = 1
        }
    }
    
    private func stopScanning(_ result: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.timer?.invalidate()
            self.timer = nil
            self.avCaptureSession.stopRunning()
            self.doneBlock!(result)
            self.window?.performClose(nil)
        }
    }
    
    func askPermission() {
        let cameraPermissionStatus =  AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraPermissionStatus {
            
        case .authorized:
            print("Already Authorized")
            
        case .denied:
            setSimpleAlert(message: "You denied camera access", info: "You need to allow Gordian Signer access to the camera in order to scan QR codes", buttonLabel: "OK")
            
        case .restricted:
            setSimpleAlert(message: "You restricted camera access", info: "You need to allow Gordian Signer access to the camera in order to scan QR codes", buttonLabel: "OK")
            
        default:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted {
                    print("User granted")
                } else {
                    setSimpleAlert(message: "You rejected camera access", info: "You need to allow Gordian Signer access to the camera in order to scan QR codes", buttonLabel: "OK")
                }
            })
        }
    }
    
}

extension QRScanner: AVCapturePhotoCaptureDelegate {
        
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let ciImage = CIImage(data: imageData) else {
            print("Error while generating image from photo capture data.");
            return

        }
        
        detect(ciImage)
    }
    
}
