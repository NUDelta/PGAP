//
//  CommTextViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 1/28/16.
//  Copyright © 2016 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse

class CommTextViewController: UIViewController {

    @IBOutlet weak var gameText: UILabel!
    var commTasks: [PFObject]?
    var gameIndex: Int?
    var game: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        game = commTasks![gameIndex!]
        gameText.text = game!["description"] as? String

    }
    
    @IBAction func nextGame(sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let svc : CommTextViewController = mainStoryboard.instantiateViewControllerWithIdentifier("commText") as! CommTextViewController
        svc.modalTransitionStyle = .CrossDissolve
        svc.commTasks = self.commTasks
        svc.gameIndex = (self.gameIndex! + 1) % (commTasks!.count)
        presentViewController(svc, animated: true, completion: nil)
    }

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
