//
//  PaceViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 12/3/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse
import CoreMotion

class PaceViewController: UIViewController {
    // View for games that end by pace or motion interaction

    @IBOutlet weak var gameText: UILabel!
    var game: Int?
    var g: PFObject?
    var tasks: [PFObject]?
    let activityManager = CMMotionActivityManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pace not Enabled! TBD
        //startPaceTracking()
        
        g = tasks![game!]
        if g!.objectId! as String != "gttM8sMlpS" {
            _ = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("end"), userInfo: nil, repeats: true)
        }
        gameText.text = g!["mainInfo"] as? String
    }
    
    /***********************
     // Results Transition
     ************************/
    
    func end() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let svc : ResultsViewController = mainStoryboard.instantiateViewControllerWithIdentifier("results") as! ResultsViewController
        svc.modalTransitionStyle = .CrossDissolve
        svc.game = self.game
        svc.g = g
        svc.tasks = tasks
        presentViewController(svc, animated: true, completion: nil)
    }
    
    /***********************
     // Shake Interaction Functions
     ************************/
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype,
        withEvent event: UIEvent?) {
            if motion == .MotionShake && g!.objectId! as String == "gttM8sMlpS"{
                    performSelector("end", withObject: nil, afterDelay: 1)
            }
    }
    
    /***********************
     // Pace Interaction Functions - TBD
     ************************/
    
    func startPaceTracking() {
        if(CMMotionActivityManager.isActivityAvailable()){
            print("YESS!")
            self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue()) { data in
                if let data = data {
                    dispatch_async(dispatch_get_main_queue()) {
                        if(data.stationary == true){
                            print("Stationary")
                        } else if (data.walking == true){
                            print("Walking")
                        } else if (data.running == true){
                            print("Running")
                        } else if (data.automotive == true){
                            print("Automotive")
                        }
                    }
                }
            }
        }
    }
    
    /***********************
     // Template Function
     ************************/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
