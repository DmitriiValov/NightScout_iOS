//
//  TodayViewController.swift
//  NightScoutWidget
//
//  Created by Dmitry Valov on 28.02.2018.
//  Copyright © 2018 Dmitry Valov. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var currenValue: UILabel!
    @IBOutlet weak var deltaValue: UILabel!
    @IBOutlet weak var timeValue: UILabel!
    @IBOutlet weak var batteryValue: UILabel!
    
    
    @IBAction func updateData(_ sender: UIButton) {
        self.timeLabel.text = "обновляется..."
        getInfo() { data in
            DispatchQueue.main.async {
                self.statusImage.image = self.getImageForDirection(direction: data.direction)
                self.currenValue.text = String(format: "%.1f",data.sgv)
                self.deltaValue.text = String(format: "%.1f",data.bgdelta)
                self.timeValue.text = String(format: "%d min ago",data.deltaTime)
                self.batteryValue.text = data.battery + "%"
                self.timeLabel.text = "обновлено: " + data.updatedTime
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeLabel.text = "обновляется..."
        getInfo() { data in
            DispatchQueue.main.async {
                self.statusImage.image = self.getImageForDirection(direction: data.direction)
                self.currenValue.text = String(format: "%.1f",data.sgv)
                self.deltaValue.text = String(format: "%.1f",data.bgdelta)
                self.timeValue.text = String(format: "%d min ago",data.deltaTime)
                self.batteryValue.text = data.battery + "%"
                self.timeLabel.text = "обновлено: " + data.updatedTime
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func getImageForDirection(direction: String) -> UIImage {
        var image:UIImage?
        switch direction {
        case "SingleDown":
            image = UIImage(named:"down")
        case "DoubleDown":
            image = UIImage(named:"down2")
        case "SingleUp":
            image = UIImage(named:"up")
        case "DoubleUp":
            image = UIImage(named:"down")
        case "FortyFiveDown":
            image = UIImage(named:"rightdown")
        case "FortyFiveUp":
            image = UIImage(named:"rightup")
        case "Flat":
            image = UIImage(named:"right")
        default:
            image = UIImage(named:"flat")
        }
        return image!
    }
    
    func getInfo(completion: @escaping (MyData) -> ()) {
        if let url = URL(string: "https://kost.azurewebsites.net/pebble/") {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                
                if let data1 = data, let jsonObj = (try? JSONSerialization.jsonObject(with: data1, options: JSONSerialization.ReadingOptions.allowFragments)) as? Dictionary<String, AnyObject>, error == nil {
                    let paramsList = jsonObj["bgs"] as? [[String: AnyObject]]
                    if let paramsList = paramsList {
                        if paramsList.count > 0 {
                            let item = paramsList[0]
                            var data:MyData = MyData()
                            data.direction = item["direction"]! as! String
                            data.datetime = Double(item["datetime"]! as! Int64) / 1000.0
                            data.battery = item["battery"]! as! String
                            data.bgdelta = Float(item["bgdelta"]! as! Int64) / 18.0
                            data.sgv = Float(item["sgv"]! as! String)! / 18.0
                            data.trend = item["trend"]! as! Int64

                            //Time since last data from device
                            let timeIntervalNow = NSDate().timeIntervalSince1970
                            data.deltaTime = Int((timeIntervalNow - Double(data.datetime)) / 60.0)
                            
                            //Time when data was updated
                            let currentDateTime = Date()
                            let formatter = DateFormatter()
                            formatter.timeStyle = .medium
                            formatter.dateStyle = .none
                            data.updatedTime = formatter.string(from: currentDateTime)
                            
                            //Date as String for last data
                            let dateAsDate = Date(timeIntervalSince1970: TimeInterval(data.datetime))
                            formatter.timeStyle = .medium
                            formatter.dateStyle = .medium
                            data.dateString = formatter.string(from: dateAsDate)
                            
                            completion(data)
                        }
                    }
                }
                else {
                    print("error=\(error!.localizedDescription)")
                }
            }
            task.resume()
        }
    }
}
