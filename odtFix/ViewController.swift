//
//  ViewController.swift
//  odtFix
//
//  Created by Denys Badzo on 23.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController, FileManagerLogDelegate, FileProcessingDelegate {
    
//    // File processing modes
//    enum Modes {
//        case FixOnly
//        case FixAndReplace
//    }
    
    //States of UI object
    enum States {
        case ON
        case OFF
    }
    
    let controller = FileProcessingController.sharedController

//    let manager = FileManager.sharedManager
//    
//    var fileURLs: [NSURL]?
//    
//    var mode: Modes = .FixOnly
//    
//    var rewriteFiles = false
    
    let RedColor = NSColor(red: 1, green: 0, blue: 0, alpha: 0.25)
    let WhiteColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)

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
            controller.mode = .FixAndReplace
            _replacementTextFieldsChangeState(.ON)
        } else {
            controller.mode = .FixOnly
            _replacementTextFieldsChangeState(.OFF)
        }
    }
    
    ///////////////////////////////////////////////////
    //// ACTION:  Changed "rewrite" checkbox state
    ///////////////////////////////////////////////////
    @IBAction func rewriteModeChanged(sender: NSButton) {
        if sender.state == 0 {
            controller.rewriteFiles = false
        } else {
            controller.rewriteFiles = true
        }
    }
    
    ///////////////////////////////////////////////////
    //// ACTION:  "Select files" button pressed
    ///////////////////////////////////////////////////
    @IBAction func openFiles(sender: NSButton) {
        
        if controller.openFiles() == true {
            resaveButton.enabled = true
        }
        
    }
    
    ///////////////////////////////////////////////////
    //// ACTION:  "Process files" button pressed
    ///////////////////////////////////////////////////
    @IBAction func fixXML(sender: NSButton) {
        
        if controller.mode == .FixAndReplace && !_isEnteredTextForReplace() {
            writeToLog("🚫 Не введены строки для поиска и замены")
            if count(replaceTextField.stringValue) == 0 {
                replaceTextField.backgroundColor = RedColor
            }
            if count(findTextField.stringValue) == 0 {
                findTextField.backgroundColor = RedColor
            }
            
            
        } else {
            replaceTextField.backgroundColor = WhiteColor
            findTextField.backgroundColor = WhiteColor
            resaveButton.enabled = false
            
            controller.fixXML()
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
    
    ///////////////////////////////////////////////////
    //// FUNCTION:  Check entered strings for
    ////            search and replace
    ///////////////////////////////////////////////////
    private func _isEnteredTextForReplace() -> Bool {
        
        if count(findTextField.stringValue) == 0 || count(replaceTextField.stringValue) == 0 {
            return false
        } else {
            return true
        }
    }
    
    /////////////////////////////////////////////////////
    //// FUNCTION:  add some String to textView
    /////////////////////////////////////////////////////
    func writeToLog(log: String) {
        if let textView = self.textView.documentView as? NSTextView{
            let logText = NSMutableAttributedString(string: "\(log)\n")
            textView.textStorage?.appendAttributedString(logText)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FileProcessingController.sharedController.delegate = self
        FileManager.sharedManager.delegate = self
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

