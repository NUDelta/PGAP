//
//
//  pgagAudio
//
//  Created by Shawn Caeiro on 4/7/16.
//  Copyright © 2016 Jennie Werner. All rights reserved.
//

import UIKit
import Parse

class endController: UIViewController, UITextFieldDelegate {
    
    
    var name : String = ""
    
    @IBOutlet weak var goodWorkL: UILabel!
    
       override func viewDidLoad() {
        super.viewDidLoad()
        goodWorkL.text = "Good work" + name
        
        // Do any additional setup after loading the view.
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}