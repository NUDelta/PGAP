//
//  ResultsViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 12/3/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse

class ResultsViewController: UIViewController {

    @IBOutlet weak var carrotText: UILabel!
    @IBOutlet weak var resultsText: UILabel!
    @IBOutlet weak var endImage: UIImageView!
    var game: Int?
    var g: PFObject?
    var tasks: [PFObject]?
    var cc = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        cc = Int(arc4random_uniform(10) + 1)
        carrotText.text = "You've earned " + String(cc) + " carrots!"
        // Do any additional setup after loading the view.
        print("OHHHHHHWHAT")
        print(g!)
        let userImageFile = g!["picEnd"] as! PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    self.endImage.image = image
                }
            }
        }
        resultsText.text = g!["endCorrect"] as! String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func homeScreen(sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let svc : StartViewController = mainStoryboard.instantiateViewControllerWithIdentifier("startView") as! StartViewController
        svc.modalTransitionStyle = .CrossDissolve
        presentViewController(svc, animated: true, completion: nil)
    }
    @IBAction func nextGame(sender: UIButton) {
        
        var query = PFQuery(className:"carrots")
        query.getObjectInBackgroundWithId("qdLrKoWRK4") {
            (u: PFObject?, error: NSError?) -> Void in
            if error == nil {
                print("HOLYCRAPITWORKED")
                u!["carrotCount"] = u!["carrotCount"] as! Int + self.cc
                u!.saveInBackground()
            } else {
                print(error)
                print("LAKJSDKLJWIOFJAISFNCJWKFHAJFH")
            }
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        if tasks![(game! + 1) % 6]["gameType"] as! String == "button" {
            let svc : ButtonViewController = mainStoryboard.instantiateViewControllerWithIdentifier("buttonGame") as! ButtonViewController
            svc.modalTransitionStyle = .CrossDissolve
            svc.tasks = tasks
            svc.game = (game! + 1) % 6
            presentViewController(svc, animated: true, completion: nil)
        }
        else if tasks![(game! + 1) % 6]["gameType"] as! String == "pace"{
            let svc : PaceViewController = mainStoryboard.instantiateViewControllerWithIdentifier("pace") as! PaceViewController
            svc.modalTransitionStyle = .CrossDissolve
            svc.tasks = tasks
            svc.game = (game! + 1) % 6
            presentViewController(svc, animated: true, completion: nil)
        }
        else {
            let svc : ImageGViewController = mainStoryboard.instantiateViewControllerWithIdentifier("imageGame") as! ImageGViewController
            svc.modalTransitionStyle = .CrossDissolve
            svc.tasks = tasks
            svc.game = (game! + 1) % 6
            presentViewController(svc, animated: true, completion: nil)
        }
    }
    
    func displayCarrots() {
        var DynamicView=UIImageView(frame: CGRectMake(100, 200, 50, 100))
        
        //DynamicView.backgroundColor=UIColor.greenColor()
        //DynamicView.layer.cornerRadius=25
        //DynamicView.layer.borderWidth=2
        DynamicView.image = UIImage(named: "carrot")
        self.view.addSubview(DynamicView)
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
