//
//  AVPlayer+Data.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/19/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//
//  MNGAVPlayerExtensions.swift
//
//
//  Created by Tommie Carter on 7/6/15.
//  Copyright © 2015 MING Technology. All rights reserved.
//
import AVFoundation
import UIKit

extension AVPlayer {

    convenience init(data:Data!) {

        if  let urlString = String(data: data, encoding: String.Encoding.utf8) {
            self.init(url: URL(string: urlString)!)

        } else {
            self.init()
        }

    }

    class func thumbNail (videoURL:URL) -> UIImage? {
        var imgRef:CGImage? = nil
        let asset = AVURLAsset(url: videoURL)
        let generate = AVAssetImageGenerator(asset: asset)
        generate.appliesPreferredTrackTransform = true

        let time = CMTimeMake(value: 1, timescale: 60);

        do {

            imgRef = try generate.copyCGImage(at: time, actualTime: nil)

        } catch let e as NSError {
            print(e.localizedDescription)
        }

        if imgRef != nil {
            return UIImage(cgImage: imgRef!) as UIImage
        } else {
            return nil
        }
    }
}
