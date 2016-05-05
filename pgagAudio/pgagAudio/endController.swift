//
//
//  pgagAudio
//
//  Created by Shawn Caeiro on 4/7/16.
//  Copyright © 2016 Jennie Werner. All rights reserved.
//

import UIKit
import Parse

class endController: UIViewController, UITextFieldDelegate {
    
    let aD = UIApplication.sharedApplication().delegate as! AppDelegate
    var numGamesPlayed : Int!
    
    var userName : String = ""
    @IBOutlet weak var points: UILabel!
    
    @IBOutlet weak var goodWorkL: UILabel!
    
       override func viewDidLoad() {
        super.viewDidLoad()
        self.userName = aD.userName

        self.numGamesPlayed = aD.numberGamesPlayed
        points.text = String(self.numGamesPlayed)
        
        goodWorkL.text = "Good work " + userName
        self.endMissionButton.hidden = true
        
        if(numGamesPlayed > 4){
            self.endMissionButton.hidden = false

        }

        // Do any additional setup after loading the view.
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var endMissionButton: UIButton!
    
    @IBAction func endGame(sender: UIButton) {
            aD.endGame = true
    }

    
}