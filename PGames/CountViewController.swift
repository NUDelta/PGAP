//
//  CountViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/13/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse

class CountViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
   
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var countButton: UIButton!
    @IBOutlet weak var gameText: UILabel!
    var timeLeft:Int?
    var mainController:ViewController?
    var game: PFObject?
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        countDownLabel.text = String(timeLeft!)
        gameText.text = game!["description"] as! String
        countButton.backgroundColor = UIColor.blueColor()
        countButton.layer.cornerRadius = 5
        countButton.layer.borderWidth = 1
        countButton.layer.borderColor = UIColor.blackColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addCount(sender: UIButton) {
        count++
        countButton.setTitle(String(count), forState: .Normal)
    }
    @IBAction func doneButton(sender: UIButton) {
        sendParseData()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func update() {
        if(timeLeft >= 0)
        {
            countDownLabel.text = String(timeLeft!--)
        }
    }
    
    func sendParseData() {
        let loc = PFObject(className:"locationData")
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                // do something with the new geoPoint
                loc["location"] = geoPoint!
                print("\(geoPoint)")
            }
            loc["count"] = self.count
            loc["gameType"] = "countGames"
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
