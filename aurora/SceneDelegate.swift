//
//  SceneDelegate.swift
//  aurora
//
//  Created by justin on 1/25/21.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("in sceneDidBecomeActive")
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("in sceneWillEnterForeground in SceneDelegate once")
    
        // July 30: Remove
        NotificationCenter.default.post(name: Notification.Name.changeBackgroundNotificationReceived, object: nil)
        
        // Check if current date is same as date stored in 'previousUpdatedDate' -> if yes, leave it alone/don't update anything?
        // if no, redirect to launchsceen
        
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
            let group = DispatchGroup()
            
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
           // tabBarController.selectedIndex = 0
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
            
           
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
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
          //      print("in delete_past_lfts in SceneDelegate, deleting \(old_lft.value(forKey: "desc")) for date \(old_lft.value(forKey: "date"))")
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
        /*
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight)!
        let tomorrows_date = dateFormatter.string(from: tomorrow)
        
        
    
        var old_user_interests: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
        fetchRequest.predicate = NSPredicate(format: "date != %@ AND date != %@", todays_date, tomorrows_date)
        do {
            old_user_interests = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for old_lft in old_user_interests{
            print("in delete_past_lfts in SceneDelegate, deleting \(old_lft)")
            managedContext.delete(old_lft)
        }

       
        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
 */
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
        
       // print("user_interests is \(user_interests)")
      //  print("recommended_user_interests is \(recommended_user_interests)")
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

      //  print("user_)interest_ids is \(user_interests_ids)")
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
                  //  print("Results for interest ID \(Int(i)) is \(String(describing: x))")
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
              //  print("appending to user lfts today \(lft)")
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
        
    //    print("user_lfts_today before sort is \(user_lfts_today)")
    //    print("user_lfts_tomorrow before sort is \(user_lfts_tomorrow)")
        
        //user_lfts_today = user_lfts_today.sort(by: <#T##(NSManagedObject, NSManagedObject) throws -> Bool#> {$0.value(forKey: "importance") < $1.value(forKey: "importance")})
        
        user_lfts_today = user_lfts_today.sorted(by: { (obj1, obj2) -> Bool in
            
            return (obj1.value(forKey: "importance") as AnyObject).doubleValue > (obj2.value(forKey: "importance") as AnyObject).doubleValue
        })
        user_lfts_tomorrow = user_lfts_tomorrow.sorted(by: { (obj1, obj2) -> Bool in
            
            return (obj1.value(forKey: "importance") as AnyObject).doubleValue > (obj2.value(forKey: "importance") as AnyObject).doubleValue
        })
        
      //  print("user_lfts_today after sort is \(user_lfts_today)")
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
             //   print("repeat on \(items)")
                var ignore = 0
            }
            else{
                today_already_added.append(desc)
               // print("saving (today) \(items)")
                DispatchQueue.main.async{
                self.save_userLft(items: items, day: "today")
                }
             //   print("saving a user lft in launchscreen with today_index as \(today_index)")
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
                //  print("repeat on \(items)")
                var ignore = 0
            }
            else{
             //   print("saving (tomorrow) \(items)")
                DispatchQueue.main.async{
                self.save_userLft(items: items, day: "tomorrow")
                }
            //    print("saving a user lft in launchscreen with tomorrow_index as \(tomorrow_index)")

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

