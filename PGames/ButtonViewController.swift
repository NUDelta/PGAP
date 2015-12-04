//
//  ButtonViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 12/3/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse

class ButtonViewController: UIViewController {

    @IBOutlet weak var submitText: UIButton!
    @IBOutlet weak var gameText: UILabel!
    @IBOutlet weak var gameImg: UIImageView!
    var game: Int?
    var g: PFObject?
    var tasks: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        g = tasks![game!]
        submitText.setTitle("WHAT", forState: .Normal)
        gameText.text = g!["mainInfo"] as? String
        let userImageFile = g!["picGame"] as! PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    self.gameImg.image = image
                }
            }
        }

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func finishGame(sender: UIButton) {
        end()
    }
    
    func end() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let svc : ResultsViewController = mainStoryboard.instantiateViewControllerWithIdentifier("results") as! ResultsViewController
        svc.modalTransitionStyle = .CrossDissolve
        svc.game = self.game
        svc.g = g
        svc.tasks = tasks
        presentViewController(svc, animated: true, completion: nil)
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
