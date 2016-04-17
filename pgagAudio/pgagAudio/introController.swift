

import UIKit
import Parse
import AVFoundation


class introController: UIViewController, UITextFieldDelegate, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    
    var userName : String = ""
    let synth  = AVSpeechSynthesizer()
    var player = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(userName)
        self.synth.delegate = self

        // Do any additional setup after loading the view.
        
    }
    
    var VC : ViewController  = ViewController()
   
    @IBAction func breifing() {
        print("hi")
        
        
        let intro : [PFObject]
        let query = PFQuery(className: VC.STATEMENTS_DB)
        
        query.whereKey("name", equalTo: "intro")
        do{
            try intro = query.findObjects()
            var introText = intro[0]["text"] as! String
            introText.replaceRange(introText.rangeOfString("***")!, with: userName )
            let utt = VC.makeSpeechUtterance(introText)
            synth.speakUtterance(utt)
            
        }catch{}
        
        
        /*
        while synth.speaking{
            
        }
        
        player = VC.makeAudioPlayer("theme", type: "mp3")
        player.play()*/

    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        
            player = VC.makeAudioPlayer("theme", type: "mp3")
            player.prepareToPlay()
            //player.delegate = self
            player.play()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}