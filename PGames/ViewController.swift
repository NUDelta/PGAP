//
//  ViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/12/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var countDownLabel: UILabel!
    var timeLeft:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        countDownLabel.text = String(timeLeft!--)
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "textSegue") {
            
            let ViewControllerIn = (segue.destinationViewController as! TextViewController)
            ViewControllerIn.mainController = self
            ViewControllerIn.timeLeft = timeLeft
            
        }
        else if (segue.identifier == "imageSegue") {
            let ViewControllerIn = (segue.destinationViewController as! ImageViewController)
            ViewControllerIn.mainController = self
            ViewControllerIn.timeLeft = timeLeft
        }
    }

    @IBAction func beginGame(sender: UIButton) {
        self.performSegueWithIdentifier("imageSegue", sender: self)
    }
    
    func update() {
        
        if(timeLeft > 0)
        {
            countDownLabel.text = String(timeLeft!--)
            countDownLabel.font = countDownLabel.font.fontWithSize(CGFloat(50 + (60 - timeLeft!) * 5 ))
        }
        else
        {
            countDownLabel.font = countDownLabel.font.fontWithSize(CGFloat(50))
            countDownLabel.text = "Time's Up!"
            //playAgainButton.hidden = false
        }
        
    }

}

