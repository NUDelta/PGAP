//
//  ViewController.swift
//  pgagAudio
//
//  Created by Shawn Caeiro on 4/7/16.
//  Copyright © 2016 Jennie Werner. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getObjects(loc: CLLocation) -> [String] {
        var objects:[String] = []
        var objects_nearby:[PFObject] = []
        
        let query = PFQuery(className: "OBJ_DB")
        let user_loc = PFGeoPoint(location:loc)
        query.whereKey("location", nearGeoPoint: user_loc, withinMiles: 0.01)
        do {
            try objects_nearby = query.findObjects()
            for obj in objects_nearby {
                let name = obj["name"] as! (String)
                if !objects.contains(name) {
                    objects.append(name)
                }
            }
        } catch {}
        return objects
    }
    
    func getAffordances(objects: [String]) -> [(affordance: String, obj: String)] {
        var affordance_objs:[(affordance: String, obj: String)] = []
        var affordance_names:[String] = []
        
        let query = PFQuery(className: "MAPPING_DB")
        query.whereKey("objectName", containedIn: objects)
        do {
            var obj_affordances:[PFObject] = []
            try obj_affordances = query.findObjects()
            // Not necessarily in order of closest affordances!!!!!!!!!
            for a in obj_affordances {
                if !(affordance_names.contains(a["affordance"] as! String)){
                    affordance_objs.append((affordance: a["affordance"] as! String, obj: a["name"] as! String))
                    affordance_names.append(a["affordance"] as! (String))
                }
            }
        } catch {}
        
        return affordance_objs
    }
    
    func getGames(affordances: [(affordance: String, obj: String)], var gamesPlayed: [String])
        -> (title: String, game: String, conclusion: String, duration: Int, obj: String)? {
            var affordance_names:[String] = []
            for a in affordances {
                affordance_names.append(a.affordance)
            }
            
            let query = PFQuery(className: "GAMES_DB")
            query.whereKey("affordance", containedIn: affordance_names)
            do {
                var games_possible:[PFObject] = []
                try games_possible = query.findObjects()
                // Not in order
                for g in games_possible {
                    let title = g["title"] as! String
                    if !gamesPlayed.contains(title){
                        gamesPlayed.append(title)
                        // TODO - How to use gamesPlayed... is it Global or do array references work as intended?
                        var obj = ""
                        for a in affordances {
                            if a.affordance == g["affordance"] as! String {
                                obj = a.obj
                            }
                        }
                        return (title, g["game"] as! String, g["conclusion"] as! String, g["duration"] as! Int, obj)
                    }
                }
            } catch {}
            return nil
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
