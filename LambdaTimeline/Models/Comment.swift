//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//
//
//import Foundation
//import FirebaseAuth
//
//struct Comment: FirebaseConvertible, Equatable {
//
//    static private let textKey = "text"
//    static private let author = "author"
//    static private let timestampKey = "timestamp"
//    static private let audioURLKey = "audioURL"
//    static private let commentIDKey = "commentID"
//
//    var commentID: String
//    let text: String?
//    let author: Author
//    let timestamp: Date
//    let audioURL: URL?
//
//    init(commentID: String = UUID().uuidString, text: String?, author: Author, timestamp: Date = Date(), audioURL: URL? = nil) {
//        self.commentID = commentID
//        self.text = text
//        self.author = author
//        self.timestamp = timestamp
//        self.audioURL = audioURL
//    }
//
//    // Convert from a dictionary needed by Firebase back to our Comment object
//    init?(dictionary: [String : Any]) {
//        guard let authorDictionary = dictionary[Comment.author] as? [String: Any],
//            let author = Author(dictionary: authorDictionary),
//            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval,
//            let commentID = dictionary[Comment.commentIDKey] as? String else { return nil }
//
//        self.commentID = commentID
//        self.text = dictionary[Comment.textKey] as? String
//        self.author = author
//        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
//        self.audioURL = dictionary[Comment.audioURLKey] as? URL
//    }
//
//    // Convert to a dictionary for Firebase
//    var dictionaryRepresentation: [String: Any] {
//        return [Comment.commentIDKey: commentID as String,
//                Comment.textKey: text,
//                Comment.author: author.dictionaryRepresentation,
//                Comment.timestampKey: timestamp.timeIntervalSince1970,
//                Comment.audioURLKey: audioURL?.absoluteString]
//    }
//
//    static func ==(lhs: Comment, rhs: Comment) -> Bool {
//        return lhs.author == rhs.author &&
//            lhs.timestamp == rhs.timestamp
//    }
//}
