//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController {
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            postController.fetchComments(with: post, completion: {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
    var postController: PostController!
    var imageData: Data?
    private let cache = Cache<String, Data>()
    private var operations = [String: Operation]()
    private let mediaFetchQueue = OperationQueue()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData),
        let post = post else { return }
//        postController.fetchComments(with: post) {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
        title = post.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let audioAction = UIAlertAction(title: "Audio Comment", style: .default) { action in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "RecordCommentSegue", sender: self)
            }
        }
        
        let textAction = UIAlertAction(title: "Text Comment", style: .default) { action in
            self.addTextCommentAlert()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(audioAction)
        alert.addAction(textAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func addTextCommentAlert() {
        
                let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
                var commentTextField: UITextField?
        
                alert.addTextField { (textField) in
                    textField.placeholder = "Comment:"
                    commentTextField = textField
                }
        
                let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
        
                    guard let commentText = commentTextField?.text else { return }
        
                    self.postController.addTextComment(with: commentText, with: nil, to: self.post!) {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(addCommentAction)
                alert.addAction(cancelAction)
                
                present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post!.comments?.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let post = post else { fatalError() }
        guard let comments = post.comments else { return UITableViewCell() }
        let comment = comments[indexPath.row]
        
        if let audioURL = comment.audioURL {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCommentCell", for: indexPath) as? ImagePostDetailTableViewCell else { return UITableViewCell() }
            cell.audioURL = audioURL
            cell.authorLabel.text = comment.author.displayName
            loadAudio(for: cell, forItemAt: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCommentCell", for: indexPath)
            
            cell.textLabel?.text = comment.text
            cell.detailTextLabel?.text = comment.author.displayName
            
            return cell
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordCommentSegue" {
            guard let recordVC = segue.destination as? RecordCommentViewController else { return }
            
            recordVC.postController = postController
            recordVC.post = post
            recordVC.delegate = self
        }
    }
    
    private func loadAudio(for audioCell: ImagePostDetailTableViewCell, forItemAt indexPath: IndexPath) {
        
        let comment = post!.comments![indexPath.row]
        guard let audioURL = comment.audioURL else {
                print("Audio URL does not exist for comment")
            return
        }
        if let audioData = cache.value(for: comment.author.uid+"\(comment.timestamp)") {
            audioCell.loadAudio(data: audioData)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        
        let fetchOp = FetchCommentOperation(audioURL: URL(string: audioURL)!, postController: postController)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.mediaData {
                self.cache.cache(value: data, for: comment.author.uid+"\(comment.timestamp)")
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: comment.author.uid+"\(comment.timestamp)")}
            
            if let currentIndexPath = self.tableView.indexPath(for: audioCell),
                currentIndexPath != indexPath {
                return
            }
            
            if let data = fetchOp.mediaData {
                audioCell.loadAudio(data: data)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        mediaFetchQueue.addOperation(fetchOp)
        mediaFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[comment.author.uid+"\(comment.timestamp)"] = fetchOp
    }
}

extension ImagePostDetailTableViewController: RecordCommentVCDelegate {
    func updatePost(post: Post) {
        self.post = post
        self.tableView.reloadData()
    }
}
