//
//  PostController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

// TODO: Left off after step 6, for the most part. Implemented UI slider for the image post but not the video post.  Need to implement steps seven and eight.

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MapKit

class PostController {
    
    var posts: [Post] = []
    var comments: [Post.Comment] = []
    let currentUser = Auth.auth().currentUser
    let postsRef = Database.database().reference(withPath: "posts")
    let commentsRef = Database.database().reference(withPath: "comments")
    let storageRef = Storage.storage().reference()
    
    func createPost(with title: String, ofType mediaType: MediaType, mediaData: Data, ratio: CGFloat?, geotag: Bool, completion: @escaping (Bool) -> Void = { _ in }) {
        
        guard let currentUser = Auth.auth().currentUser,
            let author = Author(user: currentUser) else { return }
        
        store(mediaData: mediaData, mediaType: mediaType) { (mediaURL) in
            
            guard let mediaURL = mediaURL else { completion(false); return }
            let imagePost: Post
            
            if geotag {
                
                let currentLocation = geotagHelper().currentUserLocation()
               
                imagePost = Post(title: title, mediaURL: mediaURL, mediaType: mediaType, ratio: ratio, author: author, geotag: currentLocation)
            } else {
                imagePost = Post(title: title, mediaURL: mediaURL, mediaType: mediaType, author: author, geotag: nil)
            }
            
            self.postsRef.childByAutoId().setValue(imagePost.dictionaryRepresentation) { (error, ref) in
                if let error = error {
                    NSLog("Error posting image post: \(error)")
                    completion(false)
                }
        
                completion(true)
            }
        }
    }
    
    func addTextComment(with text: String, with audioURL: URL?, to post: Post, completion: @escaping () -> Void) {
        
        guard let currentUser = Auth.auth().currentUser,
            let postID = post.postID,
            let author = Author(user: currentUser) else { return }
        
        let comment = Post.Comment(text: text, author: author, audioURL: nil)
        let commentPostReference = self.commentsRef.child(postID)
        let commentReference = commentPostReference.child(comment.commentID)
        commentReference.setValue(comment.dictionaryRepresentation)
        completion()
    }
    
    func addAudioComment(with dataURL: String, of mediaType: MediaType, to post: Post, completion: @escaping (Bool) -> Void = { _ in }) {
        guard let currentUser = Auth.auth().currentUser,
            let postID = post.postID,
            let author = Author(user: currentUser) else { return }
        
        var audioData: Data
        do {
            audioData = try Data(contentsOf: URL(string: dataURL)!)
        } catch {
            print("Error retrieving audio data from directory: \(error)")
            return
        }
        putAudioDataToServer(mediaData: audioData, mediaType: mediaType) { (mediaURL) in
            
            guard let mediaURL = mediaURL else { completion(false); return }
            
            let comment = Post.Comment(text: nil, author: author, audioURL: mediaURL.absoluteString)
            let commentPostReference = self.commentsRef.child(postID)
            let commentReference = commentPostReference.child(comment.commentID)
            commentReference.setValue(comment.dictionaryRepresentation)
            completion(true)
        }
    }
    
    private func putAudioDataToServer(mediaData: Data, mediaType: MediaType, completion: @escaping (URL?) -> Void) {
        let mediaID = UUID().uuidString
        let mediaRef = storageRef.child(mediaType.rawValue).child(mediaID)
        
        let uploadTask = mediaRef.putData(mediaData, metadata: nil) { (metadata, error) in
            if let error = error {
                NSLog("Error storing media data: \(error)")
                completion(nil)
                return
            }
            
            if metadata == nil {
                NSLog("No metadata returned from upload task.")
                completion(nil)
                return
            }
            
            mediaRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    NSLog("Error getting download url of media: \(error)")
                }
                
                guard let url = url else {
                    NSLog("Download url is nil. Unable to create a Media object")
                    
                    completion(nil)
                    return
                }
                completion(url)
            })
        }
        uploadTask.resume()
    }
    
    func fetchComments(with post: Post, completion: @escaping () -> Void) {
        
        let commentPostReference = self.commentsRef.child(post.postID!)
        commentPostReference.observe(.value) { (snapshot) in
            var newComments: [Post.Comment] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let comment = Post.Comment(snapshot: childSnapshot) {
                    newComments.append(comment)
                }
            }
            DispatchQueue.main.async {
                post.comments = newComments
            }
            completion()
        }
    }

    func observePosts(completion: @escaping (Error?) -> Void) {
        
        postsRef.observe(.value, with: { (snapshot) in
            
            guard let postDictionaries = snapshot.value as? [String: [String: Any]] else { return }
            
            var posts: [Post] = []
            
            for (key, value) in postDictionaries {
                
                guard let post = Post(dictionary: value, id: key) else { continue }
                
                posts.append(post)
            }
            
            self.posts = posts.sorted(by: { $0.timestamp > $1.timestamp })
            
            completion(nil)
            
        }) { (error) in
            NSLog("Error fetching posts: \(error)")
        }
    }
    
    func savePostToFirebase(_ post: Post, completion: (Error?) -> Void = { _ in }) {
        
        guard let postID = post.postID else { return }
        
        let ref = postsRef.child(postID)
        
        ref.setValue(post.dictionaryRepresentation)
    }

    private func store(mediaData: Data, mediaType: MediaType, completion: @escaping (URL?) -> Void) {
        
        let mediaID = UUID().uuidString
        
        let mediaRef = storageRef.child(mediaType.rawValue).child(mediaID)
        
        let uploadTask = mediaRef.putData(mediaData, metadata: nil) { (metadata, error) in
            if let error = error {
                NSLog("Error storing media data: \(error)")
                completion(nil)
                return
            }
            
            if metadata == nil {
                NSLog("No metadata returned from upload task.")
                completion(nil)
                return
            }
            
            mediaRef.downloadURL(completion: { (url, error) in
                
                if let error = error {
                    NSLog("Error getting download url of media: \(error)")
                }
                
                guard let url = url else {
                    NSLog("Download url is nil. Unable to create a Media object")
                    
                    completion(nil)
                    return
                }
                completion(url)
            })
        }
        
        uploadTask.resume()
    }

    
}
