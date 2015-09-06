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

    
    @IBOutlet weak var openFilesMenuItem: NSMenuItem!
    @IBOutlet weak var processFilesMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        FileManager.sharedManager.removeTempDir(FileManager.sharedManager.tempDir)
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
        FileManager.sharedManager.removeTempDir(FileManager.sharedManager.tempDir)
    }
    
    @IBAction func openFilesMenuSelected(sender: NSMenuItem) {
    
    }
    
    @IBAction func processFilesMenuSelected(sender: NSMenuItem) {

    }
        

}

