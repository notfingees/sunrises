//
//  TabBarViewController.swift
//  aurora
//
//  Created by justin on 2/2/21.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseCore
import AVFoundation

class TabBarViewController: UITabBarController {

    
    var changeBackgroundNotificationReceivedObserver: NSObjectProtocol?
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    var switchToTabBarOneObserver: NSObjectProtocol?
   
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        switchToTabBarOneObserver = NotificationCenter.default.addObserver(forName: Notification.Name.switchToTabBarOneReceived, object: nil, queue: nil, using: { (notification) in
            DispatchQueue.main.async{
                print("Switch to Tab bar One Received")
            self.selectedIndex = 0
            }
            
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // presenting view controller is not dismissing itself
       // self.presentingViewController?.dismiss(animated: false, completion: nil)
     //   presentingViewController!.dismiss(animated: false, completion: nil)
        // this line is really important
        print("inserting subview")
        //self.view.insertSubview(SkyBackgroundViewController().view, at: 0)
      //  self.view.backgroundColor = .red
        /*
        var BackgroundVideoView = BackgroundVideoViewController().view
        BackgroundVideoView!.tag = 100
        self.view.insertSubview(BackgroundVideoView!, at: 0)
 */
        // MARK: IMPORTANT
        self.view.insertSubview(BackgroundVideoViewController().view, at: 0)
        /*
        changeBackgroundNotificationReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.changeBackgroundNotificationReceived, object: nil, queue: nil, using: {(notification) in
            
            print("in notification of changeBackgroundNotificationReceivedObserver, about to print subviews")
            
            var subviews = self.view.subviewsRecursive()
            print("length of subviews is \(subviews.count)")
            for subview in subviews{
            print(subview)
            }
            
            if let viewWithTag = self.view.viewWithTag(100){
                print("Removing backgroundvideoview from subviews")
                viewWithTag.removeFromSuperview()
                /*
                var NewBackgroundVideoView = BackgroundVideoViewController().view
                NewBackgroundVideoView!.tag = 100
                self.view.insertSubview(NewBackgroundVideoView!, at: 0)
 */
                self.view.insertSubview(BackgroundVideoViewController().view, at: 0)
            }
            else{
                print("some type of error creating/finding BackgroundVideoViewController")
            }
        })
 */
        
        
      //  self.view.insertSubview(BackgroundVideoViewController().view, at: 0)
        
        //
        UITabBar.appearance().tintColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
        
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().clipsToBounds = true
        
        // MARK: Need to make this so that it deletes everything except interests if user is logged in, deletes nothing if user isn't (?)
        
        // July 28 
        //self.clearAllCoreData()
        self.delete_past_lfts()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // MARK: July 13 - is this an adequate way of signing out if it's users first time opening
        // the app? Firebaes is remembering that I'm signed in
        let managedContext = appDelegate.persistentContainer.viewContext
        var indexes_temp: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HelperVariables")
    
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        if indexes_temp.count == 0{
            // sign out
            print("signing out in tabbarviewcontroller")
            do {
                        try Auth.auth().signOut()
                    }
                 catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
        }
        
        
        
        self.selectedIndex = 2
        
        /*
        let controller:SkyBackgroundViewController = self.storyboard!.instantiateViewController(withIdentifier: "SkyBackgroundViewController") as! SkyBackgroundViewController
       
        controller.view.frame = self.view.bounds
     //   self.view.addSubview(controller.view)
        self.view.insertSubview(controller.view, at: 0)
        self.addChild(controller)
        controller.didMove(toParent: self)
 */
     //   self.view.insertSubview(SkyBackgroundViewController, at: 0)
      
    

        // Do any additional setup after loading the view.
/*
        let HEIGHT_TAB_BAR:CGFloat = self.view.frame.size.height * 0.12
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var tabFrame = self.tabBar.frame
        print("IN TABBARVIEWCONTROLLER")
        print(self.view.frame.size.height)
        tabFrame.size.height = HEIGHT_TAB_BAR
        tabFrame.origin.y = self.view.frame.size.height - HEIGHT_TAB_BAR
        self.tabBar.frame = tabFrame
 */
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
             //   print("in delete_past_lfts in TabBarViewController, deleting \(old_lft.value(forKey: "desc")) for date \(old_lft.value(forKey: "date"))")
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
    
    public func clearAllCoreData() {
        print("in clearAllCoreData in SceneDelegate, getting called once")
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

}
extension Notification.Name {
    static let changeBackgroundNotificationReceived = Notification.Name("uk.co.company.app.changeBackground")
}
extension Notification.Name {
    static let switchToTabBarOneReceived = Notification.Name("uk.co.company.app.switchToTabBarOneReceived")
}

extension UIView {

    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }

}
/*
extension UITabBar {
    static func setTransparentTabbar(){
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().clipsToBounds = true
    }
}
*/
