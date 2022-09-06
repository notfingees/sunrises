//
//  NotificationService.swift
//  AuroraNotificationService
//
//  Created by justin on 2/21/21.
//

import UserNotifications
import UIKit
import CoreData
import CryptoKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        print("in NotificationService.swift at all")
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            if let today_notification = bestAttemptContent.userInfo["today_notification"] as? String {
            bestAttemptContent.title = "\(bestAttemptContent.title)" + today_notification
            
            
        }
        contentHandler(bestAttemptContent)
    }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func get_user_id() -> Int {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return 0
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        var user: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            user = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        let user_id = (user[0].value(forKey: "user_id") as AnyObject).doubleValue
        let int_user_id = Int(user_id!)
    
        return int_user_id
    }
    
    
    func get_user_today_notification(){
        let user_id = self.get_user_id()
        let url5 = NSURL(string: "https://www.sunrisesapp.com/get_user_today_notification.php")
        var request5 = URLRequest(url: url5! as URL)
        request5.httpMethod = "POST"
        let dataString5 = "user_id=" + String(user_id)

        let dataD5 = dataString5.data(using: .utf8)
        do {
            let uploadJob = URLSession.shared.uploadTask(with: request5, from: dataD5){
                data, response, error in
                if error != nil {
                    print(error)
                }
                else {
                    var jsonResult = NSArray()
                    do{
                   //     jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                        
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                
                            } catch let error as NSError {
                                print(error)
                                
                            }
                    print(jsonResult.count)
                    var jsonElement = NSDictionary()
                   // let persons = NSMutableArray()
                    //var lft_array: [String] = []
                   // print(jsonResult)

                    for i in 0 ..< jsonResult.count{
                        jsonElement = jsonResult[i] as! NSDictionary

                        if let interest_id = (jsonElement["today_notification"] as AnyObject).doubleValue{
                           // print("in the viewdiappear part of saving \(interest_id) for user")
                            DispatchQueue.main.async{
                          //      self.save_user_interest(user_id: Double(user_id), interest_id: interest_id)
                          //      self.save_user_recommended(interest_id: interest_id)
                            }
                        
                        }
                        
                        //print(type(of: jsonElement["updated"]))
                     //   let updated = jsonElement["updated"]!
                     //   if (updated as AnyObject).doubleValue == 1{
                      //      print("so true")
                      //  }

                    }
                }
            }
           
                uploadJob.resume()
            
        }
    }

}
