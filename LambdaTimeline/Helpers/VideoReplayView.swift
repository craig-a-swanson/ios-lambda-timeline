//
//  VideoReplayView.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/19/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoReplayView: UIView {
    
    // defaults to the CALayer class but we can override
    // this layer can display it effectively
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPlayerLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { return videoPlayerLayer.session }
        set { videoPlayerLayer.session = newValue }
    }
}
