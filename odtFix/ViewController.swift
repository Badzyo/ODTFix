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

