//
//  ImageViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/12/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse

class ImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var gameText: UILabel!
    
    @IBOutlet weak var imageV: UIImageView!
    var imagePicker: UIImagePickerController!
    var image: UIImage?
    var timeLeft:Int?
    var mainController:ViewController?
    var actionCount = 0
    var tasks: [PFObject] = []
    var game: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countDownLabel.text = String(timeLeft!--)
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        imageV.addGestureRecognizer(tapGestureRecognizer)
        imageV.userInteractionEnabled = true
        
        gameText.text = game!["description"] as? String
    }
    
    func imageTapped(img: UITapGestureRecognizer)
    {
        if (actionCount < 10) {
            var location = img.locationInView(nil) as CGPoint
            var DynamicView=UIImageView(frame: CGRectMake(100, 200, 50, 100))
            
            //DynamicView.backgroundColor=UIColor.greenColor()
            //DynamicView.layer.cornerRadius=25
            //DynamicView.layer.borderWidth=2
            DynamicView.image = UIImage(named: game!["imgName"] as! String)
            DynamicView.center = location
            self.view.addSubview(DynamicView)
            actionCount++
        }
        else {
            gameText.text = "THANKS!!!!"
            let _ : NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("leaveCode"), userInfo: nil, repeats: false)
        }
    }
    
    func leaveCode() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func doAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageV.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        gameText.text = game!["actionVerb"] as? String
    }
    
    func update() {
        if(timeLeft >= 0)
        {
            countDownLabel.text = String(timeLeft!--)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func takePhoto(sender: UIButton) {
    imagePicker =  UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = .Camera
    presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
    image = info[UIImagePickerControllerOriginalImage] as? UIImage
    print("Image Test")
    print(info[UIImagePickerControllerOriginalImage])
    if image != nil {
    print("Image is NILLLL")
    }
    
    
    }
    
    
    
    */

}
