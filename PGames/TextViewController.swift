//
//  TextViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/12/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {

    @IBOutlet weak var countDownLabel: UILabel!
    var timeLeft:Int?
    var mainController:ViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countDownLabel.text = String(timeLeft!--)
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextGame(sender: UIButton) {
        //mainController?.timeLeft = timeLeft
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
