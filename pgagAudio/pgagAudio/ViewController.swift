//
//  ViewController.swift
//  pgagAudio
//
//  Created by Jennie Werner on 1/31/16.
//  Copyright © 2016 Jennie Werner. All rights reserved.
//

import UIKit
import AVFoundation //add framework to Build Phases
import Parse //add to stuff to Build Phases, set-up db in AppDelegate
import CoreLocation //add location to info


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //initalize Parse global variables
    var userData = PFObject(className: "UserData")
    var gameLoc : String = "home"{
        
        willSet{
            labelChangeLocation.text = "false"
        }
        
        didSet{
            
//NEED TO ADD A CHECK IF gameLoc HAS CHANGED TO A NULL VALUE BC NOT NEAR A NEW LOCATION
//!!!!!!!!!!!!!!!!!!!!!!
            
            if (gameLoc != oldValue && gameLoc != "empty") {
                //check if the user has reached a new game location
                //  and trigger audio
                playGameAudio(gameLoc)
                labelChangeLocation.text = "true"
            }
        }
    }
    
    
    //initalize location global variables
    var locationManager: CLLocationManager!
    var currLocation: CLLocation? = nil
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(manager.location?.coordinate)
        currLocation = manager.location
        saveLocation()
        findLocation()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initalize loaction manager details
        locationManager = CLLocationManager();
        self.locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation();
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
   
    
    //Check Parse DB for a nearby location, and if so, update gameLoc
    func findLocation(){
        let query = PFQuery(className:"generalLocations")
        // Interested in locations near user.
        query.whereKey("location", nearGeoPoint:PFGeoPoint(location:currLocation), withinMiles:0.1)

        // Limit what could be a lot of points.
        query.limit = 1
        // Final list of objects
        query.findObjectsInBackgroundWithBlock {
            (foundObj: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(foundObj!.count) locations.")
                // Do something with the found objects
                if let foundObj = foundObj {
                    for object in foundObj {
                        self.gameLoc = object["name"] as! String
                        print(self.gameLoc)
                        self.labelNearLocation.text = self.gameLoc
                    }
                }
            } else {
                // Log details of the failure
                
//TEST TEST TEST CAN YOU SET gameLoc TO EMPTY IF NOTHING NEARBY
//!!!!!!!!!!!
                self.gameLoc = "empty"
                print("Error: \(error!) \(error!.userInfo)")
            }
        }

    }
    
    //pull the name of the correct audio file based on user's location and play it
    func playGameAudio(gameLoc: String){
        print("playGameAudio called")
        let query = PFQuery(className:"generalLocations")
        query.whereKey("name", equalTo: gameLoc)
        
        query.findObjectsInBackgroundWithBlock {
            (foundObj: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                if let foundObj = foundObj {
                    for object in foundObj {
                        print(object.objectId)
                        let audioFile = object["audioFile"] as! String
                        self.makePlay(audioFile)
                    }
                }
            } else {
                // Log details of the failure
                print("Error in playGameAudio: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    //saves the user's locaiton into a parse database
    func saveLocation(){
        //display location in UI
        let lat: Double = (currLocation?.coordinate.latitude)!
         labelLat.text = String(format: "%f", lat)
        let long: Double = (currLocation?.coordinate.longitude)!
        labelLong.text = String(format: "%f", long)
        
        //save User's current location in parse db
        userData["location"] =  PFGeoPoint(location:currLocation)
        userData.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                print("location saved")
            } else {
                // There was a problem, check error.description
                print("error in SaveLocatoin")
            }
        }
    
    }
    

    //inialize UI element labels
    @IBOutlet weak var labelLat: UILabel!
    @IBOutlet weak var labelLong: UILabel!
    @IBOutlet weak var labelNearLocation: UILabel!
    @IBOutlet weak var labelChangeLocation: UILabel!
    
    
//************************
//AUDIO PLAYING SETUP
//************************
    
    //initalize audio player instance
    var thePlayer : AVAudioPlayer!
    
    //set up for audio, turn string into file path, check if audio play can play, etc.
    //  takes file name and file type as an argument
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
    
        //check if file can be found
        if (NSBundle.mainBundle().pathForResource(file as String, ofType: type as String) != nil){
        }else{
            print("no file \(file) found")
        }
        
//MOVE THIS INTO THE IF CLAUSE
        //define file path
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
    
//CAN I USE thePlayer HERE WHY DID I CREATE A NEW VARIABLE???
        var audioPlayer:AVAudioPlayer!
    
        //create the player with the specific audio file
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    //given an audio file name, make it play
    func makePlay(fileName:String){
        print("makePlay called")
        
        //call set-up using the give file name and type of mp3
        if let helloPlayer = self.setupAudioPlayerWithFile(fileName, type: "mp3"){
            self.thePlayer = helloPlayer
        }else{
            print("error in makePlay when called with \(fileName)")
        }
        
        //start playing!
        thePlayer?.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }


    
   
}

