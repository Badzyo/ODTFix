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
    
    // File processing modes
    enum Modes {
        case FixOnly
        case FixAndReplace
    }
    
    //States of UI object
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
    
    ///////////////////////////////////////////////////
    //// ACTION:  Changed work mode by checking a radiobutton
    ///////////////////////////////////////////////////
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
    
    ///////////////////////////////////////////////////
    //// ACTION:  Changed "rewrite" checkbox state
    ///////////////////////////////////////////////////
    @IBAction func rewriteModeChanged(sender: NSButton) {
        if sender.state == 0 {
            rewriteFiles = false
        } else {
            rewriteFiles = true
        }
    }
    
    ///////////////////////////////////////////////////
    //// ACTION:  "Select files" button pressed
    ///////////////////////////////////////////////////
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
    
    ///////////////////////////////////////////////////
    //// ACTION:  "Process files" button pressed
    ///////////////////////////////////////////////////
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
    
    ///////////////////////////////////////////////////
    //// FUNCTION:  Change state of textFields at UI
    ///////////////////////////////////////////////////
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
        
        FileManager.sharedManager.addObserver(self, forKeyPath: "xmlErrorsCounter", options: .New, context: nil)
        FileManager.sharedManager.addObserver(self, forKeyPath: "xmlErrorsFixed", options: .New, context: nil)
        FileManager.sharedManager.addObserver(self, forKeyPath: "textReplacementsCounter", options: .New, context: nil)

    }
    

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if let theObject = object as? FileManager {
            switch keyPath {
            case "xmlErrorsCounter", "xmlErrorsFixed":
                errorsCountLabel.stringValue = "\(theObject.xmlErrorsFixed) из \(theObject.xmlErrorsCounter)"
            case "textReplacementsCounter":
                replacesCountLabel.stringValue = "\(theObject.textReplacementsCounter)"
            default: ()
            }
        }
    }

   
}

