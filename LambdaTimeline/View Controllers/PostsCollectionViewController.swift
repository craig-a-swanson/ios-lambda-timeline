//
//  PostsCollectionViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import AVFoundation

class PostsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestCameraPermission()
        
        postController.observePosts { (_) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func signout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPost(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Post", message: "Which kind of post do you want to create?", preferredStyle: .actionSheet)
        
        let imagePostAction = UIAlertAction(title: "Image", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddImagePost", sender: nil)
        }
        
        let videoPostAction = UIAlertAction(title: "Video", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddVideoPost", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(imagePostAction)
        alert.addAction(videoPostAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:  // User's first use of the app
            requestVideoPermission() // request permission
        case .restricted:  // Parental controls, for instance, are preventing recording
            preconditionFailure("Video is disabled; please review device restrictions")
        case .denied:  // The user denied permission to use video
            preconditionFailure("You are not able to use the app without giving permission via Setting > Privacy > Video")
        case .authorized: break  // The user previously granted permission
            
        @unknown default: // A future new feature from apple that isn't handled now
            preconditionFailure("A new status code was added that we need to handle")
        }
    }
    
    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (isGranted) in
            guard isGranted else {
                preconditionFailure("UI: Tell the user to enable permissions for Video/Camera")
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = postController.posts[indexPath.row]
        
        switch post.mediaType {
            
        case .image:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePostCell", for: indexPath) as? ImagePostCollectionViewCell else { return UICollectionViewCell() }
            
            cell.post = post
            
            loadImage(for: cell, forItemAt: indexPath)
            
            return cell
            
        case .video:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPostCell", for: indexPath) as? VideoPostCollectionViewCell else { return UICollectionViewCell() }
            
            cell.post = post
            loadVideo(for: cell, forItemAt: indexPath)
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize(width: view.frame.width, height: view.frame.width)
        
        let post = postController.posts[indexPath.row]
        
        switch post.mediaType {
        case .image:
            guard let ratio = post.ratio else { return size }
            size.height = size.width * ratio
            
        case .audio:
            return size
            
        case .video:
            guard let ratio = post.ratio else { return size }
            size.height = size.width * ratio
        }
        
        return size
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if let cell = cell as? ImagePostCollectionViewCell,
            cell.imageView.image != nil {
            self.performSegue(withIdentifier: "ViewImagePost", sender: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
        guard let postID = postController.posts[indexPath.row].postID else { return }
        operations[postID]?.cancel()
    }
    
    // MARK: - Load Image
    func loadImage(for imagePostCell: ImagePostCollectionViewCell, forItemAt indexPath: IndexPath) {
        let post = postController.posts[indexPath.row]
        
        guard let postID = post.postID else { return }
        
        if let mediaData = cache.value(for: postID),
            let image = UIImage(data: mediaData) {
            imagePostCell.setImage(image)
            self.collectionView.reloadItems(at: [indexPath])
            return
        }
        
        let fetchOp = FetchMediaOperation(post: post, postController: postController)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.mediaData {
                self.cache.cache(value: data, for: postID)
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: postID) }
            
            if let currentIndexPath = self.collectionView?.indexPath(for: imagePostCell),
                currentIndexPath != indexPath {
                print("Got image for now-reused cell")
                return
            }
            
            if let data = fetchOp.mediaData {
                imagePostCell.setImage(UIImage(data: data))
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        mediaFetchQueue.addOperation(fetchOp)
        mediaFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[postID] = fetchOp
    }
    
    // MARK: - Load Video
    func loadVideo(for videoPostCell: VideoPostCollectionViewCell, forItemAt indexPath: IndexPath) {
        let post = postController.posts[indexPath.row]
        
        guard let postID = post.postID else { return }
        
        if let mediaData = cache.value(for: postID) {
//            let mediaAsset = AVAsset(url: post.mediaURL)
//            let playerItem = AVPlayerItem(asset: mediaAsset)
            videoPostCell.player = AVPlayer(data: mediaData)
            self.collectionView.reloadItems(at: [indexPath])
            return
        }
        
        let fetchOp = FetchMediaOperation(post: post, postController: postController)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.mediaData {
                self.cache.cache(value: data, for: postID)
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: postID) }
            
            if let currentIndexPath = self.collectionView?.indexPath(for: videoPostCell),
                currentIndexPath != indexPath {
                print("Got video for now-reused cell")
                return
            }
            
            if let data = fetchOp.mediaData {
                videoPostCell.player = AVPlayer(data: data)
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        mediaFetchQueue.addOperation(fetchOp)
        mediaFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[postID] = fetchOp
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddImagePost" {
            let destinationVC = segue.destination as? ImagePostViewController
            destinationVC?.postController = postController
            
        } else if segue.identifier == "ViewImagePost" {
            
            let destinationVC = segue.destination as? ImagePostDetailTableViewController
            
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
                let postID = postController.posts[indexPath.row].postID else { return }
            
            destinationVC?.postController = postController
            destinationVC?.post = postController.posts[indexPath.row]
            destinationVC?.imageData = cache.value(for: postID)
        } else if segue.identifier == "AddVideoPost" {
            let addVideoVC = segue.destination as? VideoPostViewController
            addVideoVC?.postController = postController
        }
    }
    
    private let postController = PostController()
    private var operations = [String : Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let cache = Cache<String, Data>()
}
