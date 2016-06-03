//
//  ViewController.swift
//  pgapDemo
//
//  Created by Jennie Werner on 6/3/16.
//  Copyright © 2016 Jennie Werner. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var actionLabel: UILabel!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    let synth = AVSpeechSynthesizer()
    var player : AVAudioPlayer! = nil
    var recorder: AVAudioRecorder!
    
    var motionManager: CMMotionManager!

    var activityManager :CMMotionActivityManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
 
        myGames.append(game0)
        myGames.append(game1)
        myGames.append(game2)
        successText.append(s0)
        successText.append(s1)
        successText.append(s1)
        
        failureText.append(f0)
        failureText.append(f1)
        failureText.append(f2)


        
        

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

    
    @IBAction func playGameButton() {
        curr = (curr+1)%3
        print("playing game")
        print(curr)
        playGame()
    }
  
    var needConcl = true
    
    let game0 = "Attention, spy. Look around the room and count how many people you see ahead of you. Communicate that message through your receiver. "
    let game1 = "Attention, comrade one of our satellites have been shot down and we need your help sending a radio signal to our satellite passing overhead. Stand and hold your phone as high as possible so we can use it as a secure intermediary device to bounce our radio signal off of. Make sure to keep your phone still."
    let game2 = "Attention, spy. You’re passing over the entrance that leads to one of our underground base. Jump on the [OBJECT] to let our team know you are passing overhead in case they need you to collect above ground intel. "


    var f0 = "FAILURE: Sorry comrade, we did not pick up that message, but you may move on. We will have another spy retrieve that information."
    var f1 = "FAILURE: We keep getting an error and couldn’t send the signal. Just keep moving and there might be another opportunity."
    var f2 = "FAILURE: Our team didn’t heard you, next time try to send a clearer signal."

    var s0 = "SUCCESS: Thank you spy. This information will be sent to operations to help distribute rations."
    var s1 = "SUCCESS: We were able to bounce the signal! Let's hope it goes through."
    var s2 = "SUCCESS: Team Scion heard you — be careful, they think Bartley could be nearby."

    var myGames : [String] = []
    var successText : [String] = []
    var failureText : [String] = []


    var curr = 0
    
    
    func playGame() {
        switch curr {
        case 1:
            actionLabel.text = "STAND STILL"
        case 2:
            actionLabel.text = "JUMP"
            
        default:
            actionLabel.text = "SAY 'roger that'"
            
        }
        self.resultLabel.text = "waiting for action"
        
        player = makeAudioPlayer("beep", type: "wav")
        player.prepareToPlay()
        player.delegate = self
        player.play()
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
        
        //pick correct voice speed based on iOS
        let os = NSProcessInfo().operatingSystemVersion
        switch (os.majorVersion, os.minorVersion, os.patchVersion) {
        case (9, _, _):
            game_speech.rate = 0.52
        default:
            game_speech.rate = 0.2
        }
        
        game_speech.voice = AVSpeechSynthesisVoice(language: "en-ZA")
        game_speech.pitchMultiplier = 1.5
        return game_speech
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        print("end of speech synth")
        if(voiceInstructions){
            isVoice()
            voiceInstructions = false
        }else if(needConcl){
            waitForAction(myGames[curr], duration: 30)
        }else{
            needConcl = true
        }
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully: Bool) {
        print("audio player finished")
        let task_speech = makeSpeechUtterance(myGames[curr])
        task_speech.preUtteranceDelay = 1
        print(task_speech)
        synth.speakUtterance(task_speech)
    }
    
    var voiceInstructions : Bool = false
    var time_out_timer = NSTimer()
    var voice_timer = NSTimer()
    
    func waitForAction(aff: String, duration: Int) {
        time_out_timer = NSTimer()
        time_out_timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("timedOut"), userInfo: nil, repeats: false)
        
        let affordance = curr
        switch affordance {
        case 1:
            print("Stationary detection available")
            
            isStationary()
            //checkForJump()
        case 2:
            print("Jump action available")
            checkForJump()
            
        default:
            print("No action detection available")
            voiceInstructions = true
            
            let instructions = makeSpeechUtterance("Once you've completed the task, say Roger that into your mic to confirm")
            synth.speakUtterance(instructions)
            
            
            
        }
    }
    
    func timedOut() {
        print("Timed Out")
        resultLabel.text = "Failure"
        
        time_out_timer.invalidate()
        voice_timer.invalidate()
        standingTimer.invalidate()
        self.activityManager.stopActivityUpdates()
        
        self.Jtimer.invalidate()
        self.resetTimer.invalidate()
        self.motionMan.stopAccelerometerUpdates()
        
        recorder.stop()
        let conclusion_speech = makeSpeechUtterance(failureText[curr])
        needConcl = false

        synth.speakUtterance(conclusion_speech)
        
    }
    
    func gameSucceeded() {
        
        resultLabel.text = "Success"
        
        time_out_timer.invalidate()
        voice_timer.invalidate()
        standingTimer.invalidate()
        
        self.Jtimer.invalidate()
        self.resetTimer.invalidate()
        self.motionMan.stopAccelerometerUpdates()
        print("timers ok")
        
        self.activityManager.stopActivityUpdates()
        
        recorder.stop()
        print(successText[curr])
        let conclusion_speech = makeSpeechUtterance(successText[curr])
        
        needConcl = false

        synth.speakUtterance(conclusion_speech)

        
    }
    
    func createAudioRecorder() {
        do {
            let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            
            audioSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        //everything
                        
                        
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
                            try self.recorder = AVAudioRecorder(URL:url, settings: recordSettings)
                        }
                        catch {
                            
                        }
                        
                    } else {
                        print("CREATE AUDIO RECORDER EERRRRORORRR NOOO")
                    }
                }
            }
        }
        catch {
        }
        
    }
    
    func isVoice() {
        
        
        recorder.prepareToRecord()
        recorder.meteringEnabled = true
        
        recorder.record()
        voice_timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: Selector("voiceTimerCallback"), userInfo: nil, repeats: true)
    }
    
    func voiceTimerCallback() {
        recorder.updateMeters()
        if (recorder.averagePowerForChannel(0) > -10) {
            time_out_timer.invalidate()
            voice_timer.invalidate()
            _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("gameSucceeded"), userInfo: nil, repeats: false)
        }
    }
    
    var standingTimer = NSTimer()
    var timeStanding = 0.0
    var standing = false
    
    func isStationary() {
        timeStanding = 0.0
        standing = false
        print("IS IT WORKING?")
        standingTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("standingTime"), userInfo: nil, repeats: true)
        
        if(CMMotionActivityManager.isActivityAvailable()){
            print("WORKING")
            self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data: CMMotionActivity?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if(data!.stationary == true){
                        print("Stationary!")
                        self.standing = true
                    } else if (data!.walking == true){
                        print("Not Stationary")
                        self.standing = false
                    }
                })
                
            })
        }
    }
    
    func standingTime() {
        if standing {
            timeStanding += 0.01
        }
        else {
            if(timeStanding > 0){
                timeStanding -= 0.01
            }else{
                timeStanding = 0
            }
        }
        
        if timeStanding > 1.5 {
            gameSucceeded()
        }
    }
    
    
    let motionMan = CMMotionManager()
    var Jtimer = NSTimer()
    var resetTimer = NSTimer()
    
    var numSpikes : Int = 0
    var oldX : Double = 0
    var oldY : Double = 0
    var oldZ : Double = 0
    
    func checkForJump(){
        print("calling check for jump")
        
        if self.motionMan.accelerometerActive {
            self.motionMan.stopAccelerometerUpdates()
            return
        }
        
        self.motionMan.startAccelerometerUpdates()
        
        self.Jtimer = NSTimer.scheduledTimerWithTimeInterval(self.motionMan.accelerometerUpdateInterval, target: self, selector: Selector("pollAccel"), userInfo: nil, repeats: true)
        
        //reset count of spikes every 3 seconds
        self.resetTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("resetCount"), userInfo: nil, repeats: true)
        
        //self.doneWaiting = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: Selector("stopAccelometer"), userInfo: nil, repeats: true)
        
    }
    
    
    func resetCount(){
        self.numSpikes = 0
        
    }
    
    func pollAccel() {
        print("calling poll accell")
        guard let dat = self.motionMan.accelerometerData else {return}
        self.receiveAccel(dat)
    }
    
    func receiveAccel(dat:CMAccelerometerData){
        print("calling recieve accel")
        
        let spiked = didSpike(dat)
        if(spiked){
            self.numSpikes++
        }
        
        didJump()
    }
    
    func didJump() -> Bool{
        print("calling did jump")
        print(numSpikes)
        if(numSpikes > 5){
            resetTimer.invalidate()
            self.resetCount()
            self.Jtimer.invalidate()
            print("JUMPED")
            _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("gameSucceeded"), userInfo: nil, repeats: false)
            
            return true
            
        }else{
            return false
        }
        
    }
    
    func didSpike(dat:CMAccelerometerData) -> Bool{
        let x = dat.acceleration.x
        let y = dat.acceleration.y
        let z = dat.acceleration.z
        
        var dif  : [Double] = [0, 0, 0]
        dif[0] = oldX + abs(x)
        dif[1] = oldY + abs(y)
        dif[2] = oldZ + abs(z)
        
        print(dif[0] + dif[1] + dif[2])
        if(dif[0] + dif[1] + dif[2] > 5){
            //print("hype " + String(dif[0] + dif[1] + dif[2] ))
            return true
            //print(numSpikes)
        }
        
        return false
        
    }
    
    
    
    

    
}

