//
//  Post.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

enum MediaType: String {
    case image
    case audio
}

class Post {
    
    var mediaURL: URL
    let mediaType: MediaType
    let author: Author
    let timestamp: Date
    var comments: [Comment]?
    var postID: String?
    var ratio: CGFloat?
    
    var title: String? {
        guard let comments = comments else { return "" }
        return comments.first?.text
    }
    
    init(title: String, mediaURL: URL, ratio: CGFloat? = nil, author: Author, timestamp: Date = Date(), comments: [Comment]? = []) {
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.mediaType = .image
        self.author = author
        self.comments = comments
//        self.comments = [Comment(text: title, author: author)]
        self.timestamp = timestamp
    }
    
    // Convert from a dictionary needed by Firebase back to our Post object
    init?(dictionary: [String : Any], id: String) {
        guard let mediaURLString = dictionary[Post.mediaKey] as? String,
            let mediaURL = URL(string: mediaURLString),
            let mediaTypeString = dictionary[Post.mediaTypeKey] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let authorDictionary = dictionary[Post.authorKey] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Post.timestampKey] as? TimeInterval else { return nil }
//            let captionDictionaries = dictionary[Post.commentsKey] as? [[String: Any]] else { return nil }
        
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.ratio = dictionary[Post.ratioKey] as? CGFloat
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
//        self.comments = captionDictionaries.compactMap({ Comment(dictionary: $0) })
        self.postID = id
    }
    
    // Convert to a dictionary using the key constants defined below as the dictionary keys
    var dictionaryRepresentation: [String : Any] {
        var dict: [String: Any] = [Post.mediaKey: mediaURL.absoluteString,
                Post.mediaTypeKey: mediaType.rawValue,
//                Post.commentsKey: comments.map({ $0.dictionaryRepresentation }),
                Post.authorKey: author.dictionaryRepresentation,
                Post.timestampKey: timestamp.timeIntervalSince1970]
        
        guard let ratio = self.ratio else { return dict }
        
        dict[Post.ratioKey] = ratio
        
        return dict
    }
    
    static private let mediaKey = "media"
    static private let ratioKey = "ratio"
    static private let mediaTypeKey = "mediaType"
    static private let authorKey = "author"
    static private let commentsKey = "comments"
    static private let timestampKey = "timestamp"
    static private let idKey = "id"
    
    
    // MARK: - Comment Structure
    struct Comment: FirebaseConvertible, Equatable {
        static private let textKey = "text"
        static private let author = "author"
        static private let timestampKey = "timestamp"
        static private let audioURLKey = "audioURL"
        static private let commentIDKey = "commentID"
        
        var commentID: String
        let text: String?
        let author: Author
        let timestamp: Date
        let audioURL: URL?
        
        init(commentID: String = UUID().uuidString, text: String?, author: Author, timestamp: Date = Date(), audioURL: URL?) {
            self.commentID = commentID
            self.text = text
            self.author = author
            self.timestamp = timestamp
            self.audioURL = audioURL
        }
        
        // Convert from a dictionary needed by Firebase back to our Comment object
        init? (snapshot: DataSnapshot) {
            guard let value = snapshot.value as? [String:Any],
                let authorDictionary = value[Post.Comment.author] as? [String:Any],
            let author = Author(dictionary: authorDictionary),
                let timestampTimeInterval = value[Comment.timestampKey] as? TimeInterval,
                let commentID = value[Comment.commentIDKey] as? String else { return nil }
            
            self.commentID = commentID
            self.text = value[Comment.textKey] as? String
            self.author = author
            self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
            guard let urlStirng = value["audioURL"] as? String else { return nil }
            self.audioURL = URL(string: urlStirng)
        }
        
    /*
        init?(dictionary: [String : Any]) {
            guard let authorDictionary = dictionary[Comment.author] as? [String: Any],
                let author = Author(dictionary: authorDictionary),
                let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval,
                let commentID = dictionary[Comment.commentIDKey] as? String else { return nil }
            
            self.commentID = commentID
            self.text = dictionary[Comment.textKey] as? String
            self.author = author
            self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
            self.audioURL = dictionary[Comment.audioURLKey] as? URL
        }
 */
        
        // Convert to a dictionary for Firebase
        var dictionaryRepresentation: [String: Any] {
            return [Comment.commentIDKey: commentID as String,
                    Comment.textKey: text,
                    Comment.author: author.dictionaryRepresentation,
                    Comment.timestampKey: timestamp.timeIntervalSince1970,
                    Comment.audioURLKey: audioURL?.absoluteString]
        }
        
        static func ==(lhs: Comment, rhs: Comment) -> Bool {
            return lhs.author == rhs.author &&
                lhs.timestamp == rhs.timestamp
        }
    }
}
