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

    var audioURL: String?
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
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
        commentAudioControl.isSelected = isPlaying
        
    }
    
    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func loadAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
        } catch {
            print("Error loading data into audio player: \(error)")
        }
    }
    
    func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
            updateViews()
        } catch {
            print("Cannot play audio: \(error)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        updateViews()
    }
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: [])
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
