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
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var ratingsValue: UILabel!
    @IBOutlet weak var ratingsSlider: UISlider!
    @IBOutlet weak var objMap: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var labelLat: UILabel!
    @IBOutlet weak var labelNearLocation: UILabel!
    @IBOutlet weak var labelChangeLocation: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var feedbackText: UILabel!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var scoreText: UILabel!

    // Variables
    var locCalls = 0
    var nameText = "Name"
    var playedGames : [String] = []
    var recentlyPlayed = true
    var locationManager: CLLocationManager!
    var currLocation: CLLocation? = nil
    
    var currGame: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        nameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.nameTextField.delegate = self;
        
        locationManager = CLLocationManager();
        self.locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation();
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        objMap.showsUserLocation = true;
        objMap.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        addAnnotations()
        
        feedbackText.hidden = true
        submitButton.hidden = true
        ratingsValue.hidden = true
        ratingsSlider.hidden = true
        
//        var silentPlayer : AVAudioPlayer!
//        let path = NSBundle.mainBundle().pathForResource("nothing" as String, ofType: "mp3" as String)
//        let url = NSURL.fileURLWithPath(path!)
//    
//        do {
//            try silentPlayer = AVAudioPlayer(contentsOfURL: url)
//        } catch {
//            print("can't play silence")
//        }
//
//        silentPlayer.play()
        
        createLocalStorage()
    }
    
    func createLocalStorage() {
        let queryObjects = PFQuery(className:"WorldObject")
        queryObjects.limit = 1000
        queryObjects.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) Objects for local storage.")
                if let objects = objects {
                    PFObject.pinAllInBackground(objects)
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        let queryGames = PFQuery(className:"WorldGame")
        queryGames.limit = 1000
        queryGames.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) Games for Local Storage.")
                if let objects = objects {
                    PFObject.pinAllInBackground(objects)
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
 
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(manager.location?.coordinate)
        currLocation = manager.location
        saveLocation()
        gamesNearby()
        if(!recentlyPlayed){
            print("calling find location")
            findLocation()
        }
    }
    
    //saves the user's locaiton into a parse database
    func saveLocation(){
        let gamePlay = PFObject(className:"WorldPlayLoc")
        gamePlay["username"] = nameText
        gamePlay["userLocation"] =  PFGeoPoint(location:currLocation)
        gamePlay.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
            } else {
            }
        }
        
        labelLat.text = String((currLocation?.coordinate.latitude)!) + ", " + String((currLocation?.coordinate.longitude)!)
    }
    
    func gamesNearby() {
        let query = PFQuery(className:"WorldObject")
        query.whereKey("location", nearGeoPoint:PFGeoPoint(location:currLocation), withinMiles:0.1)
        query.fromLocalDatastore()
        query.limit = 100
        query.findObjectsInBackgroundWithBlock {
            (foundObjs: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if (foundObjs!.count == 0){
                    self.statusText.text = "ALERT: No tasks within 500 feet. Keep exploring."
                    self.statusText.textColor = UIColor.redColor()
                }
                else if let foundObjs = foundObjs {
                    var objectLabels = Set<String>()
                    for obj in foundObjs {
                        objectLabels.insert(obj["label"] as! String)
                    }
                    for label in objectLabels {
                        let queryGames = PFQuery(className:"WorldGame")
                        queryGames.whereKey("object", equalTo: label)
                        query.fromLocalDatastore()
                        queryGames.findObjectsInBackgroundWithBlock {
                            (foundGames: [PFObject]?, error: NSError?) -> Void in
                            if error == nil {
                                if let foundGames = foundGames{
                                    for game in foundGames{
                                        let fileName = game["fileName"] as! String
                                        self.currGame = fileName
                                        
                                        if (!self.playedGames.contains(fileName)){
                                            self.statusText.text = "Tasks are nearby!"
                                            self.statusText.textColor = UIColor.greenColor()
                                            return
                                        }
                                    }
                                    //self.statusText.text = "ALERT: No tasks within 500 feet. Keep exploring."
                                    //self.statusText.textColor = UIColor.blueColor()
                                }
                            } else{
                                print("Error: \(error!) \(error!.userInfo)")
                            }
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
    
    }
    
    func findLocation(){
        let query = PFQuery(className:"WorldObject")
        query.whereKey("location", nearGeoPoint:PFGeoPoint(location:currLocation), withinMiles:0.01)
        query.limit = 5
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock {
            (foundObjs: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(foundObjs!.count) nearby objects.")
                if (foundObjs!.count == 0){
                    print("no nearby objects found")
                }
                else if let foundObjs = foundObjs {
                    var objectLabels = Set<String>()
                    for obj in foundObjs {
                        objectLabels.insert(obj["label"] as! String)
                    }
                    for object in objectLabels {
                        let queryGames = PFQuery(className:"WorldGame")
                        queryGames.whereKey("object", equalTo: object)
                        queryGames.fromLocalDatastore()
                        queryGames.findObjectsInBackgroundWithBlock {
                            (foundGames: [PFObject]?, error: NSError?) -> Void in
                            if error == nil {
                                print("Successfully retrieved \(foundGames!.count) nearby games.")
                                if let foundGames = foundGames{
                                    for game in foundGames{
                                        print(game)
                                        let fileName = game["fileName"] as! String
                                        let fileType = game["fileType"] as! String
                                        let fileTime = game["timeNeeded"] as! Double
                                        self.currGame = fileName
                                        
                                        if (!self.recentlyPlayed && !self.playedGames.contains(fileName)){
                                            self.playedGames.append(fileName)
                                            print("About to play \(fileName)")
                                            self.recentlyPlayed = true;
                                            self.makePlayGame(fileName, gType: fileType, gTime: fileTime)
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
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func makePlayGame(gName:String, gType:String, gTime: Double){
        print("makePlay called")

        let intro = AVPlayerItem.init(URL: NSURL.fileURLWithPath((NSBundle.mainBundle().pathForResource("beep", ofType: "wav"))!))
        let game = AVPlayerItem.init(URL: NSURL.fileURLWithPath((NSBundle.mainBundle().pathForResource(gName as String, ofType: gType as String))!))
        
        avPlayer.insertItem(intro, afterItem: nil)
        avPlayer.insertItem(game, afterItem: intro)
        avPlayer.play()
        
        let _ = NSTimer.scheduledTimerWithTimeInterval(gTime, target: self, selector: "sendConfirmation", userInfo: nil, repeats: false)
        let _ = NSTimer.scheduledTimerWithTimeInterval(gTime+15, target: self, selector: "updateRecentlyPlayed", userInfo: nil, repeats: false)
        
    }
    
    func saveGamePlayData(object:String, game:PFObject) {
        var gamePlay = PFObject(className:"WorldPlayUserData")
        gamePlay["username"] = nameText
        gamePlay["userLocation"] =  PFGeoPoint(location:currLocation)
        //gamePlay["objectID"] = object.objectId
        gamePlay["object"] = object
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
    
    func sendConfirmation(){
        let conf = AVPlayerItem.init(URL: NSURL.fileURLWithPath((NSBundle.mainBundle().pathForResource("goodWork", ofType: "m4a"))!))
        avPlayer.insertItem(conf, afterItem: nil)
        avPlayer.play()
        let score = Int(scoreText.text!)! + 5
        scoreText.text = String(score)
        
        askForFeedback()
    }
    
    func updateRecentlyPlayed(){
        recentlyPlayed = false
    }
    
    func askForFeedback() {
        feedbackText.text = "Please rate your enjoyment of the last game."
        ratingsValue.text = "5"
        feedbackText.hidden = false
        submitButton.hidden = false
        ratingsValue.hidden = false
        ratingsSlider.value = 5
        ratingsSlider.hidden = false
    }
    
    @IBAction func submitRating(sender: UIButton) {
        let gamePlay = PFObject(className:"WorldGameRating")
        gamePlay["username"] = nameText
        gamePlay["location"] =  PFGeoPoint(location:currLocation)
        gamePlay["game"] = currGame
        gamePlay["rating"] = ratingsSlider.value 
        gamePlay.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
            } else {
            }
        }
        feedbackText.text = "Thank you!"
        submitButton.hidden = true
        ratingsValue.hidden = true
        ratingsSlider.hidden = true
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        var selectedValue = Int(sender.value)
        ratingsValue.text = String(stringInterpolationSegment: selectedValue)
    }

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
        playQueue(["Intro1", "Intro2", "theme"], types: ["m4a", "m4a", "mp3"])
//        playSound("Intro1", type: "m4a")
//        let _ = NSTimer.scheduledTimerWithTimeInterval(26, target: self, selector: "introB", userInfo: nil, repeats: false)
//        let _ = NSTimer.scheduledTimerWithTimeInterval(41, target: self, selector: "introC", userInfo: nil, repeats: false)
          let _ = NSTimer.scheduledTimerWithTimeInterval(57, target: self, selector: "updateRecentlyPlayed", userInfo: nil, repeats: false)
    }
    
    func introB() {
        playSound("Intro2", type: "m4a")
    }
    
    func introC() {
        playSound("theme", type: "mp3")
    }
    
    @IBAction func endGame() {
        playSound("Conclusion", type: "m4a")
    }

    func addAnnotations() {
        let query = PFQuery(className:"WorldObject")
        query.limit = 1000
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock {
            (foundObjs: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let foundObjs = foundObjs {
                    for obj in foundObjs {
                        self.objMap.addAnnotation(worldObject(title: obj["label"] as! String, coordinate: CLLocationCoordinate2D(latitude: obj["location"].latitude, longitude: obj["location"].longitude)))
                    }
                }
            }
            else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    
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
    
    var qPlayer = AVQueuePlayer()

    
    func playQueue(files:[String], types:[String]){
        print("PLAYING")
        var items : [AVPlayerItem] = []
        for (var i = 0;  i < files.count; i++){
            let path = NSBundle.mainBundle().pathForResource(files[i] as String, ofType: types[i] as String)
            let url = NSURL.fileURLWithPath(path!)
            let sound = AVPlayerItem.init(URL: url)
            items.append(sound)
        }
        qPlayer = AVQueuePlayer(items: items)
        qPlayer.play()
    }
    
    var avPlayer = AVQueuePlayer()
    
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
    
    // Deleted from saveLocation
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
    
    // Deleted from makeGamePlay
    
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

*/
    
   
}

