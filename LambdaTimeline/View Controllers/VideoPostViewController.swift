//
//  VideoPostViewController.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostViewController: UIViewController {
    
    // MARK: - Properties
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var player: AVPlayer!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.videoPlayerLayer.videoGravity = .resizeAspectFill
        setupCamera()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    // MARK: - Actions
    @IBAction func startStopRecording(_ sender: UIButton) {
        toggleRecording()
    }
    
    // MARK: - Methods
    @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        switch(tapGesture.state) {
        case .ended:
            playRecording()
        default:
            print("Handled other tap states: \(tapGesture.state)")
        }
    }
    
    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        var topRect = view.bounds
        topRect.origin.y = view.frame.origin.y
        
        playerLayer.frame = topRect
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    func playRecording() {
        if let player = player {
            // Go to start of video (CMTime zero)
            player.seek(to: CMTime.zero)
            // CMTime(second: 2, preferredTimescale: 30) // 30 frames per second
            player.play()
        }
    }
    
    // MARK: - Set up Camera
    private func setupCamera() {
        let camera = bestcamera()
        let microphone = bestMicrophone()
        
        // there is a "begin" to start and a "commit" to end.
        captureSession.beginConfiguration()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            preconditionFailure("Cannot create an input from the camera, but we should do something better than crashing")
        }
        
        // Add input
        guard captureSession.canAddInput(cameraInput) else {
            preconditionFailure("This session can't handle this type of input: \(cameraInput)")
        }
        
        captureSession.addInput(cameraInput)
        
        guard let microphoneInput = try? AVCaptureDeviceInput(device: microphone) else {
            preconditionFailure("Can't create an input from microphone")
        }
        captureSession.addInput(microphoneInput)
        
        // If the file is large, change the resolution quality to make it smaller
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        // Add output
        guard captureSession.canAddOutput(fileOutput) else {
            preconditionFailure("Cannot write to disk.")
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }
    
    // MARK: - Best Camera and Microphone
    private func bestcamera() -> AVCaptureDevice {
        // try the better camera first if the user has it
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        // if the user doesn't have the better one, use the standard camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        preconditionFailure("No cameras on device match the specs that we need.")
    }
    
    private func bestMicrophone() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        preconditionFailure("No microphones on device match the specs that we need.")
    }
    
    // MARK: - Record Video
    private func toggleRecording() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    // MARK: - Create URL
    /// Creates a new file URL in the documents directory
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
}

// MARK: - AVCaptureFileOutputRecording Delegate
extension VideoPostViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }

        updateViews()
        playMovie(url: outputFileURL)
    }
}

