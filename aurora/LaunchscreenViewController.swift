//
//  LaunchscreenViewController.swift
//  aurora
//
//  Created by justin on 2/9/21.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import CoreData
import CryptoKit


var userLoggedInVCS = false

class LaunchscreenViewController: UIViewController {
    @IBOutlet weak var logo: UIImageView!
    
    var howManyInterestsDone = 0
    var howManyInterestsTotal = 0
    
    var launchscreenDoneNotificationReceivedObserver: NSObjectProtocol?
    
    var loggedInLaunchscreenDoneNotificationReceivedObserver: NSObjectProtocol?
    
    var downloadNewReceivedObserver: NSObjectProtocol?
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    public func clearAllCoreData() {
        print("in clearAllCoreData in LaunchscreenVC, getting called once")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entities = appDelegate.persistentContainer.managedObjectModel.entities
        
      //  persistentContainer.managedObjectModel.entities
        entities.flatMap({ $0.name }).forEach(clearDeepObjectEntity)
    }

    private func clearDeepObjectEntity(_ entity: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let context = appDelegate.persistentContainer.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    

    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        print("in LaunchscreenViewController viewWillAppear")
        
        downloadNewReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.downloadNewReceived, object: nil, queue: nil, using: {(notification) in
            
            var largest_interest_id = 0
            var largest_lft_id = 0
            
            print("in notification of downloadNewReceivedObserver")
            let user_id = self.get_user_id()
            let user_hash = self.get_user_hash()
            
            let group = DispatchGroup()
            group.enter()
            let urlPath2 = "https://www.sunrisesapp.com/download_all_lft.php?user_id=" + String(user_id)
            let url2 = URL(string: urlPath2)!
            let defaultSession2 = Foundation.URLSession(configuration: URLSessionConfiguration.default)
            let task2 = defaultSession2.dataTask(with: url2){ (data, response, error) in
                if error != nil {
                    print("Failed to download data")
                } else {
                    
                    var jsonResult = NSArray()
                    do{
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                
                            } catch let error as NSError {
                                print(error)
                                
                            }
                    
                

                            DispatchQueue.main.async{
                                self.big_save_lft(jsonResult: jsonResult)
                            }
                            
                        
                    
                    group.leave()
                    
                    }

                    print("Data downloaded")
                
                
                
                

                }
                
            task2.resume()
            group.wait()
               
            // DOWNLOADING ALL NEW INTERESTS
               group.enter()
           let urlPath = "https://www.sunrisesapp.com/download_new_interests.php?user_id=" + String(user_id) // would have to change this to like "download all new interests"
           let url = URL(string: urlPath)!
           let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
           let task = defaultSession.dataTask(with: url){ (data, response, error) in
               if error != nil {
                   print("Failed to download data")
               } else {
                   
                   var jsonResult = NSArray()
                   do{
                       jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                               
                           } catch let error as NSError {
                               print(error)
                               
                           }
                   
                           DispatchQueue.main.async{
                               self.big_save_interest(jsonResult: jsonResult)
                           }
                           
                       
                   
                   group.leave()
                   
                   }
               }
           task.resume()
            
       /*
            group.wait()
               group.enter()
               print("4")
           let url4 = NSURL(string: "https://www.sunrisesapp.com/user_uptodate.php")
           var request4 = URLRequest(url: url4! as URL)
           request4.httpMethod = "POST"
            
            let dataString2 = "user_id=" + String(user_id) + "&largest_interest_id=" + String(largest_interest_id) + "&largest_lft_id=" + String(largest_lft_id)
            print("in user up to date (user not logged in, dataString2 is", dataString2)
           
           let dataD2 = dataString2.data(using: .utf8)
           do {
               let uploadJob2 = URLSession.shared.uploadTask(with: request4, from: dataD2){
                   data, response, error in
                   if error != nil {
                    print(error as Any)
                   }
                   else {
                       print("no error!")
                   }
               }
               
                   uploadJob2.resume()
               group.leave()
               }
            print("wait 1")
 */
            
        })
        
        loggedInLaunchscreenDoneNotificationReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.loggedInLaunchscreenDoneNotificationReceived, object: nil, queue: nil, using: {(notification) in
            
            print("in notification of loggedInLaunchscreenDoneNotificationReceived")
            /*
            sleep(1)
            DispatchQueue.main.async{
                self.initLftIndex()
  
                self.updateCurrentUpdatedDate()
   
                self.generate_lfts()
                print("about to redirect to view controller")
                print("current selected index is \(self.tabBarController!.selectedIndex)")
                self.tabBarController!.selectedIndex = 0
            }
 */
        })
        
        launchscreenDoneNotificationReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.launchscreenDoneNotificationReceived, object: nil, queue: nil, using: { (notification) in
            print("in notification thing of launchscreen, howmanyinterests done is \(self.howManyInterestsDone), total interests is \(self.howManyInterestsTotal)")
            if self.howManyInterestsDone == self.howManyInterestsTotal{
                sleep(1)
                print("after sleep 1 in viewwillappear launchscreen notification stuff")
                DispatchQueue.main.async { // because the notification won't be received on the main queue and you want to update the UI which must be done on the main queue.
                    print("launchscreen done notification received!")
                    self.initLftIndex()
      
                    self.updateCurrentUpdatedDate()
       
                    // Commented out july 12
                    self.generate_lfts()
                    
            //        var cvc = UIApplication.shared.windows[0].rootViewController?.children as! [ViewController]
            //        print("about to print children in launchscreen")
            //        print(cvc)
                    
                    NotificationCenter.default.post(name: Notification.Name.switchToTabBarOneReceived, object: nil)
                    //self.redirect_tabbarcontroller()
                    /*
                    print("about to redirect to view controller")
                    print("current selected index is \(self.tabBarController!.selectedIndex)")

                    self.tabBarController!.selectedIndex = 0
 */
                }
            }
            else{
                
            }
            
                    
                })
    }
    
    
    override func viewDidAppear(_ animated: Bool){
     super.viewDidAppear(animated)
       
        print("at the top of viewDidAppear in LaunchscreenViewController\n")
        
        /*
        do {
                    try Auth.auth().signOut()
                }
             catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
 */
 
        
        
        
        if Auth.auth().currentUser != nil {
            
            var user_interest_ids: [Double] = []
            
            let group = DispatchGroup()
            DispatchQueue.main.async{
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                    return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                //managedContext.deleteAllData()
                //print("calling clearAllCoreData when user is logged in")
                //self.clearAllCoreData()
                // .clearAllCoreData() is the one that work
                
                //self.createTestUserAndDeleteOld()
                
                
              //  self.initLftIndex()
              //  self.initTestUser()
              //  self.delete_past_lfts()
            }
            
           print("user is already logged in")
           
           userLoggedInVCS = true
           
         //  var user_lft_ids: [Int] = []
           
           
            let user_id = self.get_user_id()
            let user_hash = self.get_user_hash()
            print("user_id is \(user_id)")

           // CHECKING IF NEEDS UPDATE OR NOT for current_lft and current_interest index
            
            group.enter()
            var current_lft_index = 0
            var current_interest_index = 0
            let _urlpath = "https://www.sunrisesapp.com/get_current_lft_and_interest_index.php"
            let _url = URL(string: _urlpath)!
            let _defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
            let _task = _defaultSession.dataTask(with: _url){ (data, response, error) in
                if error != nil {
                    print("Failed to download data")
                } else {
                    
                    var jsonResult = NSArray()
                    do{
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                
                            } catch let error as NSError {
                                print(error)
                                
                            }
                    
                    var jsonElement = NSDictionary()

                    for i in 0 ..< jsonResult.count{
      
                        jsonElement = jsonResult[i] as! NSDictionary
                       // print(jsonElement)
                    //    let interest_id = (jsonElement["interest_id"] as AnyObject).doubleValue
                    //       let lft_id = (jsonElement["lft_id"] as AnyObject).doubleValue
                        let cli = (jsonElement["current_lft_index"] as AnyObject).doubleValue
                        let cii = (jsonElement["current_interest_index"] as AnyObject).doubleValue
                        current_lft_index = Int(cli!)
                        current_interest_index = Int(cii!)
                    
                            
                        
                    }
                    group.leave()
                    
                    }

                
                
                
                

                }
                
            _task.resume()
            
            
            group.wait()
           group.enter()
           var user_is_updated = false
           let url0 = NSURL(string: "https://www.sunrisesapp.com/is_user_uptodate.php")
           var request = URLRequest(url: url0! as URL)
           request.httpMethod = "POST"
           let dataString = "user_id=" + String(user_id) + "&user_hash=" + user_hash

           let dataD = dataString.data(using: .utf8)
           do {
               let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD){
                   data, response, error in
                   if error != nil {
                    print(error as Any)
                   }
                   else {
                       var jsonResult = NSArray()
                       do{
                 
                           jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                   
                               } catch let error as NSError {
                                   print(error)
                                   
                               }
                       print(jsonResult.count)
                       var jsonElement = NSDictionary()

                       for i in 0 ..< jsonResult.count{

                           jsonElement = jsonResult[i] as! NSDictionary

                           let updated_interests = jsonElement["updated_interests"] as! String
                           let updated_lft = jsonElement["updated_lft"] as! String
                           //print(updated)
                        if (Int(updated_interests)! >= current_interest_index && Int(updated_lft)! >= current_lft_index){
                               user_is_updated = true

                           }
                           else {
                           }
                           
                           group.leave()
                       }
                   }
               }
                   uploadJob.resume()
           }
           
           group.wait()
           // MARK: - CHANGE!!
            
            var largest_interest_id = 0
            var largest_lft_id = 0
        //   if(user_is_updated == false || user_is_updated == true){
            if(user_is_updated == false){
               
           
           // DOWNLOADING ALL NEW LFTs
            group.enter()
            let urlPath2 = "https://www.sunrisesapp.com/download_all_lft.php?user_id=" + String(user_id)
            let url2 = URL(string: urlPath2)!
            let defaultSession2 = Foundation.URLSession(configuration: URLSessionConfiguration.default)
            let task2 = defaultSession2.dataTask(with: url2){ (data, response, error) in
                if error != nil {
                    print("Failed to download data")
                } else {
                    
                    var jsonResult = NSArray()
                    do{
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                
                            } catch let error as NSError {
                                print(error)
                                
                            }
                        

                            DispatchQueue.main.async{
                                self.big_save_lft(jsonResult: jsonResult)
                            }
                            
                        
                    
                    group.leave()
                    
                    }

                    print("Data downloaded")
                
                
                
                

                }
                
            task2.resume()
            group.wait()
               
            // DOWNLOADING ALL NEW INTERESTS
               group.enter()
           let urlPath = "https://www.sunrisesapp.com/download_new_interests.php?user_id=" + String(user_id) // would have to change this to like "download all new interests"
           let url = URL(string: urlPath)!
           let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
           let task = defaultSession.dataTask(with: url){ (data, response, error) in
               if error != nil {
                   print("Failed to download data")
               } else {
                   
                   var jsonResult = NSArray()
                   do{
                       jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                               
                           } catch let error as NSError {
                               print(error)
                               
                           }
                   
                   var jsonElement = NSDictionary()
                  // let persons = NSMutableArray()
                   //var lft_array: [String] = []
                   
                
                        DispatchQueue.main.async{
                            self.big_save_interest(jsonResult: jsonResult)
                        }
                           
                       
                   
                   group.leave()
                   
                   }
               }
           task.resume()
            
            group.wait()
            group.enter()

            let url5 = NSURL(string: "https://www.sunrisesapp.com/download_user_interests.php")
            var request5 = URLRequest(url: url5! as URL)
            request5.httpMethod = "POST"
            let dataString5 = "user_id=" + String(user_id)

            let dataD5 = dataString5.data(using: .utf8)
            var interests_done = 0
            
            do {
                let uploadJob = URLSession.shared.uploadTask(with: request5, from: dataD5){
                    data, response, error in
                    if error != nil {
                        print(error as Any)
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
                        
                        var interests_done_flag = false
                        
                        var jsonElement = NSDictionary()
                       // let persons = NSMutableArray()
                        //var lft_array: [String] = []
                       // print(jsonResult)
                        self.howManyInterestsTotal = jsonResult.count
                        for i in 0 ..< jsonResult.count{
                            print("interests_done is \(interests_done), jsonResult.count is \(jsonResult.count)")
                            if interests_done + 1 == jsonResult.count{
                                print("setting interests_done_flag to true")
                                interests_done_flag = true
                            }
                            else{

                            }
                            
                            
                            jsonElement = jsonResult[i] as! NSDictionary

                            if let interest_id = (jsonElement["interest_id"] as AnyObject).doubleValue{
                               // print("in the viewdiappear part of saving \(interest_id) for user")
                              //  DispatchQueue.main.async{
                                    self.save_user_interest(user_id: Double(user_id), interest_id: interest_id)
                                user_interest_ids.append(interest_id)
                                /*
                                DispatchQueue.main.async{
                                self.save_user_recommended_launchscreen(interest_id: interest_id, completionHandler: { (success) -> Void in
                                    
                                    if (success){
                                        print("successfully saved user_recommended_interest \(interest_id)")
                                        if interests_done_flag{
                                            /*
                                       //     DispatchQueue.main.async{
                                                self.initLftIndex()
                                       //     }
                                        //    DispatchQueue.main.async{
                                                self.delete_past_lfts()
                                        //    }
                                        //    DispatchQueue.main.async{
                                                self.generate_lfts()
 */
                                            
                                            print("posting launchscreen done notificatino received notification")
                                            NotificationCenter.default.post(name: Notification.Name.launchscreenDoneNotificationReceived, object: nil)
                                            }
                                       // }
                                        else{
                                            print("in this else statement incrementing interests_done once")
                                            interests_done = interests_done + 1
                                            print("interests_done in the else statement is now \(interests_done)")
                                        }
                                        /*
                                        DispatchQueue.main.async{
                                            self.initLftIndex()
                                        }
                                        DispatchQueue.main.async{
                                            self.delete_past_lfts()
                                        }
                                        DispatchQueue.main.async{
                                            self.generate_lfts()
                                        }
 */
                                            
                                        
                                        
                                    }
                                    else{
                                        print("Save user recommended in launchscreen failed")
                                    }
                                    
                                })
                                }
                                */
                              //  }
                            
                            }
   

                        }
                        group.leave()
                    }
                }
               
                    uploadJob.resume()
                
            }
           
           // DOWNLOADING ALL THINGS TO LOOK FORWARD TO
           
           
           

           // Set user to updated so we don't download the data again
               group.wait()
            
            group.enter()
            for iid in user_interest_ids{
                DispatchQueue.main.async{
                    self.save_user_recommended(interest_id: iid)
                }
            }
            group.leave()
                
                /*
            group.wait()
               group.enter()
               print("4")
           let url4 = NSURL(string: "https://www.sunrisesapp.com/user_uptodate.php")
           var request4 = URLRequest(url: url4! as URL)
           request4.httpMethod = "POST"
            
            let dataString2 = "user_id=" + String(user_id) + "&largest_interest_id=" + String(largest_interest_id) + "&largest_lft_id=" + String(largest_lft_id)
            print("in user up to date (user not logged in, dataString2 is", dataString2)
           
           let dataD2 = dataString2.data(using: .utf8)
           do {
               let uploadJob2 = URLSession.shared.uploadTask(with: request4, from: dataD2){
                   data, response, error in
                   if error != nil {
                    print(error as Any)
                   }
                   else {
                       print("no error!")
                   }
               }
               
                   uploadJob2.resume()
               group.leave()
               }
            print("wait 1")
                */
                
                /* commented out on july 28 
                DispatchQueue.main.async{
                    self.initLftIndex()
      
                    self.updateCurrentUpdatedDate()
       
                    self.generate_lfts()
                    print("about to redirect to view controller")
                    print("current selected index is \(self.tabBarController!.selectedIndex)")
                    self.tabBarController!.selectedIndex = 0
                }
                
 */
                
               // NotificationCenter.default.post(name: Notification.Name.loggedInLaunchscreenDoneNotificationReceived, object: nil)
           
            
            
            
           
         
            
            // END OF IF USER NOT UP TO DATE
           }
            else{
                //NotificationCenter.default.post(name: Notification.Name.loggedInLaunchscreenDoneNotificationReceived, object: nil)
                DispatchQueue.main.async{
                    self.initLftIndex()
      
                    self.updateCurrentUpdatedDate()
       
                    self.generate_lfts()
                    print("about to redirect to view controller")
                    print("current selected index is \(self.tabBarController!.selectedIndex)")
                    self.tabBarController!.selectedIndex = 0
                }
            }
     
      //      print("about to redirect to view controller")
      //      print("current selected index is \(self.tabBarController!.selectedIndex)")

     //       self.tabBarController!.selectedIndex = 0
      
            
    
       }
        //MARK: - ELSE
        else {
            
            
            
            
            DispatchQueue.main.async{
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                    return
                }
                //let managedContext = appDelegate.persistentContainer.viewContext
                //    managedContext.deleteAllData()
                //print("clearing all core data when user is not logged in")
                //self.clearAllCoreData()
                self.initLftIndex()
                self.updateCurrentUpdatedDate()

            }

            
            
          
            
           // deletes everything from coredata
            
     

            //MARK: - USER ID NEEDS TO BE GOTTEN FROM OBJECT IN ACTUAL IMPLEMENTATION

            let user_id = 2

            // CHECKING IF NEEDS UPDATE OR NOT
            let group = DispatchGroup()
            
            group.enter()
            var current_lft_index = 0
            var current_interest_index = 0
            let _urlpath = "https://www.sunrisesapp.com/get_current_lft_and_interest_index.php"
            let _url = URL(string: _urlpath)!
            let _defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
            let _task = _defaultSession.dataTask(with: _url){ (data, response, error) in
                if error != nil {
                    print("Failed to download data")
                } else {
                    
                    var jsonResult = NSArray()
                    do{
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                
                            } catch let error as NSError {
                                print(error)
                                
                            }
                    
                    var jsonElement = NSDictionary()

                    for i in 0 ..< jsonResult.count{
      
                        jsonElement = jsonResult[i] as! NSDictionary
                       // print(jsonElement)
                    //    let interest_id = (jsonElement["interest_id"] as AnyObject).doubleValue
                    //       let lft_id = (jsonElement["lft_id"] as AnyObject).doubleValue
                        let cli = (jsonElement["current_lft_index"] as AnyObject).doubleValue
                        let cii = (jsonElement["current_interest_index"] as AnyObject).doubleValue
                        current_lft_index = Int(cli!)
                        current_interest_index = Int(cii!)
                    
                            
                        
                    }
                    group.leave()
                    
                    }

                
                
                
                

                }
                
            _task.resume()
            
            
            group.wait()
            
            
            group.enter()
            let urlPath = "https://www.sunrisesapp.com/download_new_interests.php?user_id=" + String(user_id) // would have to change this to like "download all new interests"
            let url = URL(string: urlPath)!
            let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
            let task = defaultSession.dataTask(with: url){ (data, response, error) in
                if error != nil {
                    print("Failed to download data")
                } else {
                    
                    var jsonResult = NSArray()
                    do{
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                
                            } catch let error as NSError {
                                print(error)
                                
                            }
                    
                    print("done downloading and serializing INTERESTS data!")
                    
                    
                    DispatchQueue.main.async{
                        self.big_save_interest(jsonResult: jsonResult)
                    }
                    /*
                    var jsonElement = NSDictionary()
                   // let persons = NSMutableArray()
                    //var lft_array: [String] = []
                    
                    for i in 0 ..< jsonResult.count{
                        jsonElement = jsonResult[i] as! NSDictionary
                    //    print("downloading Interest (not logged in)")
                     //   print(jsonElement)
                        if let interest_id = (jsonElement["interest_id"] as AnyObject).doubleValue,
                           let name = jsonElement["name"] as? String,
                           let desc = jsonElement["description"] as? String,
                           let category = jsonElement["category"] as? String,
                           //let image = jsonElement["image"] as? String,
                           let trending = jsonElement["trending"] as? String {
                                let items = [interest_id, name, desc, category, trending] as [Any]
                            DispatchQueue.main.async{
                                self.save_interest(items: items)
                            }
                            
                        }
                        else{
                            print("didn't fucking work???")
                        }
                    }
 */
                    group.leave()
                    
                    }

                //    print("Data downloaded")

                }
                
            task.resume()
                
                
            

           
            
            // DOWNLOADING ALL THINGS TO LOOK FORWARD TO
                group.wait()
                group.enter()
                print("2")
            let urlPath2 = "https://www.sunrisesapp.com/download_all_lft.php?user_id=" + String(user_id)
            let url2 = URL(string: urlPath2)!
            let defaultSession2 = Foundation.URLSession(configuration: URLSessionConfiguration.default)
            let task2 = defaultSession2.dataTask(with: url2){ (data, response, error) in
                if error != nil {
                    print("Failed to download data")
                } else {
                    
                    var jsonResult = NSArray()
                    do{
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                
                            } catch let error as NSError {
                                print(error)
                                
                            }
                    
                    print("done downloading and serializing LFT data!")
                    
                    DispatchQueue.main.async{
                        self.big_save_lft(jsonResult: jsonResult);
                    }
                    
                    /*
                    
                    var jsonElement = NSDictionary()
            
                   // var todayIndex = 0
                  //  var tomorrowIndex = 0
                    for i in 0 ..< jsonResult.count{
      
                        jsonElement = jsonResult[i] as! NSDictionary
                   //     print(jsonElement)
               
                        let interest_id = (jsonElement["interest_id"] as AnyObject).doubleValue
                        let lft_id = (jsonElement["lft_id"] as AnyObject).doubleValue
                           let desc = jsonElement["description"] as! String
                           let category = jsonElement["category"] as! String
                        let interest_name = jsonElement["interest_name"] as! String
                        let importance = (jsonElement["importance"] as AnyObject).doubleValue
                           let date = jsonElement["date"] as! String
                        let items = [interest_id!, lft_id!, desc, category, importance!, date, interest_name] as [Any]
                        

                            DispatchQueue.main.async{
                                self.save_lft(items: items)
                            }
                            
                        
                    }
 
 */
                    group.leave()
                    
                    }

                    print("Data downloaded")
                
                
                
               

                }
                
            task2.resume()
            
            group.wait()
            /*
            group.enter()
            print("4")
        let url4 = NSURL(string: "https://www.sunrisesapp.com/user_uptodate.php")
        var request4 = URLRequest(url: url4! as URL)
        request4.httpMethod = "POST"
         
         let dataString2 = "user_id=" + String(user_id) + "&largest_interest_id=" + String(0) + "&largest_lft_id=" + String(0)
         print("in user up to date (user not logged in, dataString2 is", dataString2)
        
        let dataD2 = dataString2.data(using: .utf8)
        do {
            let uploadJob2 = URLSession.shared.uploadTask(with: request4, from: dataD2){
                data, response, error in
                if error != nil {
                 print(error as Any)
                }
                else {
                    print("no error!")
                }
            }
            
                uploadJob2.resume()
            group.leave()
            }
         print("wait 1")
            */
            
                // already existed
            
            print("redirecting to OnboardingViewController, tabBarController is \(self.tabBarController!.viewControllers)")
           self.tabBarController!.selectedIndex = 3

           
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController!.tabBar.isHidden = true
        
        print("in view did load of LaunchscreenViewController")
        
        /*
        do {
                    try Auth.auth().signOut()
                }
             catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
 */
     
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool){
        print("in viewWillDisappear")
       // self.dismiss(animated: false, completion: nil)
       // logo.isHidden = true
       

    
        
    }
    
    func save_user_recommended(interest_id: Double){
            //print("at the top of save_user_recommended")
         
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
           //     print("in save_user_recommended of launchscreen, saving interest_id \(interest_id)")
            // 1: Getting hands on NSManagedObjectContext
            let managedContext = appDelegate.persistentContainer.viewContext
            let url3 = NSURL(string: "https://www.sunrisesapp.com/get_recommended_interests.php")
            var request = URLRequest(url: url3! as URL)
            request.httpMethod = "POST"
            let string_selected_interest_id = String(interest_id)
            let dataString = "interest_id=" + string_selected_interest_id
            //print("dataString is \(dataString)")
            let dataD = dataString.data(using: .utf8)
            do {
                let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD){
                    data, response, error in
                    if error != nil {
                        print(error as Any)
                    }
                    else {
                        var jsonResult = NSArray()
                        do{
                            jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                    
                                } catch let error as NSError {
                                    print(error)
                                    // try notifiations
                                }
                        
                        var jsonElement = NSDictionary()
                       // let persons = NSMutableArray()
                        //var lft_array: [String] = []
                        
                        //print(jsonResult)
                        for i in 0 ..< jsonResult.count{

                            jsonElement = jsonResult[i] as! NSDictionary
                         //   print("the recommended interest id is")
                         //   print(jsonElement["recommended_interest_id"])
                            
                            if let recommended_interest_id = (jsonElement["recommended_interest_id"] as AnyObject).doubleValue
                               {
                                
                                
                                // 2: Creating new managed object and inserting into managed object contextt]
                            
                                
                                var indexes_temp: [NSManagedObject] = []
                                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
                                fetchRequest.predicate = NSPredicate(format: "id == %d", (recommended_interest_id as NSNumber).intValue)
                                do {
                                    indexes_temp = try managedContext.fetch(fetchRequest)
                             
                                } catch let error as NSError {
                                    print("Could not fetch. \(error), \(error.userInfo)")
                                }
                                
                            //    print("setting \(indexes_temp[0]) to recommended = true")
                                if indexes_temp.count > 0{
                                    indexes_temp[0].setValue(true, forKeyPath: "recommended")
                                }
                                

                                do {
                                    try managedContext.save()
                                } catch let error as NSError {
                                    print("Could not save. \(error), \(error.userInfo)")
                                }
                                
                            }
                            
                        }
                        
                        print("howmanyinterestsdone is \(self.howManyInterestsDone)")
                        self.howManyInterestsDone = self.howManyInterestsDone + 1
                        if self.howManyInterestsDone + 1 == self.howManyInterestsTotal{
                            
                        }
                        else{
                            print("pOSTING launchscreenDoneNotificationReceived notification ONCE")
                        NotificationCenter.default.post(name: Notification.Name.launchscreenDoneNotificationReceived, object: nil)
                        //user_lft_ids.append(Int(lft_id))
                        }
              
                   
                    }
                    //group.leave() -> did this change anything
                }
                
                    uploadJob.resume()
              //  group.leave()
            }


        }
    
    // Used to be a save_user_recommended_launchscreen but deleted july 14 
    
    
    func initTestUser(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object context
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        
        let indexes = NSManagedObject(entity: entity, insertInto: managedContext)
  
        // 3: Setting name attribute (setting attributes for the object in general)
        indexes.setValue("1", forKeyPath: "user_id")
        indexes.setValue("09 00 AM", forKeyPath: "tomorrow_notification")
        indexes.setValue("testemail@gmail.com", forKeyPath: "email")
        indexes.setValue("09 00 PM", forKeyPath: "today_notification")
        indexes.setValue("testpassword", forKeyPath: "password")
     
        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func save_interest(items: [Any]) {
      //  print("at the top of save_interest")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        
        // 2: Creating new managed object and inserting into managed object context
        let entity = NSEntityDescription.entity(forEntityName: "Interest", in: managedContext)!
        
        let interest = NSManagedObject(entity: entity, insertInto: managedContext)
        var trending = false
        if (items[4] as AnyObject).doubleValue == 1{
            trending = true
        }
        // 3: Setting name attribute (setting attributes for the object in general)
        interest.setValue(items[0], forKeyPath: "id")
        interest.setValue(items[1], forKeyPath: "name")
        interest.setValue(items[2], forKeyPath: "desc")
        interest.setValue(items[3], forKeyPath: "category")
        interest.setValue(trending, forKeyPath: "trending")
        interest.setValue(false, forKeyPath: "user_added")
        interest.setValue(false, forKeyPath: "recommended")
        
        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
            
            
            
            
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func big_save_interest(jsonResult: NSArray){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        var jsonElement = NSDictionary()
       // let persons = NSMutableArray()
        //var lft_array: [String] = []
        
        for i in 0 ..< jsonResult.count{
            jsonElement = jsonResult[i] as! NSDictionary
        //    print("downloading Interest (not logged in)")
         //   print(jsonElement)
            if let interest_id = (jsonElement["interest_id"] as AnyObject).doubleValue,
               let name = jsonElement["name"] as? String,
               let desc = jsonElement["description"] as? String,
               let category = jsonElement["category"] as? String,
               //let image = jsonElement["image"] as? String,
               let trending = jsonElement["trending"] as? String {
                    let items = [interest_id, name, desc, category, trending] as [Any]
                let entity = NSEntityDescription.entity(forEntityName: "Interest", in: managedContext)!
                
                let interest = NSManagedObject(entity: entity, insertInto: managedContext)
                var trending = false
                if (items[4] as AnyObject).doubleValue == 1{
                    trending = true
                }
                // 3: Setting name attribute (setting attributes for the object in general)
                interest.setValue(items[0], forKeyPath: "id")
                interest.setValue(items[1], forKeyPath: "name")
                interest.setValue(items[2], forKeyPath: "desc")
                interest.setValue(items[3], forKeyPath: "category")
                interest.setValue(trending, forKeyPath: "trending")
                interest.setValue(false, forKeyPath: "user_added")
                interest.setValue(false, forKeyPath: "recommended")
                
                // 4: Commiting the changes -> save
            }
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    
        
    }
    
    func big_save_lft(jsonResult: NSArray){
        var jsonElement = NSDictionary()

       // var todayIndex = 0
      //  var tomorrowIndex = 0
        
      
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            // 1: Getting hands on NSManagedObjectContext
            let managedContext = appDelegate.persistentContainer.viewContext
            
            
        for i in 0 ..< jsonResult.count{

            jsonElement = jsonResult[i] as! NSDictionary
       //     print(jsonElement)
   
            let interest_id = (jsonElement["interest_id"] as AnyObject).doubleValue
            let lft_id = (jsonElement["lft_id"] as AnyObject).doubleValue
               let desc = jsonElement["description"] as! String
               let category = jsonElement["category"] as! String
            let interest_name = jsonElement["interest_name"] as! String
            let importance = (jsonElement["importance"] as AnyObject).doubleValue
               let date = jsonElement["date"] as! String
            let items = [interest_id!, lft_id!, desc, category, importance!, date, interest_name] as [Any]
            

            
            // 2: Creating new managed object and inserting into managed object context
            let entity = NSEntityDescription.entity(forEntityName: "LookForwardTo", in: managedContext)!
            
            let interest = NSManagedObject(entity: entity, insertInto: managedContext)
            
            // 3: Setting name attribute (setting attributes for the object in general)
            interest.setValue(items[0], forKeyPath: "interest_id")
            interest.setValue(items[1], forKeyPath: "id")
            interest.setValue(items[2], forKeyPath: "desc")
            interest.setValue(items[3], forKeyPath: "category")
            interest.setValue(items[4], forKeyPath: "importance")
            interest.setValue(items[5], forKeyPath: "date")
            interest.setValue(items[6], forKeyPath: "interest_name")
            
           // print("saving look forward to \(interest)")
            
            // 4: Commiting the changes -> save
            
                
            
        }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        
    }
    
    func save_lft(items: [Any]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object context
        let entity = NSEntityDescription.entity(forEntityName: "LookForwardTo", in: managedContext)!
        
        let interest = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3: Setting name attribute (setting attributes for the object in general)
        interest.setValue(items[0], forKeyPath: "interest_id")
        interest.setValue(items[1], forKeyPath: "id")
        interest.setValue(items[2], forKeyPath: "desc")
        interest.setValue(items[3], forKeyPath: "category")
        interest.setValue(items[4], forKeyPath: "importance")
        interest.setValue(items[5], forKeyPath: "date")
        interest.setValue(items[6], forKeyPath: "interest_name")
        
       // print("saving look forward to \(interest)")
        
        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
 
    /*
    override func viewDidDisappear(_ animated: Bool){
        self.dismiss(animated: false, completion: nil)
    }
 */
    
    func updateCurrentUpdatedDate(){

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object contextt]
        var indexes_temp: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HelperVariables")

      //  fetchRequest.predicate = NSPredicate(format: "id == %ld", interest_id)
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if indexes_temp.count == 0{
            initCurrentUpdatedDate()
        }
        else{
        print("in the else statement of updateCurrentUpdatedDate")
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let todays_date = dateFormatter.string(from: Date())
        
        indexes_temp[0].setValue(todays_date, forKeyPath: "currentUpdatedDate")
        

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        }
    
    }
    
    func initCurrentUpdatedDate(){
        
        print("in initCurrentUpdatedDate")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object context
        let entity = NSEntityDescription.entity(forEntityName: "HelperVariables", in: managedContext)!
        
        let indexes = NSManagedObject(entity: entity, insertInto: managedContext)
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd.MM.yy"
        let todays_date = dateFormatter.string(from: Date())
        
        let fetchRequestToday = NSFetchRequest<NSFetchRequestResult>(entityName: "HelperVariables")
        let countToday = try! managedContext.count(for: fetchRequestToday) as Int

        print("countToday in initCurrentUpdatedDate is \(countToday)")
        
        if countToday > 1{
            print("in this if statement in initCurrentUpdatedDate")
        }
        else{
            indexes.setValue(todays_date, forKeyPath: "currentUpdatedDate") // used to be 0 instead of countToday

            print("inserting \(indexes) to HelperVariables")
            // 4: Commiting the changes -> save
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        // 3: Setting name attribute (setting attributes for the object in general)
        
    }
    
    func initLftIndex(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object context
        let entity = NSEntityDescription.entity(forEntityName: "UserLftIndex", in: managedContext)!
        
        // deleting past UserLftIndexes
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLftIndex")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
            {
                try managedContext.execute(deleteRequest)
                try managedContext.save()
            }
        catch
            {
                print ("There was an error in deleting initLftIndex()")
            }
        
        let indexes = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let fetchRequestToday = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLftToday")
        let countToday = try! managedContext.count(for: fetchRequestToday) as Int
     
        let fetchRequestTomorrow = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLftTomorrow")
        let countTomorrow = try! managedContext.count(for: fetchRequestTomorrow) as Int
  
        print("in initLftindex\n\n countToday is \(countToday) countTomorrow is \(countTomorrow)")
        // 3: Setting name attribute (setting attributes for the object in general)
        indexes.setValue(0, forKeyPath: "todayIndex") // used to be 0 instead of countToday
        indexes.setValue(0, forKeyPath: "tomorrowIndex")

     
        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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
    
    func get_user_hash() -> String {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return ""
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        var user: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            user = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        let user_hash = user[0].value(forKey: "user_hash") as! String
        return user_hash
    }
    
    
    func createTestUserAndDeleteOld(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        var user: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            user = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        for i in user{
            managedContext.delete(i)
        }
        
        
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        let indexes = NSManagedObject(entity: entity, insertInto: managedContext)
  
        // 3: Setting name attribute (setting attributes for the object in general)
        indexes.setValue("1", forKeyPath: "user_id")
        indexes.setValue("password", forKeyPath: "password")
        indexes.setValue("test_user_id_1@gmail.com", forKeyPath: "email")
        indexes.setValue("testificate", forKeyPath: "name")
        indexes.setValue("09 00 PM", forKeyPath: "tomorrow_notification")
        indexes.setValue("09 00 AM", forKeyPath: "today_notification")

        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIViewController{
    
    func generate_hash(str: String) -> String{
        
        let str_data = Data(str.utf8)
        let hashed = SHA256.hash(data: str_data)
        let hash_string = hashed.description as String
        var components = hash_string.components(separatedBy: " ")
        return components[2]
        print(components[2])
    }
    
    
    func save_user_interest(user_id: Double, interest_id: Double){
        DispatchQueue.main.async{

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        print("interest_id that is being saved is \(interest_id)")
        // 2: Creating new managed object and inserting into managed object contextt]
        var indexes_temp: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
        fetchRequest.predicate = NSPredicate(format: "id == %d", Int(interest_id))
      //  fetchRequest.predicate = NSPredicate(format: "id == %ld", interest_id)
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if indexes_temp.count > 0{
            print("setting user_added as true for \(indexes_temp[0])")
            indexes_temp[0].setValue(true, forKeyPath: "user_added")
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

    }
        //}
    }
    
    
    
    func generate_lfts(){
        
        print("at the top of generate_lfts() in LaunchscreenViewController")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        /*
        var _testarray: [NSManagedObject] = []
        let _fetchRequestTodayIndex = NSFetchRequest<NSManagedObject>(entityName: "UserLftToday")
        do {
            _testarray = try managedContext.fetch(_fetchRequestTodayIndex)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print("_testarray is \(_testarray)")
        for i in _testarray{
            print((i.value(forKey: "desc") as? String))
        }
        var _today_index = _testarray.count
        print("_today_index is \(_today_index)")
 */
        /*
        var _today_index = try! managedContext.count(for: _fetchRequestTodayIndex) as Int
        let _fetchRequestTomorrowIndex = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLftTomorrow")
        var _tomorrow_index = try! managedContext.count(for: _fetchRequestTomorrowIndex) as Int
        */
        //print("at the very _start of launchscreen, today_index is \(_today_index) and tomorrow_index is \(_tomorrow_index)")
        
        
        var user_interests: [NSManagedObject] = []
        var recommended_user_interests: [NSManagedObject] = []
        var user_interests_ids: [Double] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
        fetchRequest.predicate = NSPredicate(format: "user_added == true")
        do {
            user_interests = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Interest")
        fetchRequest2.predicate = NSPredicate(format: "recommended == true")
        do {
            recommended_user_interests = try managedContext.fetch(fetchRequest2)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
      //  print("user_interests is \(user_interests)")
       // print("recommended_user_interests is \(recommended_user_interests)")
// need to get recommended / set recommended as well when i download user_lft
        for i in user_interests{
            let interest_id = (i.value(forKey: "id") as AnyObject).doubleValue
            user_interests_ids.append(interest_id!)
        }
        for i in recommended_user_interests{
            let interest_id = (i.value(forKey: "id") as AnyObject).doubleValue
            user_interests_ids.append(interest_id!)
        }

        var user_lfts_today: [NSManagedObject] = []
        var user_lfts_tomorrow: [NSManagedObject] = []

       // print("user_)interest_ids is \(user_interests_ids)")
        user_interests_ids = user_interests_ids.uniqueArray
        for i in user_interests_ids{

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy"
            let todays_date = dateFormatter.string(from: Date())
            let calendar = Calendar.current
            let midnight = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight)!
            let tomorrows_date = dateFormatter.string(from: tomorrow)
            
            var TEST: [NSManagedObject] = []
            let fetchRequestTEST = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
            fetchRequestTEST.predicate = NSPredicate(format: "interest_id == %d", Int(i))
            
            do {
                TEST = try managedContext.fetch(fetchRequestTEST)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            if TEST.count > 0{
                for iTEST in TEST{
                    let x = iTEST.value(forKey: "desc") as? String
                   // print("Results for interest ID \(Int(i)) is \(String(describing: x))")
                }
            
            }
            
            var temp: [NSManagedObject] = []
            let fetchRequest3 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
            fetchRequest3.predicate = NSPredicate(format: "interest_id == %d AND date = %@", Int(i), todays_date)
            
            do {
                temp = try managedContext.fetch(fetchRequest3)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            for lft in temp{
             //   print("appending to user lfts today \(lft)")
                user_lfts_today.append(lft)

            }
            
            var temp2: [NSManagedObject] = []
            let fetchRequest4 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
          //  fetchRequest.predicate = NSPredicate(format: "id == %ld", Int(interest_id))
    //        fetchRequest4.sortDescriptors = [sortDescriptor]
            fetchRequest4.predicate = NSPredicate(format: "interest_id == %d AND date = %@", Int(i), tomorrows_date)
            
            
        
            do {
                temp2 = try managedContext.fetch(fetchRequest4)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            for lft in temp2{
             //   print("appending to user lfts tomorrow \(lft)")
                user_lfts_tomorrow.append(lft)

            }
            
        }
        
       // print("user_lfts_today before sort is \(user_lfts_today)")
       // print("user_lfts_tomorrow before sort is \(user_lfts_tomorrow)")
        
        //user_lfts_today = user_lfts_today.sort(by: <#T##(NSManagedObject, NSManagedObject) throws -> Bool#> {$0.value(forKey: "importance") < $1.value(forKey: "importance")})
        
        user_lfts_today = user_lfts_today.sorted(by: { (obj1, obj2) -> Bool in
            
            return (obj1.value(forKey: "importance") as AnyObject).doubleValue > (obj2.value(forKey: "importance") as AnyObject).doubleValue
        })
        user_lfts_tomorrow = user_lfts_tomorrow.sorted(by: { (obj1, obj2) -> Bool in
            
            return (obj1.value(forKey: "importance") as AnyObject).doubleValue > (obj2.value(forKey: "importance") as AnyObject).doubleValue
        })
        
       // print("user_lfts_today after sort is \(user_lfts_today)")
       // print("user_lfts_tomorrow after sort is \(user_lfts_tomorrow)")
        
        //user_lfts_today = user_lfts_today.uniqueArray
        //user_lfts_tomorrow = user_lfts_tomorrow.uniqueArray
        
        /*
        let fetchRequestTodayIndex = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLftToday")
        var today_index = try! managedContext.count(for: fetchRequestTodayIndex) as Int
        let fetchRequestTomorrowIndex = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLftTomorrow")
        var tomorrow_index = try! managedContext.count(for: fetchRequestTomorrowIndex) as Int
        
        print("in launchscreen, today_index is \(today_index) and tomorrow_index is \(tomorrow_index)")
 */
        var today_index = 0
        var tomorrow_index = 0
        
        var today_already_added: [String] = [] // Lft Descriptions that have already been added
        var tomorrow_already_added: [String] = []
        
        for lft in user_lfts_today{
            let interest_id = (lft.value(forKey: "interest_id") as AnyObject).doubleValue
            let lft_id = (lft.value(forKey: "id") as AnyObject).doubleValue
            let desc = (lft.value(forKey: "desc") as! String)
               let category = (lft.value(forKey: "category") as! String)
            let interest_name = (lft.value(forKey: "interest_name") as! String)
            let importance = (lft.value(forKey: "importance") as AnyObject).doubleValue
               let date = (lft.value(forKey: "date") as! String)
            let index = today_index
            let items = [interest_id!, lft_id!, desc, category, importance!, date, interest_name, index] as [Any]
            
            if today_already_added.contains(desc){
                var ignore = 0
               // print("repeat on \(items)")
            }
            else{
                today_already_added.append(desc)
              //  print("saving (today) \(items)")
                DispatchQueue.main.async{
                self.save_userLft(items: items, day: "today")
                }
               // print("saving a user lft in launchscreen with today_index as \(today_index)")
                today_index = today_index + 1
            }
        }
        for lft in user_lfts_tomorrow{
            let interest_id = (lft.value(forKey: "interest_id") as AnyObject).doubleValue
            let lft_id = (lft.value(forKey: "id") as AnyObject).doubleValue
            let desc = (lft.value(forKey: "desc") as! String)
               let category = (lft.value(forKey: "category") as! String)
            let interest_name = (lft.value(forKey: "interest_name") as! String)
            let importance = (lft.value(forKey: "importance") as AnyObject).doubleValue
               let date = (lft.value(forKey: "date") as! String)
            let index = tomorrow_index
                let items = [interest_id!, lft_id!, desc, category, importance!, date, interest_name, index] as [Any]
            
            if tomorrow_already_added.contains(desc){
                var ignore = 0
                //print("repeat on \(items)")
            }
            else{
              //  print("saving (tomorrow) \(items)")
                DispatchQueue.main.async{
                self.save_userLft(items: items, day: "tomorrow")
                }
             //   print("saving a user lft in launchscreen with tomorrow_index as \(tomorrow_index)")

                tomorrow_index = tomorrow_index + 1
            }
        }
        // end of function
    }
    
    func save_userLft(items: [Any], day: String) {
        //print("SAVE USER LFT IN LAUNCHSCREEN GETTING CALLED ONCE WITH \(items)")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if day == "today"{
            let entity = NSEntityDescription.entity(forEntityName: "UserLftToday", in: managedContext)!

            let interest = NSManagedObject(entity: entity, insertInto: managedContext)
            
            // 3: Setting name attribute (setting attributes for the object in general)
            interest.setValue(items[0], forKeyPath: "interest_id")
            interest.setValue(items[1], forKeyPath: "id")
            interest.setValue(items[2], forKeyPath: "desc")
            interest.setValue(items[3], forKeyPath: "category")
            interest.setValue(items[4], forKeyPath: "importance")
            interest.setValue(items[5], forKeyPath: "date")
            interest.setValue(items[6], forKeyPath: "interest_name")
            interest.setValue(items[7], forKeyPath: "index")

        }
        else{
            let entity = NSEntityDescription.entity(forEntityName: "UserLftTomorrow", in: managedContext)!

            let interest = NSManagedObject(entity: entity, insertInto: managedContext)
            
            // 3: Setting name attribute (setting attributes for the object in general)
            interest.setValue(items[0], forKeyPath: "interest_id")
            interest.setValue(items[1], forKeyPath: "id")
            interest.setValue(items[2], forKeyPath: "desc")
            interest.setValue(items[3], forKeyPath: "category")
            interest.setValue(items[4], forKeyPath: "importance")
            interest.setValue(items[5], forKeyPath: "date")
            interest.setValue(items[6], forKeyPath: "interest_name")
            interest.setValue(items[7], forKeyPath: "index")
            
            
            
        }
       
        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension Notification.Name {
    static let loggedInLaunchscreenDoneNotificationReceived = Notification.Name("uk.co.company.app.loggedInLaunchscreenDone")
    static let launchscreenDoneNotificationReceived = Notification.Name("uk.co.company.app.launchscreenDone")
    static let downloadNewReceived = Notification.Name("uk.co.company.app.downloadNew")
}
