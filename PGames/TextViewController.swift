//
//  TextViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/12/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse

class TextViewController: UIViewController {

    @IBOutlet weak var taskText: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    var timeLeft:Int?
    var tasks: [PFObject] = []
    var mainController:ViewController?
    var game: PFObject?
    override func viewDidLoad() {
        super.viewDidLoad()
        countDownLabel.text = String(timeLeft!--)
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        taskText.text = game!["description"] as? String
    }

    /***********************
     // Template Functions
     ************************/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /***********************
     // Game Transition Functions
     ************************/
    
    @IBAction func nextGame(sender: UIButton) {
        //mainController?.timeLeft = timeLeft
        sendParseData()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func update() {
        if(timeLeft >= 0)
        {
            countDownLabel.text = String(timeLeft!--)
        }
    }
    
    /***********************
     // Data Functions
     ************************/
    
    func sendParseData() {
        let loc = PFObject(className:"locationData")
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                // do something with the new geoPoint
                loc["location"] = geoPoint!
                print("\(geoPoint)")
            }
            loc["gameType"] = "textGames"
            loc["gameID"] = self.game!.objectId
            loc.saveInBackground()
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
