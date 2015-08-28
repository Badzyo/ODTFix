//
//  ErrorHandler.swift
//  odtFix
//
//  Created by Denys Badzo on 27.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Foundation

enum ErrorCode: String {
    case OK = "OK"
    case TmpDirUnreachable = "TmpDirUnreachable"
    case ZipNotIstalled = "ZipNotIstalled"
    case TempFileDissapeard = "TempFileDissapeard"
}

class ErrorHandler: NSObject {
    
    static let defaultHandler = ErrorHandler()
    
    func printError (error: ErrorCode) {
        println(error.rawValue)
    }
}