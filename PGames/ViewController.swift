//
//  ViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/12/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse
import GameplayKit

class ViewController: UIViewController {
    // Time Base Game Start View
    
    @IBOutlet weak var nextGame: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    var timeLeft:Int?
    var tasks = Array<Array<PFObject>>()
    var gameChoice = -1
    var tasksTmp = Array<Array<PFObject>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.redColor()
        //let tasks = [1,2,3]
        // Do any additional setup after loading the view, typically from a nib.
        countDownLabel.text = String(timeLeft!--)
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)

        let games = ["countGames", "imageGames", "tasks", "actionGames"]
        for (index, element) in games.enumerate() {
            print("\(element)")
            let query = PFQuery(className:element)
            print("HUH")
            do {
                try tasks.append(query.findObjects())
                print("EH")
            } catch {
                print("NOO")
            }
            tasks[index] = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(tasks[index]) as! [PFObject]
        }
        print(tasks)
        tasksTmp.append([tasks[0][2],tasks[0][1]])
        tasksTmp.append([tasks[1][2],tasks[1][0]])
        tasksTmp.append([tasks[2][3],tasks[2][5]])
        tasksTmp.append([tasks[3][0]])
        //tasks = tasksTmp
        
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
            ViewControllerIn.game = tasks[gameChoice].removeFirst()
        }
        else if (segue.identifier == "imageSegue") {
            let ViewControllerIn = (segue.destinationViewController as! ImageViewController)
            ViewControllerIn.mainController = self
            ViewControllerIn.timeLeft = timeLeft
            ViewControllerIn.game = tasks[gameChoice].removeFirst()
        }
        else if (segue.identifier == "shakeSegue") {
            let ViewControllerIn = (segue.destinationViewController as! ShakeViewController)
            ViewControllerIn.mainController = self
            ViewControllerIn.timeLeft = timeLeft
            ViewControllerIn.game = tasks[gameChoice].removeFirst()
        }
        else if (segue.identifier == "countSegue") {
            let ViewControllerIn = (segue.destinationViewController as! CountViewController)
            ViewControllerIn.mainController = self
            ViewControllerIn.timeLeft = timeLeft
            ViewControllerIn.game = tasks[gameChoice].removeFirst()
        }
        
        
        
        
    }

    @IBAction func beginGame(sender: UIButton) {
        gameChoice = getNextGame(gameChoice)
        goNext()
    }
    
    
    
    override func viewWillAppear(animated: Bool)
    {
        //super.viewWillAppear(animated)
        UIView.animateWithDuration(1.3, animations: {
            self.view.backgroundColor = UIColor.greenColor()
            }, completion: { animationFinished in
                self.view.backgroundColor = UIColor.redColor()
        })
        let _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("goNext"), userInfo: nil, repeats: false)
    }
    
    func goNext() {
        gameChoice = getNextGame(gameChoice)
        switch gameChoice {
        case 0:
            self.performSegueWithIdentifier("countSegue", sender: self)
        case 1:
            self.performSegueWithIdentifier("imageSegue", sender: self)
        case 2:
            self.performSegueWithIdentifier("textSegue", sender: self)
        case 3:
            self.performSegueWithIdentifier("shakeSegue", sender: self)
        default:
            break
        }
    }
    
    func getNextGame(lastGame: Int) -> Int {
        var gamesAvailable = Array<Int>()
        for (i, e) in tasks.enumerate() {
            if e.count != 0{
                gamesAvailable.append(i)
                if i != lastGame {
                    gamesAvailable.append(i)
                    gamesAvailable.append(i)
                }
            }
            else {
                print("\(i)")
            }
        }
        return gamesAvailable[Int(arc4random_uniform(UInt32(gamesAvailable.count)))]
    }
    
    @IBAction func goHome(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        
        if(timeLeft > 0)
        {
            countDownLabel.text = String(timeLeft!--)
            countDownLabel.font = countDownLabel.font.fontWithSize(CGFloat(50 + (75 - timeLeft!) * 4 ))
        }
        else
        {
            countDownLabel.font = countDownLabel.font.fontWithSize(CGFloat(50))
            countDownLabel.text = "Time's Up!"
            nextGame.enabled = false
            nextGame.hidden = true
            //playAgainButton.hidden = false
        }
        
    }

}

