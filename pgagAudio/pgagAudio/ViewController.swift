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


class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    var nameText = "Name"
    func textFieldDidChange(textField: UITextField) {
        if nameTextField.text != nil {
            nameText = nameTextField.text!
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func introGame() {
       // let a = playQueue(["Intro1", "Intro2", "theme"], types: ["m4a", "m4a", "mp3"])
       // a.play()
        
        playSound("Intro1", type: "m4a")
    }
    
    @IBAction func endGame() {
        playSound("Conclusion", type: "m4a")

    }
    
    
    var playedGames : [String] = []
    var recentlyPlayed = false
    
    //initalize Parse global variables
    var userData = PFObject(className: "UserData")
    
    
    //initalize location global variables
    var locationManager: CLLocationManager!
    var currLocation: CLLocation? = nil
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(manager.location?.coordinate)
        currLocation = manager.location
        saveLocation()
        
     
        if(!recentlyPlayed){
            print("calling find location")
            findLocation()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initalize loaction manager details
        nameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.nameTextField.delegate = self;

        locationManager = CLLocationManager();
        self.locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation();
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    
    }
   
    
    
    
//get points from WorldDatabse
    
    func findLocation(){
        let query = PFQuery(className:"WorldObject")
        // Interested in locations near user.
        query.whereKey("location", nearGeoPoint:PFGeoPoint(location:currLocation), withinMiles:0.01)

        // Limit what could be a lot of points.
        query.limit = 5
        
        // Final list of objects
        query.findObjectsInBackgroundWithBlock {
            (foundObjs: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(foundObjs!.count) locations.")
                // Do something with the found objects
                
                if (foundObjs!.count == 0){
                    print("no nearby objects found")
                    
                }
                else if let foundObjs = foundObjs {
                    for object in foundObjs {
                        //STORE IN AN ARRAY
                        
                        let queryGames = PFQuery(className:"WorldGame")
                        queryGames.whereKey("object", equalTo: object["label"])
                        
                        queryGames.findObjectsInBackgroundWithBlock {
                            (foundGames: [PFObject]?, error: NSError?) -> Void in
                            
                            if error == nil {
                                print("Successfully retrieved \(foundGames!.count) games.")
                                if let foundGames = foundGames{

                                    for game in foundGames{
                                        print(game)
                                    
                                        let fileName = game["fileName"] as! String
                                        let fileType = game["fileType"] as! String
                                    
                                        if (!self.recentlyPlayed && !self.playedGames.contains(fileName)){
                                            self.playedGames.append(fileName)
                                            print("About to play \(fileName)")
                                            print("already played \(self.playedGames)")
                                            self.recentlyPlayed = true;
                                            self.makePlayGame(fileName, gType: fileType)
                                            self.saveGamePlayData(object, game: game)
                          
                                            return
                                        }

                                    }
                                }
                                
                            }else{
                                print("Error: \(error!) \(error!.userInfo)")

                            }
                        }
                        
                    
                    }
                }
            } else {
                // Log details of the failure

                print("Error: \(error!) \(error!.userInfo)")
            }
        }

    }
    
    func saveGamePlayData(object:PFObject, game:PFObject) {
        var gamePlay = PFObject(className:"WorldPlayData")
        gamePlay["username"] = nameText
        gamePlay["userLocation"] =  PFGeoPoint(location:currLocation)
        gamePlay["objectID"] = object.objectId
        gamePlay["object"] = object["label"]
        gamePlay["gameID"] = game.objectId
        gamePlay["game"] = game["gameName"]
        gamePlay.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
        }
    }
    
    //saves the user's locaiton into a parse database
    func saveLocation(){
        var gamePlay = PFObject(className:"WorldPlayLoc")
        gamePlay["username"] = nameText
        gamePlay["userLocation"] =  PFGeoPoint(location:currLocation)
        gamePlay.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
        }

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
    
//LIFE QUESTION: when to create new audio players versus reset
    
    //initalize audio player instance
    var thePlayer : AVAudioPlayer!
    
    //set up for audio, turn string into file path, check if audio play can play, etc.
    //  takes file name and file type as an argument
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        
        //define file path
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
    
        var audioPlayer:AVAudioPlayer!
    
        //create the player with the specific audio file
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    
    func playSound(file:String, type:String){
        
        if let helloPlayer = self.setupAudioPlayerWithFile(file, type: type){
            self.thePlayer = helloPlayer
        }
        
        //start playing!
        thePlayer?.play()
        
    }
    
    
    func playQueue(files:[String], types:[String]) -> AVQueuePlayer!{
        
        var qPlayer = AVQueuePlayer()
        var prev : AVPlayerItem! = nil
        
        for (var i = 0;  i < files.count; i++){
            print("OK")
            let sound = AVPlayerItem.init(URL: NSURL.fileURLWithPath((NSBundle.mainBundle().pathForResource(files[i], ofType: types[i]))!))
            qPlayer.insertItem(sound, afterItem: prev)
            prev = sound;
            
        }
        print(qPlayer)
        return qPlayer
        
    }
    
    
    var avPlayer = AVQueuePlayer()
    
    //given an audio file name, make it play
    func makePlayGame(gName:String, gType:String){
        print("makePlay called")
        
        
        let intro = AVPlayerItem.init(URL: NSURL.fileURLWithPath((NSBundle.mainBundle().pathForResource("beep", ofType: "wav"))!))
        let game = AVPlayerItem.init(URL: NSURL.fileURLWithPath((NSBundle.mainBundle().pathForResource(gName as String, ofType: gType as String))!))
        
        avPlayer.insertItem(intro, afterItem: nil)
        avPlayer.insertItem(game, afterItem: intro)
        
        avPlayer.play()
        
        let _ = NSTimer.scheduledTimerWithTimeInterval(28, target: self, selector: "sendConfirmation", userInfo: nil, repeats: false)
        
        /*
        //call set-up using the give file name and type of mp3
        if let helloPlayer = self.setupAudioPlayerWithFile(gName, type: gType){
            self.thePlayer = helloPlayer
        }else{
            print("error in makePlay when called with \(gName)")
        }
        
        //start playing!
        thePlayer?.play()
*/
        let _ = NSTimer.scheduledTimerWithTimeInterval(45, target: self, selector: "updateRecentlyPlayed", userInfo: nil, repeats: false)
        
    }
    
    func updateRecentlyPlayed(){
        recentlyPlayed = false
    }
    
    func sendConfirmation(){
        let conf = AVPlayerItem.init(URL: NSURL.fileURLWithPath((NSBundle.mainBundle().pathForResource("confirm", ofType: "wav"))!))
        
        avPlayer.insertItem(conf, afterItem: nil)
        avPlayer.play()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    
    
    
    
    
    
    
    //DELETE
    
  /*  func setupAudioPlayerFromParse(gameName: String, audioType: String) -> AVAudioPlayer? {
        
        var audioPlayer:AVAudioPlayer!
        let query = PFQuery(className:"generalLocations")
        query.whereKey("name", equalTo: gameName )
        
        query.findObjectsInBackgroundWithBlock() {
            (foundObj: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let foundObj = foundObj {
                    for object in foundObj {
                        print("the object is \(object)")
                        
                        let file = object["actualAudio"] as! PFFile
                        file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if let data = data where error == nil{
                                
                                do {
                                    try audioPlayer = AVAudioPlayer(data: data)
                                } catch {
                                    print("Player not available")
                                }
                            }
                        })
                        
                    }
                }
                
            } else {
                
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
        //create the player with the specific audio file
        
        
        return audioPlayer
        
    }

    var gameLoc : String = "home"{
    
    willSet{
    }
    
    didSet{
    if (gameLoc != oldValue && gameLoc != "empty" && gameLoc != "hydrant") {
    //check if the user has reached a new game location
    //  and trigger audio
    playGameAudio(gameLoc)
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
                        let gameName = object["name"] as! String
                       // self.makePlay(gameName)
                    }
                }
            } else {
                // Log details of the failure
                print("Error in playGameAudio: \(error!) \(error!.userInfo)")
            }
        }
    }

    
    func distanceFromPoints(){
    
    let query = PFQuery(className:"generalLocations")
    
    query.findObjectsInBackgroundWithBlock {
    (foundObj: [PFObject]?, error: NSError?) -> Void in
    
    if error == nil {
    // The find succeeded.
    print("Successfully retrieved \(foundObj!.count) locations.")
    // Do something with the found objects
    
    
    if let foundObj = foundObj {
    for object in foundObj {
    let loc = object["location"]
    let myLoc = PFGeoPoint(location:self.currLocation)
    
    let dist = loc?.distanceInMilesTo(myLoc)
    print("\(object["name"]) is \(dist) miles away");
    
    self.displayDistances.text = self.displayDistances.text!  + "\n" + "\(object["name"]) is \(dist) miles away"
    }
    }
    
    } else {
    // Log details of the failure
    
    print("Error: \(error!) \(error!.userInfo)")
    }
    }
    
    
    }

*/
    
   
}

