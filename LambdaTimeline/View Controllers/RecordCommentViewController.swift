//
//  RecordCommentViewController.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class RecordCommentViewController: UIViewController {
    
    var post: Post?

    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recordButton.layer.cornerRadius = 20
        
    }
    @IBAction func startStopRecording(_ sender: UIButton) {
        
        if recordButton.isSelected {
            recordButton.isSelected = false
        } else {
            recordButton.isSelected = true
        }
    }
    
    @IBAction func cancelComment(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveComment(_ sender: UIBarButtonItem) {
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
