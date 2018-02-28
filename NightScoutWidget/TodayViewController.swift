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
        
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBAction func updateData(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeLabel.text = "обновляется..."
        
        getInfo() { data in
            DispatchQueue.main.async {
                print(data.sgv)

                let timeIntervalNow = NSDate().timeIntervalSince1970
                let deltaTime = (timeIntervalNow - Double(data.datetime)) / 60.0
                
                let date = Date(timeIntervalSince1970: TimeInterval(data.datetime))
                let formatter1 = DateFormatter()
                formatter1.timeStyle = .medium
                formatter1.dateStyle = .medium
                let test = formatter1.string(from: date)
                
                let currentDateTime = Date()
                let formatter = DateFormatter()
                formatter.timeStyle = .medium
                formatter.dateStyle = .none
                self.timeLabel.text = "обновлено: " + formatter.string(from: currentDateTime)
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
                            data.bgdelta = item["bgdelta"]! as! Int64
                            data.sgv = item["sgv"]! as! String
                            data.trend = item["trend"]! as! Int64
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
