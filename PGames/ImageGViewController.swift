//  ImageGViewController.swift
//  PGames
//
//  Created by Shawn Caeiro on 10/12/15.
//  Copyright © 2015 Shawn Caeiro. All rights reserved.
//

import UIKit
import Parse

class ImageGViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBAction func takePhoto(sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBOutlet weak var gameText: UILabel!
    @IBOutlet weak var imageV: UIImageView!
    var imagePicker: UIImagePickerController!
    var image: UIImage?
    var timeLeft:Int?
    var mainController:ViewController?
    var actionCount = 0
    var game: Int?
    var g: PFObject?
    var tasks: [PFObject]?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        g = tasks![game!]
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        imageV.addGestureRecognizer(tapGestureRecognizer)
        imageV.userInteractionEnabled = false
    }
    
    func imageTapped(img: UITapGestureRecognizer)
    {
        if (actionCount < 10) {
            var location = img.locationInView(nil) as CGPoint
            var DynamicView=UIImageView(frame: CGRectMake(100, 200, 50, 100))
            
            //DynamicView.backgroundColor=UIColor.greenColor()
            //DynamicView.layer.cornerRadius=25
            //DynamicView.layer.borderWidth=2
            DynamicView.image = UIImage(named: "carrot")
            DynamicView.center = location
            self.view.addSubview(DynamicView)
            actionCount++
        }
        else {
            imageV.userInteractionEnabled = false
            //let _ : NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("leaveCode"), userInfo: nil, repeats: false)
            performSelector("leaveCode", withObject: nil, afterDelay: 1)
        }
    }
    
    func leaveCode() {
        end()
    }
    
    func end() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let svc : ResultsViewController = mainStoryboard.instantiateViewControllerWithIdentifier("results") as! ResultsViewController
        svc.modalTransitionStyle = .CrossDissolve
        svc.game = self.game
        svc.g = g
        svc.tasks = tasks
        presentViewController(svc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func doAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageV.image = image
        imageV.userInteractionEnabled = true
        gameText.text = "Great! Now share the wealth and feed those people carrots! Tap Away!"
    }

}