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
    var player: AVPlayer!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    func updateViews() {
        guard let post = post else { return }
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    @IBAction func playPauseVideo(_ sender: UIButton) {
    }
    
    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        //        labelBackgroundView.layer.borderColor = UIColor.white.cgColor
        //        labelBackgroundView.layer.borderWidth = 0.5
        labelBackgroundView.clipsToBounds = true
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
}
