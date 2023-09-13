//
//  JXTransManager.swift
//  JXBytesTransmission
//
//  Created by Jiaxiang Li on 2023/8/3.
//

import Foundation

typealias ProgressBlock = (Double) -> ()
typealias CompletionBlock = (URL?, Error?) -> ()

class JXTransManager {
    
    private static let sharedManager = JXTransManager.init()
    private let downloader = JXTransDownloader.shared()
    private let cacher = JXTransCacher()
    private var taskList: [JXBytesTransTask]
    
    private init() {
        self.taskList = [JXBytesTransTask]()
    }
    
    class func shared() -> JXTransManager {
        return .sharedManager
    }
    
    public func downloadWithUrl(_ urlStr: String, progress: ProgressBlock?, completion: CompletionBlock?) {
        let downloadTask = JXBytesTransTask.init(type: .download(urlStr), status: .notStart)
        if let _ = taskInList(task: downloadTask) {
            return
        } else {
            downloader.downloadTask(downloadTask, progress: progress, completion: completion)
            taskList.append(downloadTask)
        }
    }
    
    public func cancelWithUrl(_ urlStr: String, completion: CompletionBlock?) {
        for task in taskList {
            switch task.type {
            case .download(let urlStr1):
                if urlStr == urlStr1 {
                    downloader.cancelDownloadTask(task, completion: completion)
                }
            case .upload(let urlStr1):
                break
            }
        }
    }
    
    
    public func uploadWithUrl(_ urlString: String, progress: ProgressBlock?, completion: CompletionBlock?) {
        let uploadTask = JXBytesTransTask.init(type: .upload(urlString), status: .notStart)
        if let _ = taskInList(task: uploadTask) {
            
        } else {
            
        }
    }
    
    private func taskInList(task: JXBytesTransTask) -> JXBytesTransTask? {
        switch task.type {
        case .upload(let urlStr1):
            return taskList.first { task in
                switch task.type {
                case .upload(let urlStr2):
                    return urlStr1 == urlStr2
                case .download(_):
                    return false
                }
            }
        case .download(let urlStr1):
            return taskList.first { task in
                switch task.type {
                case .upload(_):
                    return false
                case .download(let urlStr2):
                    return urlStr1 == urlStr2
                }
            }
        }
    }
}
