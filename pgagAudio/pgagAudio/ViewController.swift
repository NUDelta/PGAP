//
//  ViewController.swift
//  pgagAudio
//
//  Created by Shawn Caeiro on 4/7/16.
//  Copyright © 2016 Jennie Werner. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import CoreLocation
import CoreMotion


class ViewController: UIViewController, CLLocationManagerDelegate, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    //Database Names
    let OBJECT_DB = "WorldObject"   //label, location
    let MAPPING_DB = "WorldMapping" //name, affordance
    let GAMES_DB = "WorldTask" //title, task, conclusion, affordance duration, validated
    let STATEMENTS_DB = "WorldStatement" //name, text
    
    var locationManager: CLLocationManager!
    var currLocation: CLLocation?
    enum GameStatus {
        case preintro
        case playing
        case looking
        case snippet
        case postconclusion
    }
    var currGameStatus = GameStatus.preintro
    
    let aD = UIApplication.sharedApplication().delegate as! AppDelegate
    var numGamesPlayed : Int!
    
    var userName : String = ""
    var firstLoad : Bool!
    
    
    let synth = AVSpeechSynthesizer()
    
    var player : AVAudioPlayer! = nil
    
    let activityManager = CMMotionActivityManager()
    
    var gamesPlayed:[String] = []
    
    var currGame: (title: String, task: String, conclusion: String, duration: Int, obj: String, snippet: String?, affordance: String)! = nil
    
    @IBAction func replayAudio(sender: UIButton) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if( aD.firstLoad! == true){
            breifing()
            aD.firstLoad = false
        }
        
        self.userName = aD.userName
        self.numGamesPlayed = aD.numberGamesPlayed
        print(numGamesPlayed)
        
        // Do any additional setup after loading the view.
        
        // Create Location Manage
        locationManager = CLLocationManager();
        self.locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        self.synth.pauseSpeakingAtBoundary(.Word)
        self.synth.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currGameStatus == .looking {
            print(manager.location?.coordinate)
            currLocation = manager.location
            // TODO Save location to DB
            print(currGameStatus)
            
            
            let objects = getObjects(currLocation!)
            let affordances = getAffordances(objects)
            let game = getGame(affordances, gamesPlayed: gamesPlayed)
            if (game != nil) {
                currGame = game!
                playGame()
                gamesPlayed.append(game!.title)
            }
        }
    }
    
    func breifing() {
        let intro : [PFObject]
        let query = PFQuery(className: STATEMENTS_DB)
        
        query.whereKey("name", equalTo: "intro")
        do{
            try intro = query.findObjects()
            var introText = intro[0]["text"] as! String
            introText.replaceRange(introText.rangeOfString("***")!, with: userName )
            let utt = makeSpeechUtterance(introText)
            synth.speakUtterance(utt)
            
        }catch{}
    }
    
    
    func playGame() {
        print("Game Playing")
        self.numGamesPlayed = numGamesPlayed + 1
        aD.numberGamesPlayed = self.numGamesPlayed
        currGameStatus = GameStatus.playing
        
        player = makeAudioPlayer("beep", type: "wav")
        player.prepareToPlay()
        player.delegate = self
        player.play()
    }
    
    func waitForAction(aff: String, duration: Int) {
        _ = NSTimer.scheduledTimerWithTimeInterval(Double(duration), target: self, selector: Selector("timedOut"), userInfo: nil, repeats: false)
        
        let affordance = aff.componentsSeparatedByString(" ")[0]
        switch affordance {
        case "standing", "sitting":
            isStationary()
        default:
            print("No action detection available")
        }
    }
    
    func timedOut() {
        self.activityManager.stopActivityUpdates()
        let conclusion_speech = makeSpeechUtterance(currGame.conclusion)
        synth.speakUtterance(conclusion_speech)
        needConcl = false
        
    }
    
    func gameSucceeded() {
        let conclusion_speech = makeSpeechUtterance(currGame.conclusion)
        synth.speakUtterance(conclusion_speech)
        needConcl = false
    }
    
    
    
    func isStationary() {
        
        var standingTimer = NSTimer()
        print("IS IT WORKING?")
        
        if(CMMotionActivityManager.isActivityAvailable()){
            print("WORKING")
            self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data: CMMotionActivity?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if(data!.stationary == true){
                        standingTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("gameSucceeded"), userInfo: nil, repeats: false)
                    } else {
                        standingTimer.invalidate()
                    }
                })
                
            })
        }
        
    }
    
    
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        switch currGameStatus {
        case .playing:
            if(needConcl){
                waitForAction(currGame.affordance, duration: currGame.duration)
                //                let conclusion_speech = makeSpeechUtterance(currGame.conclusion)
                //                synth.speakUtterance(conclusion_speech)
                //                needConcl = false
            }else{
                //after conclusion finishes playing
                needConcl = true
                _ = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: "beginLooking", userInfo: nil, repeats: false)
                //                if ((currGame.snippet) != nil) {
                //                    _ = NSTimer.scheduledTimerWithTimeInterval(100, target:self, selector:"playSnippet", userInfo: currGame.snippet, repeats:false)
                //                }
            }
        case .snippet:
            currGameStatus = GameStatus.looking
        case .preintro:
            player = makeAudioPlayer("theme", type: "mp3")
            player.prepareToPlay()
            player.delegate = self
            player.play()
        case .postconclusion:
            currGameStatus = GameStatus.preintro
        default:
            break
        }
    }
    
    var needConcl = true
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully: Bool) {
        switch currGameStatus {
        case .playing:
            let task_speech = makeSpeechUtterance(currGame.task)
            task_speech.preUtteranceDelay = 1
            //task_speech.postUtteranceDelay = Double(currGame.duration)
            synth.speakUtterance(task_speech)
        case .preintro:
            _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "beginLooking", userInfo: nil, repeats: false)
        case .postconclusion:
            break
        default:
            break
        }
    }
    
    func beginLooking() {
        currGameStatus = GameStatus.looking
    }
    
    func playSnippet(timer: NSTimer) {
        if currGameStatus == .looking {
            currGameStatus = GameStatus.snippet
            let snippet = timer.userInfo as! String
            let snippet_speech = makeSpeechUtterance(snippet)
            snippet_speech.preUtteranceDelay = 5
            snippet_speech.postUtteranceDelay = 5
            synth.speakUtterance(snippet_speech)
        }
    }
    
    func makeAudioPlayer(file: String, type: String) -> AVAudioPlayer {
        
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
    
    func makeSpeechUtterance(speech: String) -> AVSpeechUtterance {
        let game_speech = AVSpeechUtterance(string: speech)
        game_speech.rate = 0.52
        game_speech.voice = AVSpeechSynthesisVoice(language: "en-ZA")
        game_speech.pitchMultiplier = 1.5
        return game_speech
    }
    
    func getObjects(loc: CLLocation) -> [String] {
        var objects:[String] = []
        var objects_nearby:[PFObject] = []
        
        let query = PFQuery(className: OBJECT_DB)
        let user_loc = PFGeoPoint(location:loc)
        query.whereKey("location", nearGeoPoint: user_loc, withinMiles: 0.01)
        do {
            try objects_nearby = query.findObjects()
            for obj in objects_nearby {
                let name = obj["label"] as! (String)
                if !objects.contains(name) {
                    objects.append(name)
                }
            }
        } catch {}
        return objects
    }
    
    func getAffordances(objects: [String]) -> [(affordance: String, obj: String)] {
        //print(objects)
        var affordance_objs:[(affordance: String, obj: String)] = []
        var affordance_names:[String] = []
        
        let query = PFQuery(className: MAPPING_DB)
        query.whereKey("name", containedIn: objects)
        do {
            var obj_affordances:[PFObject] = []
            try obj_affordances = query.findObjects()
            // Not necessarily in order of closest affordances!!!!!!!!!
            //print(obj_affordances)
            for a in obj_affordances {
                if !(affordance_names.contains(a["affordance"] as! String)){
                    affordance_objs.append((affordance: a["affordance"] as! String, obj: a["name"] as! String))
                    affordance_names.append(a["affordance"] as! (String))
                }
            }
        } catch {}
        return affordance_objs
    }
    
    func getGame(affordances: [(affordance: String, obj: String)], gamesPlayed: [String])
        -> (title: String, task: String, conclusion: String, duration: Int, obj: String, snippet: String?, affordance: String)? {
            var affordance_names:[String] = []
            for a in affordances {
                affordance_names.append(a.affordance)
            }
            
            let query = PFQuery(className: GAMES_DB)
            query.whereKey("affordance", containedIn: affordance_names)
            query.whereKey("title", notContainedIn: gamesPlayed)
            query.whereKey("validated", equalTo: true)
            query.limit = 1
            
            do {
                var games_possible:[PFObject] = []
                try games_possible = query.findObjects()
                
                // Not in order
                // TODO - How to use gamesPlayed... is it Global or do array references work as intended?
                if(!games_possible.isEmpty){
                    let g = games_possible[0]
                    var obj = ""
                    
                    for a in affordances {
                        if a.affordance == g["affordance"] as! String {
                            obj = a.obj
                        }
                    }
                    
                    var theGame = g["task"] as! String
                    var range = theGame.rangeOfString("[OBJECT]")
                    
                    while(range != nil){
                        theGame.replaceRange(range!, with: obj )
                        range = theGame.rangeOfString("[OBJECT]")
                        
                    }
                    
                    print(theGame)
                    
                    return (g["title"] as! String, theGame, g["conclusion"] as! String, g["duration"] as! Int, obj, g["snippet"] as! String?, g["affordance"] as! String)
                }
                
                
            } catch {}
            
            return nil
    }
    
    
    
    @IBAction func debrief() {
        if (currGameStatus == .looking || currGameStatus == .playing  ){
            
            currGameStatus = GameStatus.postconclusion
            
            let concl : [PFObject]
            let query = PFQuery(className: STATEMENTS_DB)
            query.whereKey("name", equalTo: "conclusion")
            do{
                try concl = query.findObjects()
                let conclText = concl[0]["text"] as! String
                
                let utt = makeSpeechUtterance(conclText)
                synth.speakUtterance(utt)
            }catch{}
        }
    }
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    //        let svc = segue.destinationViewController as! endController
    //        svc.name = userName
    //
    //    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}