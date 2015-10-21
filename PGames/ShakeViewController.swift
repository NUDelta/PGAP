//
//  ShakeViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/13/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse
import CoreMotion

class ShakeViewController: UIViewController {
    
    @IBOutlet weak var gameText: UILabel!
    @IBOutlet weak var shakeCount: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    var timeLeft:Int?
    var mainController:ViewController?
    var actionCount = 0
    var tasks: [PFObject] = []
    var game: PFObject?
    
    let pedometer = CMPedometer()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countDownLabel.text = String(timeLeft!--)
        gameText.text = game!["description"] as? String
        actionCount = game!["numReq"] as! Int
        shakeCount.text = String(actionCount)
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype,
        withEvent event: UIEvent?) {
            if motion == .MotionShake{
                actionCount--
                shakeCount.text = String(actionCount)
                if (actionCount == 0) {
                    shakeCount.text = "HAPPY"
                    let _ : NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("leaveCode"), userInfo: nil, repeats: false)
                }
            }
         
    }
    
    func leaveCode() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        if(timeLeft >= 0)
        {
            countDownLabel.text = String(timeLeft!--)
        }
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
