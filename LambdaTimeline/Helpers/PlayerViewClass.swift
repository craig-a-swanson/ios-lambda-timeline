//
//  PlayerViewClass.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewClass: UIView {
    
    // defaults to the CALayer class but we can override
    // this layer can display it effectively
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var videoPlayerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get { return videoPlayerLayer.player }
        set { videoPlayerLayer.player = newValue }
    }
}
