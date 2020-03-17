//
//  RecordCommentViewController.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

// convert the audio file to Data and call the store method in PostController in order to save it to the Firebase Storage area.  It should save it to "audio/" instead of "image/"
// then figure out fetch.

protocol RecordCommentVCDelegate {
    func updatePost(post: Post)
}

class RecordCommentViewController: UIViewController {
    
    var post: Post?
    var recordingURL: URL?
    var audioRecorder: AVAudioRecorder?
    var postController: PostController?
    var delegate: RecordCommentVCDelegate?

    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recordButton.layer.cornerRadius = 20
    }
    
    @IBAction func startStopRecording(_ sender: UIButton) {
        
        if recordButton.isSelected {
            recordButton.isSelected = false
            stopRecording()
        } else {
            recordButton.isSelected = true
            requestPermissionOrStartRecording()
        }
    }
    
    @IBAction func cancelComment(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveComment(_ sender: UIBarButtonItem) {
        guard post != nil else { return }
        guard let audioURL = recordingURL else {
        presentInformationalAlertController(title: "One thing...", message: "Make sure that you record a comment before posting.")
        return
        }
        
        postController?.addAudioComment(with: audioURL, of: .audio, to: self.post!) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to save comment")
                }
                return
            }
            self.delegate?.updatePost(post: self.post!)
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func createAudioCommentURL() -> URL {
                let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
                let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
                
                print("recording URL: \(file)")
                
                return file
    }
    
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("We need microphone access")
                    return
                }
                
                print("Recording permission has been granted!")
                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
            }
        case .denied:
            print("Microphone access has been blocked.")
            
            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }
    
    func startRecording() {
        do {
            try prepareAudioSession()
        } catch {
            print("Cannot record audio: \(error)")
            return
        }
        recordingURL = createAudioCommentURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, format: format)
            audioRecorder?.delegate = self
//            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
//            updateViews()
//            startTimer()
        } catch {
            preconditionFailure("The audio recorder could not be created with \(recordingURL!) and \(format)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
//        updateViews()
//        cancelTimer()
    }
    
    // To use on a device. Boilerplate code
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RecordCommentViewController: AVAudioRecorderDelegate {
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if let recordingURL = recordingURL {
//            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
//        }
//        audioRecorder = nil
//    }
//    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
//        if let error = error {
//            print("Audio Recorder Error: \(error)")
//        }
//    }
}
