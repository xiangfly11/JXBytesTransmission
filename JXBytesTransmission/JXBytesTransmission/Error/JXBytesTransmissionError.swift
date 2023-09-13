//
//  JXBytesTransError.swift
//  JXBytesTransmission
//
//  Created by Jiaxiang Li on 2023/8/4.
//

import Foundation

enum JXBytesTransError: Error {
    case downloadError
    case uploadError
    
    var localizedDescription: String {
        switch self {
        case .downloadError:
            return NSLocalizedString("Download Error", comment: "JXBytesTransError")
        case .uploadError:
            return NSLocalizedString("upload Error", comment: "JXBytesTransError")
        }
    }
}

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
