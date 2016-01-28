//
//  StartViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/12/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse
import ReplayKit
import CoreLocation
import GameKit
class StartViewController: UIViewController, CLLocationManagerDelegate {
    // Initial Home Screen
    
    var tasks: [PFObject] = []
    var a: [PFObject]?
    
    
    var generalLocations: [PFObject]?
    var commTasks: [PFObject] = []
    var locationManager: CLLocationManager!
    var currLocation: CLLocation? = nil
    
    /***********************
     // Free Play Game Start
     ************************/
    
    @IBAction func startExplore(sender: AnyObject) {
        let query = PFQuery(className:"exploreGames")
        do {a = try query.findObjects()}
        catch {}
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        a = [a![0], a![3], a![5], a![2], a![1], a![4]]
        
        if a![0]["gameType"] as! String == "button" {
            let svc : ButtonViewController = mainStoryboard.instantiateViewControllerWithIdentifier("buttonGame") as! ButtonViewController
            svc.modalTransitionStyle = .CrossDissolve
            svc.tasks = a!
            svc.game = 0
            presentViewController(svc, animated: true, completion: nil)
        }
        else if a![0]["gameType"] as! String == "pace"{
            let svc : PaceViewController = mainStoryboard.instantiateViewControllerWithIdentifier("pace") as! PaceViewController
            svc.modalTransitionStyle = .CrossDissolve
            svc.tasks = a!
            svc.game = 0
            svc.g = a![0]
            presentViewController(svc, animated: true, completion: nil)
        }
        else {
            let svc : ImageGViewController = mainStoryboard.instantiateViewControllerWithIdentifier("imageGame") as! ImageGViewController
            svc.modalTransitionStyle = .CrossDissolve
            presentViewController(svc, animated: true, completion: nil)
        }
    }
    
    /***********************
     // Time Based Game Start
     ************************/
    
    @IBAction func beginGame(sender: AnyObject) {
        self.performSegueWithIdentifier("startSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "startSegue") {
            let ViewControllerIn = (segue.destinationViewController as! ViewController)
            ViewControllerIn.timeLeft = 75
            
        }
    }
    
    /***********************
    // Begin Recording Tools
    ************************/

    @IBAction func stopRecording(sender: AnyObject) {
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.stopRecordingWithHandler { (previewVC, error) in
            if let vc = previewVC {
                self.presentViewController(
                    vc,
                    animated: true,
                    completion: nil
                )
            }
        }
    }
    @IBAction func startrRecord(sender: UIButton) {
        let recorder = RPScreenRecorder.sharedRecorder()
        recorder.startRecordingWithMicrophoneEnabled(true, handler: nil)
        
    }
    
    /***********************
     // Community Sourced Games
     ************************/
    
    @IBAction func commGameStart(sender: UIButton) {
        let commTasks = getTasks()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let svc : CommTextViewController = mainStoryboard.instantiateViewControllerWithIdentifier("commText") as! CommTextViewController
        svc.modalTransitionStyle = .CrossDissolve
        svc.commTasks = commTasks
        svc.gameIndex = 0
        presentViewController(svc, animated: true, completion: nil)

    }
    
    func getTasks() -> [PFObject] {
        let locQuery = PFQuery(className:"generalLocations")
        do {generalLocations = try locQuery.findObjects()}
        catch {}
        let area = determineLocation()
        
        let gameQuery = PFQuery(className:"commSourced")
        do {commTasks = try gameQuery.findObjects()}
        catch {}
        
        return chooseTasks(area, commTasks: commTasks)
    }
    
    func chooseTasks(area: String, commTasks: [PFObject]) -> [PFObject] {
        var chosenGames: [PFObject] = []
        for game in commTasks {
            if ((game[area] as! Bool) || (game["anywhere"] as! Bool)) {
                chosenGames.append(game)
            }
        }
        
        chosenGames = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(chosenGames) as! [PFObject]
        return chosenGames
    }
    
    func determineLocation() -> String {
        var closestLocation: String = ""
        var smallestDistance: CLLocationDistance?
        
        for area in generalLocations! {
            let areaLoc = area["location"]
            let distance = currLocation!.distanceFromLocation(CLLocation(latitude: areaLoc.latitude, longitude: areaLoc.longitude))
            if smallestDistance == nil || distance < smallestDistance {
                closestLocation = area["name"] as! String
                smallestDistance = distance
            }
        }
        print(closestLocation)
        print("CLOSEST LOCATION")
        return closestLocation

    }
     
     
    /***********************
     // Template Functions
     ************************/
    
    override func viewDidLoad() {
        locationManager = CLLocationManager();
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation();
        //orderGames()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(manager.location?.coordinate)
        currLocation = manager.location
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
