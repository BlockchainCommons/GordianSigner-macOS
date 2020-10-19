//
//  QRDisplayer.swift
//  GordianSigner-macOS
//
//  Created by Peter on 10/19/20.
//  Copyright © 2020 Blockchain Commons. All rights reserved.
//

import Cocoa
import URKit
import CoreImage

class QRDisplayer: NSViewController, NSWindowDelegate {
    
    var psbt = ""
    private var encoder:UREncoder!
    private var timer: Timer?
    private var parts = [String]()
    private var ur: UR!
    private var partIndex = 0
    
    @IBOutlet weak var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    
    }
    
    override func viewWillAppear() {
        self.view.window?.delegate = self
        self.view.window?.minSize = NSSize(width: 450, height: 450)
    }
    
    override func viewDidAppear() {
        var frame = self.view.window!.frame
        let initialSize = NSSize(width: 450, height: 450)
        frame.size = initialSize
        self.view.window?.setFrame(frame, display: true)
        
        convertToUr()
    }
    
    @IBAction func animateAction(_ sender: Any) {
        animateNow()
    }
    
    private func animateNow() {
        encoder = UREncoder(ur, maxFragmentLen: 250)
        setTimer()
    }
    
    private func setTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(automaticRefresh), userInfo: nil, repeats: true)
    }

    @objc func automaticRefresh() {
        nextPart()
    }
    
    private func convertToUr() {
        guard let b64 = Data(base64Encoded: psbt), let ur = URHelper.psbtUr(b64) else { return }
        self.ur = ur
        let urString = UREncoder.encode(ur)
        showQR(urString)
    }
    
    private func nextPart() {
        let part = encoder.nextPart()
        let index = encoder.seqNum
        
        if index <= encoder.seqLen {
            parts.append(part.uppercased())
        } else {
            timer?.invalidate()
            timer = nil
            timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
        }
    }
    
    @objc func animate() {
        showQR(parts[partIndex])
        
        if partIndex < parts.count - 1 {
            partIndex += 1
        } else {
            partIndex = 0
        }
    }
    
    private func showQR(_ urString: String) {
        guard let qr = qr(urString) else {
            animateNow()
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.imageView.image = qr
        }
    }
    
    private func qr(_ textInput: String) -> NSImage? {
        let data = textInput.data(using: .ascii)
        
        // Generate the code image with CIFilter
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 10.0, y: 10.0)//CGAffineTransform(scaleX: 10, y: 10)
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        
        // Change the color using CIFilter
        let grey = #colorLiteral(red: 0.07804081589, green: 0.09001789242, blue: 0.1025182381, alpha: 1)
        
        let colorParameters = [
            "inputColor0": CIColor(color: grey), // Foreground
            "inputColor1": CIColor(color: .white) // Background
        ]
        
        let colored = (output.applyingFilter("CIFalseColor", parameters: colorParameters as [String : Any]))
        
        let rep = NSCIImageRep(ciImage: colored)
        let size = NSSize(width: 450, height: 450)
        let nsImage = NSImage(size: size)
        nsImage.addRepresentation(rep)
        
        return nsImage
    }
    
}
