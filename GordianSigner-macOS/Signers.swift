//
//  Signers.swift
//  GordianSigner-macOS
//
//  Created by Peter on 10/16/20.
//  Copyright © 2020 Blockchain Commons. All rights reserved.
//

import Cocoa

class Signers: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    private var signers = [String]()

    @IBOutlet weak private var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: .refreshSigners, object: nil)
    }
    
    override func viewDidAppear() {
        self.view.window?.title = "Signer's"
        loadData()
    }
    
    @objc func refresh(_ sender: Any) {
        loadData()
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        guard tableView.selectedRow >= 0 else { return }
        
        actionAlert(message: "Delete \(signers[tableView.selectedRow])", info: "This will permanently delete this signer!") { [weak self] response in
            if response {
                guard let self = self else { return }
                
                guard let seeds = Encryption.decryptedSeeds(), seeds.count > 0 else { return }
                
                var newSeeds = [String]()
                
                for signer in seeds {
                    guard let masterKey = Keys.masterKey(signer, ""),
                        let fingerprint = Keys.fingerprint(masterKey) else {
                            return
                    }
                    
                    if fingerprint != self.signers[self.tableView.selectedRow] {
                        newSeeds.append(signer)
                    }
                }
                
                KeyChain.overWriteExistingSeeds(newSeeds) { [weak self] success in
                    guard let self = self else { return }
                    
                    guard success else {
                        setSimpleAlert(message: "Something went wrong", info: "We had an issue deleteing that signer..", buttonLabel: "OK")
                        return
                    }
                    
                    self.loadData()
                    
                    setSimpleAlert(message: "Signer deleted ✅", info: "", buttonLabel: "OK")
                }
            }
        }
    }
    
    @IBAction func addSignerAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "segueToAddSigner", sender: self)
        }
    }
    
    private func loadData() {
        signers.removeAll()
        tableView.reloadData()
        guard let seeds = Encryption.decryptedSeeds(), seeds.count > 0 else { return }
        for signer in seeds {
            guard let masterKey = Keys.masterKey(signer, ""),
                let fingerprint = Keys.fingerprint(masterKey) else {
                    return
            }
            signers.append(fingerprint)
        }
        tableView.reloadData()
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return signers.count
    }
        
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "signerCell"), owner: self) as! NSTableCellView
        cell.textField?.stringValue = signers[row]
        return cell
        
    }
    
}
