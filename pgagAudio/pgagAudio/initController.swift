//
//
//  pgagAudio
//
//  Created by Shawn Caeiro on 4/7/16.
//  Copyright © 2016 Jennie Werner. All rights reserved.
//

import UIKit
import Parse
class initController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    
    var userName : String!
    var nameText : String = ""
    
    let aD = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "beginMission"){
//            
//        }
//    }
    
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
        // Do any additional setup after loading the view.        
        
        getWeather("Evanston")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "584a4f2cedd66fd2376b0a8f124e8fdb"
  

        func getWeather(city: String) {
            
            // This is a pretty simple networking task, so the shared session will do.
            let session = NSURLSession.sharedSession()
            
            let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
            
            // The data task retrieves the data.
            let dataTask = session.dataTaskWithURL(weatherRequestURL) {
                (data: NSData?, response: NSURLResponse?, error: NSError?) in
                if let error = error {
                    // Case 1: Error
                    // We got some kind of error while trying to get data from the server.
                    print("Error:\n\(error)")
                }
                else {
                    // Case 2: Success
                    // We got a response from the server!
                    do {
                        // Try to convert that data into a Swift dictionary
                        let weather = try NSJSONSerialization.JSONObjectWithData(
                            data!,
                            options: .MutableContainers) as! [String: AnyObject]
                        
                        // If we made it to this point, we've successfully converted the
                        // JSON-formatted weather data into a Swift dictionary.
                        // Let's print its contents to the debug console.
                        
                        print("Weather main: \(weather["weather"]![0]!["main"]!!)")
                        print("Weather description: \(weather["weather"]![0]!["description"]!!)")
                      
                    }
                    catch let jsonError as NSError {
                        // An error occurred while trying to convert the data into a Swift dictionary.
                        print("JSON error description: \(jsonError.description)")
                    }
                }
            }
            
            // The data task is set up...launch it!
            dataTask.resume()
        }
    
    
    
}