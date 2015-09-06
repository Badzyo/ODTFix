//
//  DragAndDropTextView.swift
//  odtFix
//
//  Created by Denys Badzo on 9/6/15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Cocoa

class DragAndDropTextView: NSTextView, NSDraggingDestination {
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.registerForDraggedTypes([NSFilenamesPboardType])
        
    }
    

    let BlueColor = NSColor(red: 0, green: 0.1, blue: 1, alpha: 1)
    let WhiteColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    ////////////////////////////////////////
    ////  NSDraggingDestination protocol
    ////////////////////////////////////////
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()!
        
        if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
            
            
            if sourceDragMask.rawValue & NSDragOperation.Generic.rawValue != 0 {
                self.backgroundColor =  BlueColor
                return NSDragOperation.Generic
            }
        }
        
        return NSDragOperation.None
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        self.backgroundColor = WhiteColor
    }
    
    override func draggingEnded(sender: NSDraggingInfo?) {
        self.backgroundColor = WhiteColor
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()!
        
        if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
            
            
            if sourceDragMask.rawValue & NSDragOperation.Generic.rawValue != 0 {
                //self.backgroundColor =  BlueColor
                return NSDragOperation.Generic
            }
        }
        
        return NSDragOperation.None
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        println("prepare")
        self.backgroundColor = WhiteColor
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()!
        
        if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
        
            if sourceDragMask.rawValue & NSDragOperation.Generic.rawValue != 0 {
                println("prepare - done")
                return true
            }
        }
        
        return false
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        println("perform")
        
        if let pboard = sender.draggingPasteboard() {
            
            var objects: AnyObject? = pboard.propertyListForType(NSFilenamesPboardType)
            if let files = objects as? [String] {
                
                var URLs: [NSURL] = []
                for file in files {
                    if let url = NSURL(fileURLWithPath: file) {
                        URLs.append(url)
                    }
                }
                
                if URLs.count > 0 {
                    FileProcessingController.sharedController.fileURLs = URLs
                    FileManager.sharedManager.unarchiveDocsFromURLs(URLs)
                    FileProcessingController.sharedController.isFileSelected = true
                }
            }
            
            return true
        }
        
        return false
        
    }
    
}