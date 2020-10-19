//
//  AddSigner.swift
//  GordianSigner-macOS
//
//  Created by Peter on 10/16/20.
//  Copyright © 2020 Blockchain Commons. All rights reserved.
//

import Cocoa

class AddSigner: NSViewController, NSTextFieldDelegate, NSControlTextEditingDelegate {
    
    private var addedWords = [String]()
    private var justWords = [String]()
    private var autoCompleteCharacterCount = 0
    private var timer = Timer()
    private var previousText = ""
    private var isCompleting = false
    
    @IBOutlet weak private var textField: NSTextField!
    @IBOutlet weak private var wordView: NSTextView!
    @IBOutlet weak private var saveButtonOutlet: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        textField.delegate = self
        saveButtonOutlet.isEnabled = false
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard Keys.validMnemonicArray(justWords),
            let data = (justWords.joined(separator: " ")).data(using: .utf8),
            let encryptedData = Encryption.encrypt(data),
            KeyChain.saveNewSeed(encryptedData) else {
                setSimpleAlert(message: "Error ⚠️", info: "Something went wrong, your seed words were not saved!", buttonLabel: "OK")
                return
        }
        
        setSimpleAlert(message: "Seed words encrypted and saved 🔐", info: "", buttonLabel: "OK")
        textField.stringValue = ""
        addedWords.removeAll()
        justWords.removeAll()
        wordView.string = ""
        updatePlaceHolder(wordNumber: 1)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .refreshSigners, object: nil, userInfo: nil)
        }
    }
    
    @IBAction func removeWord(_ sender: Any) {
        guard self.justWords.count > 0 else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.wordView.string = ""
            self.addedWords.removeAll()
            self.justWords.remove(at: self.justWords.count - 1)
            
            for (i, word) in self.justWords.enumerated() {
                self.addedWords.append("\(i + 1). \(word)\n")
                if i == 0 {
                    self.updatePlaceHolder(wordNumber: i + 1)
                } else {
                    self.updatePlaceHolder(wordNumber: i + 2)
                }
            }
            
            self.wordView.string = self.addedWords.joined(separator: "")
            
            if Keys.validMnemonicArray(self.justWords) {
                self.validWordsAdded()
            }
        }
    }
    
    @IBAction func addWord(_ sender: Any) {
        processTextfieldInput()
    }
    
    private func updatePlaceHolder(wordNumber: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.textField.placeholderString = "add word #\(wordNumber)"
        }
    }
    
    private func validWordsAdded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.textField.resignFirstResponder()
            self.saveButtonOutlet.isEnabled = true
        }
        
        setSimpleAlert(message: "Valid Words ✓", info: "That is a valid recovery phrase, tap \"save\" to encrypt it and save it so that it may sign your psbt's.", buttonLabel: "OK")
    }
    
    private func addWordNow(word: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.wordView.string = ""
            self.addedWords.removeAll()
            self.justWords.append(word)
            
            for (i, word) in self.justWords.enumerated() {
                self.addedWords.append("\(i + 1). \(word)\n")
                self.updatePlaceHolder(wordNumber: i + 2)
            }
            
            self.wordView.string = self.addedWords.joined(separator: "")
            
            if Keys.validMnemonicArray(self.justWords) {
                self.validWordsAdded()
            }
            
            self.textField.becomeFirstResponder()
        }
    }
    
    private func processTextfieldInput() {
        let textInput = textField.stringValue
        guard textInput != "" else { return }
        
        //check if user pasted more then one word
        let processed = processedCharacters(textInput)
        let userAddedWords = processed.split(separator: " ")
        var multipleWords = [String]()
        
        if userAddedWords.count > 1 {
            
            //user add multiple words
            for (i, word) in userAddedWords.enumerated() {
                var isValid = false
                
                for bip39Word in Bip39Words.valid {
                    if word == bip39Word {
                        isValid = true
                        multipleWords.append("\(word)")
                    }
                }
                
                if i + 1 == userAddedWords.count {
                    // we finished our checks
                    if isValid {
                        // they are valid bip39 words
                        addMultipleWords(words: multipleWords)
                        textField.stringValue = ""
                        
                    } else {
                        //they are not all valid bip39 words
                        textField.stringValue = ""
                        setSimpleAlert(message: "Error", info: "At least one of those words is not a valid BIP39 word. We suggest inputting them one at a time so you can utilize our autosuggest feature which will prevent typos.", buttonLabel: "OK")
                    }
                }
            }
        } else {
            //its one word
            let processedWord = textInput.replacingOccurrences(of: " ", with: "")
            for word in Bip39Words.valid {
                if processedWord == word {
                    addWordNow(word: processedWord)
                    textField.stringValue = ""
                }
            }
        }
    }
    
    private func addMultipleWords(words: [String]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.wordView.string = ""
            self.addedWords.removeAll()
            self.justWords = words
            
            for (i, word) in self.justWords.enumerated() {
                self.addedWords.append("\(i + 1). \(word)\n")
                self.updatePlaceHolder(wordNumber: i + 2)
            }
            
            self.wordView.string = self.addedWords.joined(separator: "")
            print("self.justWords: \(self.justWords)")
            
            guard Keys.validMnemonicArray(self.justWords) else {
                setSimpleAlert(message: "Invalid", info: "Just so you know that is not a valid recovery phrase, if you are inputting a 24 word phrase ignore this message and keep adding your words.", buttonLabel: "OK")
                return
            }
            
            self.validWordsAdded()
        }
    }
    
    private func processedCharacters(_ string: String) -> String {
        return string.filter("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ".contains).condenseWhitespace()
    }
    
    func control(_ control: NSControl, textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String] {
        isCompleting = true
        return getAutocompleteSuggestions(userText: textView.string)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if !isCompleting {
            isCompleting = true
            textField.currentEditor()?.complete(nil)
            isCompleting = false
        }
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        processTextfieldInput()
        return true
    }

    func getAutocompleteSuggestions(userText: String) -> [String] {
        var possibleMatches: [String] = []
        for item in Bip39Words.valid {
            let myString:NSString! = item as NSString
            let substringRange:NSRange! = myString.range(of: userText)
            if (substringRange.location == 0) {
                possibleMatches.append(item)
            }
        }
        return possibleMatches
    }
    
}
