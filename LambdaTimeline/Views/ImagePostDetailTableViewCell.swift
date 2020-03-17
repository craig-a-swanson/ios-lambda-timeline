//
//  ImagePostDetailTableViewCell.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewCell: UITableViewCell {

    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    var isAudio: Bool = false
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentText: UILabel!
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
        
        guard let audio = comment.audioURL else {
            commentText.text = comment.text
            commentText.isHidden = false
            commentAudioControl.isHidden = true
            return
        }
        commentText.isHidden = true
        commentAudioControl.isHidden = false
    }

}
