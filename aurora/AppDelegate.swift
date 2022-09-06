//
//  AppDelegate.swift
//  aurora
//
//  Created by justin on 1/25/21.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import AVFoundation

import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let window = UIApplication.shared.keyWindow
    
    func applicationDidBecomeActive(_ application: UIApplication){
    print("in applicationDidBecomeActive")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("in applicationWillResignActive")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("in applicationDidEnterBackground")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicatino is about to terminate")
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("in application willFinishLaunchingWithOptions")
        return false
    }
    
 

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // MARK: ADDED SEP 18 to try to fix phone auth
        let firebaseAuth = Auth.auth()
        if (firebaseAuth.canHandleNotification(userInfo)){
            print(userInfo)
            return
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("in application didFinishLaunchingWithOptions in appdelegate")
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
            
        } catch {
            print("Failed to set audio session category")
        }
        
        
        FirebaseApp.configure()
        
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
            // Sets shadow (line below the bar) to a blank image
            UINavigationBar.appearance().shadowImage = UIImage()
            // Sets the translucent background color
            UINavigationBar.appearance().backgroundColor = .clear
            // Set translucent. (Default value is already true, so this can be removed if desired.)
            UINavigationBar.appearance().isTranslucent = true
        
        registerForPushNotifications()
        // make sure, at some point in the past 24 hours, to download the notifications for the next 24 hours
        application.setMinimumBackgroundFetchInterval(86400)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return true
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object context
        let entity = NSEntityDescription.entity(forEntityName: "FirstLogin", in: managedContext)!
        
        let indexes = NSManagedObject(entity: entity, insertInto: managedContext)
        
    
        indexes.setValue(true, forKeyPath: "firstLogin") // used to be 0 instead of countToday
        
        print("inserting \(indexes) to FirstLogin")
        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
        
        
        return true
    }
    
    
 
    
    func applicationWillEnterForeground(_ application: UIApplication) {

        // app will enter in foreground
        // this method is called on first launch when app was closed / killed and every time app is reopened or change status from background to foreground (ex. mobile call)
        
        print("in applicationWillEnterForeground")
        
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let todays_date = dateFormatter.string(from: Date())
        
        print("indexes_temp is \(indexes_temp)")
        if indexes_temp.count == 0{
            print("nothing has been initialized yet, no worries")
        }
        else if indexes_temp[0].value(forKey: "currentUpdatedDate") as! String == todays_date{
            print("up to date, no worries")
        }
        
        else{
            
            NotificationCenter.default.post(name: Notification.Name.downloadNewReceived, object: nil)
            
            self.delete_past_lfts()
            // redirect to launchscreen
            self.generate_lfts()
            
            self.updateCurrentUpdatedDate()
            
            self.initLftIndex()
            
            NotificationCenter.default.post(name: Notification.Name.updateDateVCReceived, object: nil)
            firstTimeRemovingVCSTabBar = true
            guard let tabBarController = window?.rootViewController as? UITabBarController else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            print("redirecting tabBarController in scenedelegate, tabBarController looks like \(tabBarController.viewControllers)")
            
            
        
            // if user is logged in redirect to 0, else redirect to 2?
            /*
            do {
                        try Auth.auth().signOut()
                    }
                 catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
            
 */
            /*
            if Auth.auth().currentUser != nil {
                print("user is logged in in scenedelegate")
                tabBarController.selectedIndex = 0
            }
            else{
                print("user is not logged in in scenedelegate")
                tabBarController.selectedIndex = 2
            }
 */
            //tabBarController.selectedIndex = 0
            
           
        }
        
        
        
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "aurora")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    
    func delete_past_lfts() {
      //  print("SAVE USER LFT IN LAUNCHSCREEN GETTING CALLED ONCE")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let todays_date = dateFormatter.string(from: Date())
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date())
        
        for index in 1...30 {
            let yesterday = calendar.date(byAdding: .day, value: -index, to: midnight)!
            let yesterdays_date = dateFormatter.string(from: yesterday)
            print(yesterdays_date)
            var old_user_interests: [NSManagedObject] = []
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
            fetchRequest.predicate = NSPredicate(format: "date == %@", yesterdays_date)
            do {
                old_user_interests = try managedContext.fetch(fetchRequest)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            for old_lft in old_user_interests{
          //      print("in delete_past_lfts in AppDelegate, deleting \(old_lft.value(forKey: "name"))")
                managedContext.delete(old_lft)
            }

            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLftToday")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        let deleteFetch2 = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLftTomorrow")
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: deleteFetch2)
        do
        {
            try managedContext.execute(deleteRequest)
            try managedContext.execute(deleteRequest2)
            try managedContext.save()
        }
        catch
        {
            print ("There was an error")
        }
        
    }

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func registerForPushNotifications() {
      //1
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
          }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
        
    }
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
        // MARK: ADDED SEP 18 to try to fix phone auth
        let firebaseAuth = Auth.auth()
        firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
    }
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // fetch data from internet now
        if let newData = get_today_and_tomorrow_notifications() {
              schedule_notifications(data: newData)
              completionHandler(.newData)
           }
           completionHandler(.noData)
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
        print("in get_user_id in AppDelegate and returning user_id of", int_user_id)
        return int_user_id
    }
    
    func get_today_and_tomorrow_notifications() -> [String]? {
        let group = DispatchGroup()
        group.enter()
        // MARK: - User id thing here
            let user_id = get_user_id()
            let url5 = NSURL(string: "https://www.sunrisesapp.com/get_user_notifications.php")
            var request5 = URLRequest(url: url5! as URL)
            request5.httpMethod = "POST"
           // var notif_message = ""
        var return_array: [String] = []
            let dataString5 = "user_id=" + String(user_id)

            let dataD5 = dataString5.data(using: .utf8)
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
                        var jsonElement = NSDictionary()
                       // let persons = NSMutableArray()
                        //var lft_array: [String] = []
                       // print(jsonResult)

                        for i in 0 ..< jsonResult.count{
                            jsonElement = jsonResult[i] as! NSDictionary

                            return_array.append((jsonElement["today_notification"] as? String)!)
                            return_array.append((jsonElement["tomorrow_notification"] as? String)!)
                            
                            
                            
                            
                               // print("in the viewdiappear part of saving \(interest_id) for user")
                                
         
                                group.leave()
                              //      self.save_user_interest(user_id: Double(user_id), interest_id: interest_id)
                              //      self.save_user_recommended(interest_id: interest_id)
                                
                            
                            
                            
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
        group.wait()
        return return_array
        
    }
    
    func schedule_notifications(data: [String]){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object contextt]
        var today_notification_string = ""
        var tomorrow_notification_string = ""
        
        var indexes_temp: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        // User id
        //let user_id = 1
       // fetchRequest.predicate = NSPredicate(format: "user_id == %d", user_id)
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        today_notification_string = ((indexes_temp[0].value(forKey: "today_notification") as? String)!)
        tomorrow_notification_string = ((indexes_temp[0].value(forKey: "tomorrow_notification") as? String)!)
        // split into HOUR  MINUTE  AM/PM
        let today_array = today_notification_string.split(separator: " ")
        let tomorrow_array = tomorrow_notification_string.split(separator: " ")
        
        let today_minute = Int(today_array[1])
        var today_hour = Int(today_array[0])
        if today_array[2] == "AM"{
        }
        else{
            today_hour = today_hour! + 12
        }
        var dateComponentsToday = DateComponents()
        dateComponentsToday.hour = today_hour
        dateComponentsToday.minute = today_minute
        
        let tomorrow_minute = Int(tomorrow_array[1])
        var tomorrow_hour = Int(tomorrow_array[0])
        if tomorrow_array[2] == "AM"{
        }
        else{
            tomorrow_hour = tomorrow_hour! + 12
        }
        var dateComponentsTomorrow = DateComponents()
        dateComponentsTomorrow.hour = tomorrow_hour
        dateComponentsTomorrow.minute = tomorrow_minute
        
        let center = UNUserNotificationCenter.current()
        let content_today = UNMutableNotificationContent()

            content_today.body = "Today, look forward to " + data[0]
        //    content.categoryIdentifier = "alarm"
        //    content.userInfo = ["customData": "fizzbuzz"]
            content_today.sound = UNNotificationSound.default
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponentsToday, repeats: false)
    //    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 65, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content_today, trigger: trigger)
            center.add(request)
        let content_tomorrow = UNMutableNotificationContent()

            content_tomorrow.body = "Tomorrow, look forward to " + data[1]
        //    content.categoryIdentifier = "alarm"
        //    content.userInfo = ["customData": "fizzbuzz"]
            content_tomorrow.sound = UNNotificationSound.default
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateComponentsTomorrow, repeats: false)
    //    let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: 65, repeats: true)
        let request2 = UNNotificationRequest(identifier: UUID().uuidString, content: content_tomorrow, trigger: trigger2)
        center.add(request2)
        print("in appdelegate, content_today is \(content_today.body) and content_tomorrow is \(content_tomorrow.body)")
    }
    
    func save_userLft(items: [Any], day: String) {
        print("SAVE USER LFT IN LAUNCHSCREEN GETTING CALLED ONCE WITH \(items)")
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
     //   print("recommended_user_interests is \(recommended_user_interests)")
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

        print("user_)interest_ids is \(user_interests_ids)")
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
                    print("Results for interest ID \(Int(i)) is \(String(describing: x))")
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
                print("appending to user lfts today \(lft)")
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
              //  print("appending to user lfts tomorrow \(lft)")
                user_lfts_tomorrow.append(lft)

            }
            
        }
        
       // print("user_lfts_today before sort is \(user_lfts_today)")
      //  print("user_lfts_tomorrow before sort is \(user_lfts_tomorrow)")
        
        //user_lfts_today = user_lfts_today.sort(by: <#T##(NSManagedObject, NSManagedObject) throws -> Bool#> {$0.value(forKey: "importance") < $1.value(forKey: "importance")})
        
        user_lfts_today = user_lfts_today.sorted(by: { (obj1, obj2) -> Bool in
            
            return (obj1.value(forKey: "importance") as AnyObject).doubleValue > (obj2.value(forKey: "importance") as AnyObject).doubleValue
        })
        user_lfts_tomorrow = user_lfts_tomorrow.sorted(by: { (obj1, obj2) -> Bool in
            
            return (obj1.value(forKey: "importance") as AnyObject).doubleValue > (obj2.value(forKey: "importance") as AnyObject).doubleValue
        })
        
     //   print("user_lfts_today after sort is \(user_lfts_today)")
      //  print("user_lfts_tomorrow after sort is \(user_lfts_tomorrow)")
        
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
                //print("repeat on \(items)")
            }
            else{
                today_already_added.append(desc)
             //   print("saving (today) \(items)")
                DispatchQueue.main.async{
                self.save_userLft(items: items, day: "today")
                }
                //print("saving a user lft in launchscreen with today_index as \(today_index)")
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
               // print("repeat on \(items)")
            }
            else{
             //   print("saving (tomorrow) \(items)")
                DispatchQueue.main.async{
                self.save_userLft(items: items, day: "tomorrow")
                }
           //     print("saving a user lft in launchscreen with tomorrow_index as \(tomorrow_index)")

                tomorrow_index = tomorrow_index + 1
            }
        }
        // end of function
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

}



