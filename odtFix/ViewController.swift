//
//  ViewController.swift
//  odtFix
//
//  Created by Denys Badzo on 23.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController, FileManagerLogDelegate {
    
    enum Modes {
        case FixOnly
        case FixAndReplace
    }
    
    enum States {
        case ON
        case OFF
    }

    var fileURLs: [NSURL]?
    
    var mode: Modes = .FixOnly
    
    var rewriteFiles = false

    @IBOutlet weak var textView: NSScrollView!

    @IBOutlet weak var radioGroup: NSMatrix!
    
    @IBOutlet weak var findTextField: NSTextField!
    
    @IBOutlet weak var replaceTextField: NSTextField!
    
    @IBOutlet weak var errorsCountLabel: NSTextField!
    
    @IBOutlet weak var replacesCountLabel: NSTextField!
    
    @IBOutlet weak var resaveButton: NSButton!
    
    
    @IBAction func modeChanged(sender: NSMatrix) {
        let radioRow = sender.selectedRow
        
        if radioRow == 1 {
            mode = .FixAndReplace
            _replacementTextFieldsChangeState(.ON)
        } else {
            mode = .FixOnly
            _replacementTextFieldsChangeState(.OFF)
        }
    }
    
    @IBAction func rewriteModeChanged(sender: NSButton) {
        if sender.state == 0 {
            rewriteFiles = false
        } else {
            rewriteFiles = true
        }
    }
    
    
    @IBAction func openFiles(sender: NSButton) {
        
        FileManager.sharedManager.delegate = self
        if let files = NSOpenPanel().selectFiles {
            if !(files.isEmpty) {
                fileURLs = files
                FileManager.sharedManager.unarchiveDocsFromURLs(fileURLs!)
            } else {
                            println("file selection was canceled")
            }
        } else {
            println("file selection was canceled")
        }
        
        if fileURLs?.count > 0 {
            resaveButton.enabled = true
        }
        
    }
    
    @IBAction func fixXML(sender: NSButton) {
        
        FileManager.sharedManager.delegate = self
            if let fileURLs = self.fileURLs {
                if !(fileURLs.isEmpty) {
                    FileManager.sharedManager.archiveDocsForURLs(fileURLs, rewrite: rewriteFiles)
                }
                
            } else {
                println("file selection was canceled")
            }
    }
    
    private func _replacementTextFieldsChangeState (state: States) {
        if state == .ON {
            findTextField.enabled = true
            replaceTextField.enabled = true
        } else {
            findTextField.enabled = false
            replaceTextField.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        


        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

