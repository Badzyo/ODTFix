//
//  FileManager.swift
//  odtFix
//
//  Created by Denys Badzo on 27.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Foundation
import Cocoa

extension NSOpenPanel {
    var selectFiles: [NSURL]? {
        let fileOpenPanel = NSOpenPanel()
        fileOpenPanel.title = "Select File(s)"
        fileOpenPanel.allowsMultipleSelection = true
        fileOpenPanel.canChooseDirectories = false
        fileOpenPanel.canChooseFiles = true
        fileOpenPanel.canCreateDirectories = false
        fileOpenPanel.runModal()
        if let URLs = fileOpenPanel.URLs as? [NSURL] {
            return URLs
        }
        return nil
    }
}

protocol FileManagerLogDelegate {
    weak var textView: NSScrollView! { get }
}


class FileManager: NSObject {
    
    static let sharedManager = FileManager()
    
    var delegate: FileManagerLogDelegate?
    
    let zipPath = "/usr/bin/zip"
    let unzipPath = "/usr/bin/unzip"
    
    private func _launchTaskAt(path: String, args arguments: [String], handler: (error: ErrorCode, log: NSMutableAttributedString) -> Void) {
        var task = NSTask()
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launchPath = path
        task.arguments = arguments
        task.launch()
        task.waitUntilExit()
        
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        let error: ErrorCode = .OK
        let currentLog = NSMutableAttributedString(string: "\(output)\n\(error.rawValue)\n")
        println(currentLog)
        handler(error: .OK, log: currentLog)
    }
    
    func unarchiveDocsFromURLs(URLs: [NSURL]) -> ErrorCode {
        
        for file in URLs {
            println("Creating folder /private/tmp/\(file.lastPathComponent!)")
            println("Unzip \(file.path!) to /private/tmp/\(file.lastPathComponent!)")
            NSFileManager.defaultManager().createDirectoryAtPath("/private/tmp/\(file.lastPathComponent!)", withIntermediateDirectories: false, attributes: nil, error: nil)
            NSFileManager.defaultManager().changeCurrentDirectoryPath("/tmp/\(file.lastPathComponent!)")
            
            self._launchTaskAt(unzipPath, args: [file.path!, "-d", file.lastPathComponent!], handler: { (error: ErrorCode, log: NSMutableAttributedString) -> Void in
                ErrorHandler.defaultHandler.printError(error)
                if let textView = self.delegate?.textView.documentView as? NSTextView{
                     textView.textStorage?.appendAttributedString(log)
                }
            })


        }
        
        return .OK
    }
    
    
    func archiveDocsForURLs(URLs: [NSURL]) -> ErrorCode {
        
        for file in URLs {
           
            NSFileManager.defaultManager().changeCurrentDirectoryPath("/tmp/\(file.lastPathComponent!)")
            let newFileName = file.lastPathComponent!.stringByReplacingOccurrencesOfString(".odt", withString: "_fix.odt")
            let destinationPath = file.path!.stringByReplacingOccurrencesOfString(file.lastPathComponent!, withString: newFileName)
            println("Archiving /private/tmp/\(file.lastPathComponent!) to \(destinationPath)")
            self._launchTaskAt(zipPath, args: ["-r", "-X", destinationPath, "."], handler: { (error: ErrorCode, log: NSMutableAttributedString) -> Void in
                ErrorHandler.defaultHandler.printError(error)
                if let textView = self.delegate?.textView.documentView as? NSTextView{
                    textView.textStorage?.appendAttributedString(log)
                }
            })
            
            removeObjectAtPath(file)
            
        }
        
        return .OK
    }
    
    // NOTE: Доработать!!!
    func removeObjectAtPath(path: NSURL) -> ErrorCode {
        
        NSFileManager.defaultManager().removeItemAtPath(path.path!, error: nil)
        return .OK
    }
    
    
}