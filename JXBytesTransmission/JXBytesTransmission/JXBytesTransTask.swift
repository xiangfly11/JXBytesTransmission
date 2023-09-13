//
//  JXBytesTransTask.swift
//  JXBytesTransmission
//
//  Created by Jiaxiang Li on 2023/9/12.
//

import Foundation

enum TaskType {
    case download(String)
    case upload(String)
}

enum TaskStatus {
    case notStart
    case pause
    case processing
    case canceled
    case finished
}

struct SessionTask {
    var task: URLSessionTask
    var url: String
    var resumeData: Data?
    var progressBlock: ProgressBlock?
    var completionBlock: CompletionBlock?
}

class JXBytesTransTask {

    private(set) var type: TaskType
    private(set) var status: TaskStatus
    
    init(type: TaskType, status: TaskStatus) {
        self.type = type
        self.status = status
    }
}
