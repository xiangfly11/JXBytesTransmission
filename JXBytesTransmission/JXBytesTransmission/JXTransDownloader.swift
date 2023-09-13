//
//  JXTransDownloader.swift
//  JXBytesTransmission
//
//  Created by Jiaxiang Li on 2023/8/3.
//

import Foundation

class JXTransDownloader: NSObject {
    
    private static let sharedDownloader = JXTransDownloader.init()
    
    private var taskList: [SessionTask] = [SessionTask]()
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "JXTransmissionDownloader")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        let session = URLSession.init(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }()
    
    private override init() {
        super.init()
    }
    
    class func shared() -> JXTransDownloader {
        return .sharedDownloader
    }
    
    public func downloadTask(_ task: JXBytesTransTask, progress: ProgressBlock?, completion: CompletionBlock?) {
        guard case let TaskType.download(urlStr) = task.type, let url = URL(string: urlStr) else { return }
        let downloadTask = urlSession.downloadTask(with: URLRequest.init(url: url))
        downloadTask.resume()
        let task = SessionTask(task: downloadTask, url: urlStr, progressBlock: progress, completionBlock: completion)
        taskList.append(task)
    }
    
    public func cancelDownloadTask(_ task: JXBytesTransTask, completion: CompletionBlock?) {
        guard case let TaskType.download(urlStr) = task.type else {
            completion?(nil, JXBytesTransError.downloadError)
            return
        }
        guard var sessionTask = taskList.first(where: { $0.url == urlStr }) else {
            completion?(nil, JXBytesTransError.downloadError)
            return
        }
        guard let downloadTask = sessionTask.task as? URLSessionDownloadTask else {
            completion?(nil, JXBytesTransError.downloadError)
            return
        }
        
        downloadTask.cancel {data in
            guard let data = data else {
                completion?(nil, JXBytesTransError.downloadError)
                return
            }
            sessionTask.resumeData = data
        }
    }
    
    public func resumeDownloadTask(_ task: JXBytesTransTask, completion: CompletionBlock?) {
        guard case let TaskType.download(urlStr) = task.type else {
            completion?(nil, JXBytesTransError.downloadError)
            return
        }
        guard var sessionTask = taskList.first(where: { $0.url == urlStr }) else {
            completion?(nil, JXBytesTransError.downloadError)
            return
        }
        
        guard let resumeData = sessionTask.resumeData else {
            completion?(nil, JXBytesTransError.downloadError)
            return
        }
        
        let downloadTask = urlSession.downloadTask(withResumeData: resumeData)
        downloadTask.resume()
        sessionTask.task = downloadTask
    }
}

extension JXTransDownloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let existedTask = taskList.first(where: { $0.task.taskIdentifier == downloadTask.taskIdentifier }) else { return }
        do {
            let documentUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let savedUrl = documentUrl.appendingPathComponent(location.lastPathComponent)
            try FileManager.default.moveItem(at: location, to: savedUrl)
            DispatchQueue.main.async {
                existedTask.completionBlock?(savedUrl, nil)
            }
        } catch {
            DispatchQueue.main.async {
                existedTask.completionBlock?(nil, error)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let existedTask = taskList.first(where: { $0.task.taskIdentifier == downloadTask.taskIdentifier }) else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            existedTask.progressBlock?(progress)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else { return }
        guard var existedTask = taskList.first(where: { $0.task.taskIdentifier == task.taskIdentifier }) else { return }
        let userInfo = (error as NSError).userInfo
        if let resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
            existedTask.resumeData = resumeData
        }
        
        existedTask.completionBlock?(nil, error)
    }
}
