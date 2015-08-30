//
//  AppDelegate.swift
//  odtFix
//
//  Created by Denys Badzo on 23.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        FileManager.sharedManager.removeTempDir(FileManager.sharedManager.tempDir)
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
        FileManager.sharedManager.removeTempDir(FileManager.sharedManager.tempDir)
    }
    

}

