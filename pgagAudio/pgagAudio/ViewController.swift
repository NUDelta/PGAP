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

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
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
        case postconclusion
    }
    var currGameStatus = GameStatus.preintro
    
    var gamesPlayed:[String] = []
    
    
    
    
    
    func playIntro(introText: String){
        
        
        
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Create Location Manage
        locationManager = CLLocationManager();
        self.locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(manager.location?.coordinate)
        currLocation = manager.location
        // TODO Save location to DB
        
        if currGameStatus == .looking {
            let objects = getObjects(currLocation!)
            let affordances = getAffordances(objects)
            let game = getGame(affordances, gamesPlayed: gamesPlayed)
            if (game != nil) {
                playGame(game!)
                gamesPlayed.append(game!.title)
            }
        }
    }
    
    func playGame(game: (title: String, task: String, conclusion: String, duration: Int, obj: String)) {
        
        currGameStatus = GameStatus.playing
        
        let synth = AVSpeechSynthesizer()
        synth.pauseSpeakingAtBoundary(.Word)
        
        let alertPlayer = makeAudioPlayer("beep", type: "wav")
        alertPlayer.play()
        
        while alertPlayer.playing {
            // Do Nothing
        }
        
        let task_speech = makeSpeechUtterance(game.task)
        synth.speakUtterance(task_speech)
        
        while synth.speaking {
            // Do Nothing
        }
        
        // #HACK
        sleep(UInt32(game.duration))
        
        let synthC = AVSpeechSynthesizer()
        let conclusion_speech = makeSpeechUtterance(game.conclusion)
        synthC.speakUtterance(conclusion_speech)
        
        while synthC.speaking {
            // Do Nothing
        }
        
        sleep(UInt32(5))
        currGameStatus = GameStatus.looking
        
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
        game_speech.rate = 0.5
        game_speech.voice = AVSpeechSynthesisVoice(language: "en-GB")
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
    
    func getGame(affordances: [(affordance: String, obj: String)], var gamesPlayed: [String])
        -> (title: String, task: String, conclusion: String, duration: Int, obj: String)? {
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
                    
                    return (g["title"] as! String, g["task"] as! String, g["conclusion"] as! String, g["duration"] as! Int, obj)
                    
                }
                
                
            } catch {}
            
            return nil
    }
    
    
    
    
    //UI objects
    @IBAction func briefing() {
        if (currGameStatus == .preintro){
            let intro : [PFObject]
            let query = PFQuery(className: STATEMENTS_DB)
            query.whereKey("name", equalTo: "intro")
            do{
                try intro = query.findObjects()
                let introText = intro[0]["text"] as! String
                
                let synth = AVSpeechSynthesizer()
                let utt = makeSpeechUtterance(introText)
                synth.speakUtterance(utt)
                
                while(synth.speaking){
                    //do nothing
                }
                
                let musicPlayer = makeAudioPlayer("theme", type: "mp3")
                musicPlayer.play()
                
                while musicPlayer.playing {
                    // Do Nothing
                }
                
                sleep(UInt32(10))
                currGameStatus = GameStatus.looking
                
            }catch{}
            
            
        }
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
                
                let synth = AVSpeechSynthesizer()
                let utt = makeSpeechUtterance(conclText)
                synth.speakUtterance(utt)
                
                while(synth.speaking){
                    //do nothing
                }
                
                
            }catch{}
        }
        
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
