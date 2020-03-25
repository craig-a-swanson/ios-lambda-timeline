//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostCollectionViewCell: UICollectionViewCell {
    var post: Post? {
        didSet {
            updateViews()
        }
    }
//    var player: AVPlayer!
    var player: AVPlayer? {
        didSet {
            playRecording()
        }
    }
    var playerLayer: AVPlayerLayer?
    var recordingData: Data?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerView: PlayerViewClass!
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setupLabelBackgroundView()
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

//        playerLayer?.player = nil
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    func updateViews() {
        guard let post = post else { return }
//        titleLabel.text = post.title
//        authorLabel.text = post.author.displayName
    }
    
    func playRecording() {
           guard let player = player,
        let view = playerView else { return }
        player.seek(to: CMTime.zero)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill

        var topRect = view.bounds
        topRect.origin.y = view.frame.origin.y
        playerLayer?.frame = topRect
        view.layer.addSublayer(playerLayer!)
//        view.player = player
        player.play()
    }
    
    @IBAction func playPauseVideo(_ sender: UIButton) {
        playRecording()
    }
    
    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        labelBackgroundView.layer.borderColor = UIColor.white.cgColor
        labelBackgroundView.layer.borderWidth = 0.5
        labelBackgroundView.clipsToBounds = true
    }
}
