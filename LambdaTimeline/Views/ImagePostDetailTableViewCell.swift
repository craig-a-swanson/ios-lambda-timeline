//
//  ImagePostDetailTableViewCell.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewCell: UITableViewCell {

    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    var isAudio: Bool = false
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.delegate = self
            updateViews()
        }
    }
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentAudioControl: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func updateViews() {
        guard let comment = comment else { return }
        authorLabel.text = comment.author.displayName

    }

}

extension ImagePostDetailTableViewCell: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
            // In a real app, actually present an error message to the user.
        }
    }
}
