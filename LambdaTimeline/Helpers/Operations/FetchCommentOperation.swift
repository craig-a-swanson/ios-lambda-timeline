//
//  FetchCommentOperation.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/17/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchCommentOperation: ConcurrentOperation {
    
    // MARK: Properties
    
    let audioURL: URL
    let postController: PostController
    var mediaData: Data?
    
    private let session: URLSession
    
    private var dataTask: URLSessionDataTask?
    
    
    init(audioURL: URL, postController: PostController, session: URLSession = URLSession.shared) {
        self.audioURL = audioURL
        self.postController = postController
        self.session = session
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        
        let url = audioURL
        
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.audioURL): \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from fetch media operation data task.")
                return
            }
            
            self.mediaData = data
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}
