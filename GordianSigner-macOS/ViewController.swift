//
//  ViewController.swift
//  GordianSigner-macOS
//
//  Created by Peter on 10/15/20.
//  Copyright © 2020 Blockchain Commons. All rights reserved.
//

import Cocoa
import LibWally

class ViewController: NSViewController, NSWindowDelegate {
        
    @IBOutlet weak private var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear() {
        self.view.window?.delegate = self
        self.view.window?.minSize = NSSize(width: 407, height: 469)
    }
    
    override func viewDidAppear() {
        var frame = self.view.window!.frame
        let initialSize = NSSize(width: 407, height: 469)
        frame.size = initialSize
        self.view.window?.setFrame(frame, display: true)
        self.view.window?.title = "Gordian Signer"
        
        textView.string = """
        You may add a psbt here in a few ways:
        
        1. Paste one
        2. Click "scan QR" to scan a static or animated QR codes
        3. Click "upload file" to upload a .psbt file
        
        In order to sign psbt's you need to add bip39 mnemonics via the signers button.
        """
        
        if !FirstTime.firstTimeHere() {
            setSimpleAlert(message: "Fatal error", info: "We were unable to set and save an encryption key to your secure enclave, the app will not function without this key.", buttonLabel: "OK")
        }
    }
    
    @IBAction func exportAction(_ sender: Any) {
        guard let _ = try? PSBT(textView.string, .testnet) else {
            setSimpleAlert(message: "Invalid psbt!", info: "You need to add a valid psbt in order to export it", buttonLabel: "OK")
            return
        }
        
        DispatchQueue.main.async {
            let a = NSAlert()
            a.messageText = "Export psbt"
            a.informativeText = "You can export the psbt as a QR code or save it as a .psbt file"
            a.addButton(withTitle: "QR")
            a.addButton(withTitle: "save file")
            a.addButton(withTitle: "cancel")
            let response = a.runModal()
            if response == .alertFirstButtonReturn {
                self.exportAsQr()
            } else if response == .alertSecondButtonReturn {
                self.saveFile()
            }
        }
    }
    
    private func saveFile() {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "GordianSigner"
        savePanel.allowedFileTypes = ["psbt"]
        savePanel.isExtensionHidden = false
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {

                if let url = savePanel.url {
                    guard let data = Data(base64Encoded: self.textView.string) else {
                        setSimpleAlert(message: "Ooops", info: "We had an issue converting that psbt to raw data.", buttonLabel: "OK")
                        return
                    }
                    
                    do {
                        try data.write(to: url, options: .atomicWrite)
                        setSimpleAlert(message: "File saved ✅", info: "", buttonLabel: "OK")
                    } catch {
                        setSimpleAlert(message: "Ooops", info: "We had an issue converting that psbt to raw data.", buttonLabel: "OK")
                    }
                }
            }
        }
    }
    
    @IBAction func signAction(_ sender: Any) {
        guard textView.string != "" else {
            setSimpleAlert(message: "Ooops", info: "You need to add a psbt here first, either paste one in base64 text, scan a QR code or upload a .psbt file.", buttonLabel: "OK")
            return
        }
        
        Signer.sign(textView.string) { (psbt, errorMessage) in
            guard let psbt = psbt else {
                setSimpleAlert(message: "Something went wrong!", info: "There was an error signing that psbt: \(errorMessage ?? "unknown error")", buttonLabel: "OK")
                return
            }
            
            DispatchQueue.main.async {
                self.textView.string = psbt
            }
            
            setSimpleAlert(message: "PSBT signed ✅", info: "The signed psbt has been added to the text window. You can copy it, or you can tap \"export\" to get more options", buttonLabel: "OK")
        }
    }
    
    
    @IBAction func seeSignersAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "segueToSigners", sender: self)
        }
    }
    

    @IBAction func scanAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "segueToScanQrCode", sender: self)
        }
    }
    
    @IBAction func openFileAction(_ sender: Any) {
        let open = NSOpenPanel()
        open.canChooseFiles = true
        open.runModal()
        
        guard let path = open.url, let data = try? Data(contentsOf: path) else { return }
                    
        let psbt = data.base64EncodedString()
        addPsbt(psbt)
    }
    
    private func exportAsQr() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "segueToExportQr", sender: self)
        }
    }
    
    private func addPsbt(_ psbt: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard let validPsbt = try? PSBT(psbt, .testnet) else {
                setSimpleAlert(message: "Ooops", info: "That psbt is not valid, this release is only compatible with testnet psbt's", buttonLabel: "OK")
                return
            }
            
            self.textView.string = validPsbt.description
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueToScanQrCode":
            guard let vc = segue.destinationController as? QRScanner else { fallthrough }
            
            vc.doneBlock = { [weak self] psbt in
                guard let self = self else { return }
                
                guard let psbt = psbt else { return }
                
                self.addPsbt(psbt)
            }
            
        case "segueToExportQr":
            guard let vc = segue.destinationController as? QRDisplayer else { fallthrough }
            
            vc.psbt = self.textView.string
            
        default:
            break
        }
    }
}

