//
//  HelpViewController.swift
//  odtFix
//
//  Created by Denys Badzo on 29.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Foundation
import Cocoa

class HelpViewController: NSViewController {
    
    @IBOutlet weak var helpTextLabel: NSTextField!
    
    let helpText = NSMutableAttributedString(string: "  При неотмеченном чекбоксе \nв директории с исходными файлами будут сохранены их копии. \n  К оригинальным именам файлов будет добавлено \"\(FileManager.sharedManager.newFileSuffix)\"")
    
    override func viewDidLoad() {
        helpTextLabel.attributedStringValue = helpText
    }
}