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

    var fileURLs: [NSURL]?

    @IBOutlet weak var textView: NSScrollView!
    
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
        
//        NSFileManager.defaultManager().removeItemAtPath("/private/tmp/test.odt", error: nil)
        
//        var openPanel = NSOpenPanel()
//        
//        openPanel.allowsMultipleSelection = true
//        openPanel.canChooseDirectories = false
//        openPanel.canCreateDirectories = true
//        openPanel.canChooseFiles = true
//        openPanel.prompt? = "Fix!"
//        openPanel.beginWithCompletionHandler { (result) -> Void in
//            if result == NSFileHandlingPanelOKButton {
//                //Do what you will
//                //If there's only one URL, surely 'openPanel.URL'
//                for URL in openPanel.URLs {
//                    var deviceURL = URL as! NSURL
//                    var fullFilePathURL = deviceURL//.URLByAppendingPathComponent(fileDB)
//                    var fileOpenError:NSError?
//                
//                    if NSFileManager.defaultManager().fileExistsAtPath(deviceURL.path!) {
//                    
//                        if let fileContent = String(contentsOfURL: fullFilePathURL, encoding: NSUTF8StringEncoding, error: &fileOpenError) {
//                            var text = fileContent + "123"
//                            text.writeToURL(fullFilePathURL, atomically: false, encoding: NSUTF8StringEncoding, error: &fileOpenError)
//                            let myString = NSMutableAttributedString(string: "\(fileContent)\n")
//                            var textView = self.textView.documentView as! NSTextView
//                            textView.textStorage?.appendAttributedString(myString)
//                        } else {
//                            if let fileOpenError = fileOpenError {
//                                println(fileOpenError)  // Error Domain=NSCocoaErrorDomain Code=XXX "The file “ReadMe.txt” couldn’t be opened because...."
//                            }
//                        }
//                    } else {
//                        println("file not found")
//                    }
//                }
//            }
//            if result == NSFileHandlingPanelCancelButton {
////                self.resultDev.stringValue = "Cancel"
//            }
//            
//        }
       
    }
    

    @IBAction func fixXML(sender: NSButton) {
        FileManager.sharedManager.delegate = self
            if let fileURLs = self.fileURLs {
                if !(fileURLs.isEmpty) {
                    FileManager.sharedManager.archiveDocsForURLs(fileURLs)
                }
                
            } else {
                println("file selection was canceled")
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

