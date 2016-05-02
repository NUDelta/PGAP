//
//
//  pgagAudio
//
//  Created by Shawn Caeiro on 4/7/16.
//  Copyright © 2016 Jennie Werner. All rights reserved.
//

import UIKit
import CoreMotion
import Parse

class initController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    
    var userName : String!
    var nameText : String = ""
    
    let aD = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
         textField.resignFirstResponder()
        
        if nameField.text != nil {
                nameText = nameField.text!
                aD.userName = nameField.text!
                  print("CHANGED NAMETEXT")
          
        }
        
        return true
    }
    
    
    
    override func viewDidLoad() {
                super.viewDidLoad()
        self.nameField.delegate = self
        self.userName = ""
        isJumping()
        // Do any additional setup after loading the view.
        
    }
    
    func isJumping() {
        var motionManager: CMMotionManager!
        
        motionManager = CMMotionManager()
        //manager.accelerometerUpdateInterval = 0.01

        motionManager.startAccelerometerUpdates()
        while true{
            
            if let accelerometerData = motionManager.accelerometerData {
                let x = accelerometerData.acceleration.z
                let y = accelerometerData.acceleration.y
                let z = accelerometerData.acceleration.z
                
                let threshold = 0.6
                
                if(x > threshold || y > threshold || z > threshold){
                    print("woah")
                    print(x)
                    print(y)
                    print(z)
            
                }else{
                    print("chill")
                }
                
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}