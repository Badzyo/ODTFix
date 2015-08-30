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
    let tempDir = NSURL(fileURLWithPath: "/private/tmp/odtFix", isDirectory: true)!
    var delegate: FileManagerLogDelegate?
    
    let zipPath = "/usr/bin/zip"
    let unzipPath = "/usr/bin/unzip"
    let newFileSuffix = "_fix"
    let possibleErrors = [" < ",   " > ",   " <= ",   "  >=  ",   " <> "]
    let corrections    = [" &lt; "," &gt; "," &lt;= "," &gt;= "," &lt;&gt; "]
    
    dynamic var xmlErrorsCounter: UInt = 0
    dynamic var xmlErrorsFixed: UInt = 0
    dynamic var textReplacementsCounter: UInt = 0
    
    ///////////////////////////////////////////////////
    //// FUNCTION:  lounches a task, defined by 
    ////            path and arguments
    ///////////////////////////////////////////////////
    private func _launchTaskAt(path: String, args arguments: [String], handler: (error: ErrorCode, log: String) -> Void) {
        var task = NSTask()
        let pipe = NSPipe()
        let errorsPipe = NSPipe()
        task.standardOutput = pipe
        task.standardError = errorsPipe
        
        task.launchPath = path
        task.arguments = arguments
        task.launch()
        task.waitUntilExit()
        
        
        let data = errorsPipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        let error: ErrorCode = .OK
        let currentLog = NSMutableAttributedString(string: "\(output)\n\(error.rawValue)\n")
        println(currentLog)
        handler(error: .OK, log: output)
    }
    
    ///////////////////////////////////////////////////
    //// FUNCTION:  unarchive chosen files to a 
    ////            temporary directory and serch 
    ////            for possible XML errors
    ///////////////////////////////////////////////////
    func unarchiveDocsFromURLs(URLs: [NSURL]) -> ErrorCode {
        
        NSFileManager.defaultManager().createDirectoryAtPath(tempDir.path!, withIntermediateDirectories: false, attributes: nil, error: nil)
        NSFileManager.defaultManager().changeCurrentDirectoryPath(tempDir.path!)
        
        println("Creating folder \(tempDir.path!)")
        
        for file in URLs {
 
            println("Unzip \(file.path!) to \(tempDir.path!)/\(file.lastPathComponent!)")

            self._launchTaskAt(unzipPath, args: [file.path!, "-d", file.lastPathComponent!], handler: { (error: ErrorCode, log: String) -> Void in
                ErrorHandler.defaultHandler.printError(error)
                self.writeToLog(log)
                self.writeToLog(error.rawValue)
            })

            xmlErrorsCounter += searchForXMLErrorsAt(NSURL(fileURLWithPath: "\(tempDir.path!)/\(file.lastPathComponent!)/content.xml")!)
        }
        
        return .OK
    }
    
    ///////////////////////////////////////////////////
    //// FUNCTION:  correct & save files
    ///////////////////////////////////////////////////
    func archiveDocsForURLs(URLs: [NSURL], rewrite: Bool) -> ErrorCode {
        
        let suffix = rewrite ? "" : newFileSuffix
        
        for file in URLs {
            
            if let tmpURL = NSURL(fileURLWithPath: "\(tempDir.path!)/\(file.lastPathComponent!)", isDirectory: true) {
                
                correctXMLErrorsAt(NSURL(fileURLWithPath: "\(tmpURL.path!)/content.xml")!)
                
                NSFileManager.defaultManager().changeCurrentDirectoryPath("\(tempDir.path!)/\(file.lastPathComponent!)")
                
                let newFileName = file.lastPathComponent!.stringByReplacingOccurrencesOfString(".odt", withString: "\(suffix).odt")
                let destinationPath = file.path!.stringByReplacingOccurrencesOfString(file.lastPathComponent!, withString: newFileName)
                
                println("Archiving \(tempDir.path!)/\(file.lastPathComponent!) to \(destinationPath)")
                
                self._launchTaskAt(zipPath, args: ["-r", "-X", destinationPath, "."], handler: { (error: ErrorCode, log: String) -> Void in
                    ErrorHandler.defaultHandler.printError(error)
                    self.writeToLog(log)
                    self.writeToLog(error.rawValue)
                })
            
            }
        }
        
        removeTempDir(tempDir)
        return .OK
    }
    
    ///////////////////////////////////////////////////////////
    //// FUNCTION:  Search & correct XML-errors in a content.xml
    ///////////////////////////////////////////////////////////
    func correctXMLErrorsAt(URL: NSURL) {
        xmlErrorsFixed += searchForXMLErrorsAt(URL)
        searchAndReplaceTextAt(URL, searchFor: possibleErrors, replaceBy: corrections)
        
    }
    
    ///////////////////////////////////////////////////
    //// FUNCTION:  Search & Replace text in a file
    ///////////////////////////////////////////////////
    func searchAndReplaceTextAt(URL: NSURL, searchFor: [String], replaceBy: [String]) {
        
                            var fileOpenError:NSError?
        
                            if NSFileManager.defaultManager().fileExistsAtPath(URL.path!) {
        
                                if let fileContent = String(contentsOfURL: URL, encoding: NSUTF8StringEncoding, error: &fileOpenError) {
                                    var text = fileContent
                                    for index in 0 ... (searchFor.count - 1) {
                                        
                                        text = text.stringByReplacingOccurrencesOfString(searchFor[index], withString: replaceBy[index], options: .RegularExpressionSearch)
                                    }
                                    
                                    text.writeToURL(URL, atomically: false, encoding: NSUTF8StringEncoding, error: &fileOpenError)

                                } else {
                                    if let fileOpenError = fileOpenError {
                                        writeToLog(fileOpenError.description)
                                    }
                                }
                            } else {
                                println("file not found")
                            }
    }
    
    ///////////////////////////////////////////////////
    //// FUNCTION: Counting potentional errors in a file
    ///////////////////////////////////////////////////
    func searchForXMLErrorsAt(URL: NSURL) -> UInt {
        var counter: UInt = 0
        var fileOpenError:NSError?

        if NSFileManager.defaultManager().fileExistsAtPath(URL.path!) {

            if let fileContent = String(contentsOfURL: URL, encoding: NSUTF8StringEncoding, error: &fileOpenError) {
                var text = NSString(string: fileContent)
                for errorString in [" < "," > "," <= ","  >=  "," <> "] {
                    counter += UInt(count(text.componentsSeparatedByString(errorString)) - 1)
                }
                //writeToLog(fileContent)
            } else {
                if let fileOpenError = fileOpenError {
                    writeToLog(fileOpenError.description)
                }
            }
        } else {
            println("file not found")
        }
        return counter
    }
    
    ///////////////////////////////////////////////////
    //// FUNCTION:  Remove a temporary directory
    ///////////////////////////////////////////////////
    func removeTempDir(path: NSURL) -> ErrorCode {
        
        NSFileManager.defaultManager().removeItemAtPath(path.path!, error: nil)
        return .OK
    }
    
    /////////////////////////////////////////////////////
    //// FUNCTION:  add some String to delegate's textView
    /////////////////////////////////////////////////////
    func writeToLog(log: String) {
        if let textView = self.delegate?.textView.documentView as? NSTextView{
            let logText = NSMutableAttributedString(string: "\(log)\n")
            textView.textStorage?.appendAttributedString(logText)
        }
    }
    
    
}