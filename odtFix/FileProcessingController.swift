//
//  FileProcessingController.swift
//  odtFix
//
//  Created by Denys Badzo on 9/6/15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Foundation
import Cocoa

// File processing modes
enum Modes {
    case FixOnly
    case FixAndReplace
}

protocol FileProcessingDelegate: class {
    
    weak var findTextField: NSTextField! { get }
    
    weak var replaceTextField: NSTextField! { get }
}

class FileProcessingController: NSObject {
    static let sharedController = FileProcessingController()
    
    weak var delegate: FileProcessingDelegate?
    
    let manager = FileManager.sharedManager
    
    var fileURLs: [NSURL]?
    
    var mode: Modes = .FixOnly
    
    var rewriteFiles = false
    
   func openFiles() -> Bool {
        
        if let files = NSOpenPanel().selectFiles {
            if !(files.isEmpty) {
                fileURLs = files
                manager.unarchiveDocsFromURLs(fileURLs!)
            } else {
                println("file selection was canceled")
            }
        } else {
            println("file selection was canceled")
        }
        
        if fileURLs?.count > 0 {
            return true
        }
    
        return false
    
    }
    
    func fixXML() {
        
        if let fileURLs = self.fileURLs {
            
            if !(fileURLs.isEmpty) {
                if mode == .FixAndReplace {
                    manager.searchAndReplaceMode = true
                    manager.searchString = delegate?.findTextField.stringValue
                    manager.replaceString = delegate?.replaceTextField.stringValue
                }
                
                manager.archiveDocsForURLs(fileURLs, rewrite: rewriteFiles)
            }
            
        } else {
            println("file not selected")
        }
    }
}
