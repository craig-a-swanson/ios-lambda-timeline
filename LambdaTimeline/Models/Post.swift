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
import MapKit

enum MediaType: String {
    case image
    case audio
    case video
}

class Post: NSObject {
    
    var mediaURL: URL
    let mediaType: MediaType
    let author: Author
    let timestamp: Date
    var comments: [Comment]?
    var postID: String?
    var ratio: CGFloat?
    var PostTitle: String
    var geotag: CLLocationCoordinate2D?
    
    init(title: String, mediaURL: URL, mediaType: MediaType, ratio: CGFloat? = nil, author: Author, timestamp: Date = Date(), comments: [Comment]? = [], geotag: CLLocationCoordinate2D?) {
        self.PostTitle = title
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.mediaType = mediaType
        self.author = author
        self.comments = comments
        self.timestamp = timestamp
        self.geotag = geotag
    }
    
    // Convert from a dictionary needed by Firebase back to our Post object
    init?(dictionary: [String : Any], id: String) {
        guard let title = dictionary[Post.titleKey] as? String,
            let mediaURLString = dictionary[Post.mediaKey] as? String,
            let mediaURL = URL(string: mediaURLString),
            let mediaTypeString = dictionary[Post.mediaTypeKey] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let authorDictionary = dictionary[Post.authorKey] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Post.timestampKey] as? TimeInterval else { return nil }
        
        self.PostTitle = title
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.ratio = dictionary[Post.ratioKey] as? CGFloat
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.postID = id

        if let latitude = dictionary[Post.latitudeKey] as? Double,
            let longitude = dictionary[Post.longitudeKey] as? Double {
        self.geotag = CLLocationCoordinate2D(latitude: latitude, longitude: longitude) as CLLocationCoordinate2D
        }
    }
    
    // Convert to a dictionary using the key constants defined below as the dictionary keys
    var dictionaryRepresentation: [String : Any] {
        var dict: [String: Any] = [Post.titleKey: PostTitle,
            Post.mediaKey: mediaURL.absoluteString,
                Post.mediaTypeKey: mediaType.rawValue,
                Post.authorKey: author.dictionaryRepresentation,
                Post.timestampKey: timestamp.timeIntervalSince1970]
        
        if geotag != nil {
            dict[Post.latitudeKey] = String("\(geotag!.latitude)")
            dict[Post.longitudeKey] = String("\(geotag!.longitude)")
        }
        guard let ratio = self.ratio else { return dict }
        
        dict[Post.ratioKey] = ratio
        
        return dict
    }
    
    static private let titleKey = "title"
    static private let mediaKey = "media"
    static private let ratioKey = "ratio"
    static private let mediaTypeKey = "mediaType"
    static private let authorKey = "author"
    static private let commentsKey = "comments"
    static private let timestampKey = "timestamp"
    static private let idKey = "id"
    static private let latitudeKey = "latitude"
    static private let longitudeKey = "longitude"
    
    
    // MARK: - Comment Structure
    struct Comment: FirebaseConvertible, Equatable, Decodable {
        static private let textKey = "text"
        static private let author = "author"
        static private let timestampKey = "timestamp"
        static private let audioURLKey = "audioURL"
        static private let commentIDKey = "commentID"
        
        var commentID: String
        let text: String?
        let author: Author
        let timestamp: Date
        let audioURL: String?
        
        init(commentID: String = UUID().uuidString, text: String?, author: Author, timestamp: Date = Date(), audioURL: String?) {
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
            self.audioURL = value["audioURL"] as? String
        }
        
        // Convert to a dictionary for Firebase
        var dictionaryRepresentation: [String: Any] {
            return [Comment.commentIDKey: commentID as String,
                    Comment.textKey: text ?? "",
                    Comment.author: author.dictionaryRepresentation,
                    Comment.timestampKey: timestamp.timeIntervalSince1970,
                    Comment.audioURLKey: audioURL as Any]
        }
        
        static func ==(lhs: Comment, rhs: Comment) -> Bool {
            return lhs.author == rhs.author &&
                lhs.timestamp == rhs.timestamp
        }
    }
}
