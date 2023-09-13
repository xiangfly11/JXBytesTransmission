//
//  JXTransUploader.swift
//  JXBytesTransmission
//
//  Created by Jiaxiang Li on 2023/8/3.
//

import Foundation

class JXTransUploader {
    
    private static let sharedUploader = JXTransUploader.init()
    
    private init() {
        
    }
    
    class func shared() -> JXTransUploader {
        return .sharedUploader
    }
}
