//
//  ViewController.swift
//  pgagAudio
//
//  Created by Jennie Werner on 1/31/16.
//  Copyright © 2016 Jennie Werner. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var thePlayer : AVAudioPlayer!
    
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        //1
       
        if (NSBundle.mainBundle().pathForResource(file as String, ofType: type as String) != nil){
        }else{
            print("no file \(file) found")
        }
        
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        //2
        var audioPlayer:AVAudioPlayer!
        
        // 3
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    

    @IBAction func stopMusic() {
        
        if(thePlayer != nil){
            thePlayer.stop()
            thePlayer = nil
        }
        
    }


    func makePlay(fileName:String){
        if let helloPlayer = self.setupAudioPlayerWithFile(fileName, type: "mp3"){
            self.thePlayer = helloPlayer
        }else{
            print("error in makePlay when called with \(fileName)")
        }
        thePlayer?.play()
        
    }
    
    @IBAction func playAudio(sender: UIButton) {
        
        if(sender.currentTitle! == "Play Hello"){
            makePlay("01. Hello")
        }
        
        if(sender.currentTitle! == "Play River Lea"){
            makePlay("07. River Lea")

        }
        
    }
}

