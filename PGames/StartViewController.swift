//
//  StartViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/12/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse
import ReplayKit

class StartViewController: UIViewController {
    var tasks: [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func beginGame(sender: AnyObject) {
        self.performSegueWithIdentifier("startSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "startSegue") {
            
            let ViewControllerIn = (segue.destinationViewController as! ViewController)
            
            ViewControllerIn.timeLeft = 90
            
        }
    }

    @IBAction func stopRecording(sender: AnyObject) {
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.stopRecordingWithHandler { (previewVC, error) in
            if let vc = previewVC {
                self.presentViewController(
                    vc,
                    animated: true,
                    completion: nil
                )
            }
        }
    }
    @IBAction func startrRecord(sender: UIButton) {
        let recorder = RPScreenRecorder.sharedRecorder()
        recorder.startRecordingWithMicrophoneEnabled(true, handler: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
