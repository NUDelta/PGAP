//
//  StartViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/12/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

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
            
            ViewControllerIn.timeLeft = 60
            
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
