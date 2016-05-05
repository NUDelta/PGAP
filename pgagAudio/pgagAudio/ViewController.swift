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
    var needConcl = true

    let aD = UIApplication.sharedApplication().delegate as! AppDelegate
    var numGamesPlayed : Int!
    
    var userName : String = ""
    var firstLoad : Bool!
    
    
    let synth = AVSpeechSynthesizer()
    var player : AVAudioPlayer! = nil
    
    var activityManager: CMMotionActivityManager!
    var motionManager: CMMotionManager!
    var recorder: AVAudioRecorder!
    var lowPassResults: Double = 0.0

    
    var gamesPlayed:[String] = []
    var snippetQ: [String] = []
    
    var currGame: (title: String, task: String, conclusion: String, duration: Int, obj: String, snippet: String?, affordance: String)! = nil
    
    // Timers
    var time_out_timer = NSTimer()
    var voice_timer = NSTimer()
    var jump_timer = NSTimer()
    
    @IBAction func replayAudio(sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userName = aD.userName
        self.numGamesPlayed = aD.numberGamesPlayed

        if( aD.firstLoad! == true){
            breifing()
            aD.firstLoad = false
        }
        
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
        
        createAudioRecorder()
        motionManager = CMMotionManager()
        activityManager = CMMotionActivityManager()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*****************************
     // Action Checker Logic
     ******************************/
    
    func waitForAction(aff: String, duration: Int) {
        time_out_timer = NSTimer.scheduledTimerWithTimeInterval(Double(duration), target: self, selector: Selector("timedOut"), userInfo: nil, repeats: false)
        
        let affordance = aff.componentsSeparatedByString(" ")[0]
        switch affordance {
        case "standing", "sitting":
            print("Stationary detection available")
            isStationary()
        case "jumping":
            print("Jump action available")
            isJumping()
        default:
            print("No action detection available")
            isVoice()
        }
    }
    
    func timedOut() {
        print("Timed Out")
        time_out_timer.invalidate()
        voice_timer.invalidate()
        jump_timer.invalidate()
        self.activityManager.stopActivityUpdates()
        motionManager.stopAccelerometerUpdates()
        recorder.stop()
        
        let conclusion_speech = makeSpeechUtterance(currGame.conclusion)
        synth.speakUtterance(conclusion_speech)
        needConcl = false
        
    }
    
    func gameSucceeded() {
        time_out_timer.invalidate()
        voice_timer.invalidate()
        jump_timer.invalidate()
        self.activityManager.stopActivityUpdates()
        motionManager.stopAccelerometerUpdates()
        recorder.stop()
        
        let conclusion_speech = makeSpeechUtterance(currGame.conclusion)
        synth.speakUtterance(conclusion_speech)
        needConcl = false
    }
    
    /*****************************
     // Action Checkers
     ******************************/
    
    func isVoice() {
        
        recorder.prepareToRecord()
        recorder.meteringEnabled = true
        
        recorder.record()
        voice_timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: Selector("voiceTimerCallback"), userInfo: nil, repeats: true)
    }
    
    func voiceTimerCallback() {
        recorder.updateMeters()
        if (recorder.averagePowerForChannel(0) > -10) {
            gameSucceeded()
        }
    }
    
    func isJumping() {
        print("checking for a jump")
        motionManager.startAccelerometerUpdates()
        jump_timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: Selector("jumpTimerCallback"), userInfo: nil, repeats: true)
    }
    
    func jumpTimerCallback() {
        if let accelerometerData = motionManager.accelerometerData {
            if (accelerometerData.acceleration.x > 1) || (accelerometerData.acceleration.y > 1) || (accelerometerData.acceleration.z > 1) {
                gameSucceeded()
            }
        }
    }

    func isStationary() {
        
        var standingTimer = NSTimer()
        print("IS IT WORKING?")
        
        if(CMMotionActivityManager.isActivityAvailable()){
            print("WORKING")
            self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data: CMMotionActivity?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if(data!.stationary == true){
                        print("Stationary!")
                        standingTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("gameSucceeded"), userInfo: nil, repeats: false)
                    } else {
                        print("Not Stationary")
                        standingTimer.invalidate()
                    }
                })
                
            })
        }
    }
    

    /*****************************
     // Delegates
     ******************************/
    
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
                if (game!.snippet != nil) {
                    snippetQ.append(game!.snippet!)
                }
                gamesPlayed.append(game!.title)
            }
        }
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        
        var snippet_timer = NSTimer()
        
        switch currGameStatus {
        case .playing:
            if(needConcl){
                snippet_timer.invalidate()
                waitForAction(currGame.affordance, duration: currGame.duration)
            }else{
                //after conclusion finishes playing
                needConcl = true
                snippet_timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "playSnippet", userInfo: nil, repeats: false)
                _ = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: "beginLooking", userInfo: nil, repeats: false)
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
    

    /*****************************
     // Game Queue Logic
     ******************************/
    func beginLooking() {
        currGameStatus = GameStatus.looking
    }
    
    func playSnippet() {
        if currGameStatus == .looking && !snippetQ.isEmpty {
            currGameStatus = GameStatus.snippet
            let snippet = snippetQ.removeFirst()
            let snippet_speech = makeSpeechUtterance(snippet)
            snippet_speech.preUtteranceDelay = 5
            snippet_speech.postUtteranceDelay = 2
            synth.speakUtterance(snippet_speech)
        }
    }
    
    func makeSpeechUtterance(speech: String) -> AVSpeechUtterance {
        let game_speech = AVSpeechUtterance(string: speech)
        game_speech.rate = 1.1 * AVSpeechUtteranceDefaultSpeechRate
        print(AVSpeechUtteranceDefaultSpeechRate)
        game_speech.voice = AVSpeechSynthesisVoice(language: "en-ZA")
        game_speech.pitchMultiplier = 1.5
        return game_speech
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
    
    
    /*****************************
    // Briefing and Debriefing
    ******************************/
    
    func breifing() {
        let intro : [PFObject]
        let query = PFQuery(className: STATEMENTS_DB)
        
        query.whereKey("name", equalTo: "intro")
        do{
            try intro = query.findObjects()
            var introText = intro[0]["text"] as! String
            print(userName)
            introText.replaceRange(introText.rangeOfString("***")!, with: userName )
            let utt = makeSpeechUtterance(introText)
            synth.speakUtterance(utt)
            
        }catch{}
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
    
    /*****************************
     // Audio Builders
     ******************************/
    
    func createAudioRecorder() {
        do {
            let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
        }
        catch {
        }
        
        //set up the URL for the audio file
        let documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
        let str =  documents.stringByAppendingPathComponent("recordTest.caf")
        let url = NSURL.fileURLWithPath(str as String)
        
        // make a dictionary to hold the recording settings so we can instantiate our AVAudioRecorder
        let recordSettings: [String : AnyObject] = [
            AVSampleRateKey:44100.0,
            AVNumberOfChannelsKey:2,AVEncoderBitRateKey:12800,
            AVLinearPCMBitDepthKey:16,
            AVEncoderAudioQualityKey:AVAudioQuality.Max.rawValue
        ]
        
        //Instantiate an AVAudioRecorder
        do {
            try recorder = AVAudioRecorder(URL:url, settings: recordSettings)
        }
        catch {
            
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