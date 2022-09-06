//
//  ViewController.swift
//  aurora
//
//  Created by justin on 1/25/21.
//

import UIKit
import SpriteKit
import CoreData
import MessageUI
import CryptoKit

var firstTimeRemovingVCSTabBar = true

class ViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
    }
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    var updateDateVCReceivedObserver: NSObjectProtocol?
    
    
    // Text / Look forward to stuff
    @IBOutlet weak var lft_today: UILabel!
    
    @IBOutlet weak var lft_tomorrow: UILabel!
    
    // Scrolling stuff
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var view_tomorrow_label: UILabel!
    @IBOutlet weak var view_today_label: UILabel!
    
    // Date stuff
    @IBOutlet weak var today_month: UILabel!
    @IBOutlet weak var today_day: UILabel!
    @IBOutlet weak var tomorrow_month: UILabel!
    @IBOutlet weak var tomorrow_day: UILabel!
    

    
    // MARK: - DATA DOWNLOADING STUFF
    // Add to 'loading screen' in future
    
    var lft_today_array: [NSManagedObject] = []
    var lft_tomorrow_array: [NSManagedObject] = []
    
    var firstSwipe = true
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.tabBarController!.tabBar.isHidden = false
        self.tabBarController!.tabBar.layer.zPosition = 10

        
    
        print("printing viewcontrollers")
        print(self.tabBarController?.viewControllers)
        var vcs = self.tabBarController?.viewControllers
      //  vcs!.remove(at: 5)
    //    vcs!.remove(at: 3)

        if firstTimeRemovingVCSTabBar{
            // try removing specific element instead e.g. remove type 'LaunchscreenViewController' 
            var index = 0
            for vc in vcs!{
                print("index in firstTimeRemovingVCSTabBar is \(index)")
                if vc is ViewController || vc is SearchViewController || vc is SettingsViewController || vc is CalendarViewController{
                    print("Ignoring \(vcs![index])")
                    index = index + 1
                }
                else{
                    vcs!.remove(at: index)
                    print("removing vc \(vcs![index])")
                }
                
            }
            
            // July 19 modificatoin
            
            /*
            vcs!.remove(at: 2)
            print("removing vc \(vcs![2])")
            vcs!.remove(at: 2)
            print("removing vc \(vcs![2])")
            vcs!.remove(at: 2)
            print("removing vc \(vcs![2])")
        
            
            if userLoggedInVCS{
            vcs!.remove(at: 2)
                print("removing vc \(vcs![2])")
            }
            */
            firstTimeRemovingVCSTabBar = false
        }
 
//        vcs!.remove(at: 3)
        self.tabBarController?.viewControllers = vcs
        
        
        
        print("at the top of view controller.swift")
        
        //self.presentingViewController?.dismiss(animated: false, completion: nil)
        /*
        if presentingViewController != nil{
            presentingViewController!.dismiss(animated: false, completion: nil)
        }
 */

      
     
       
        
        DispatchQueue.main.async{
            
        //    self.initLftIndex()
            self.loadFirstLft()
        }
        

     
        
    }
    
    
    
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateDateVCReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.updateDateVCReceived, object: nil, queue: nil, using: { (notification) in
                    DispatchQueue.main.async { // because the notification won't be received on the main queue and you want to update the UI which must be done on the main queue.
                        let date = Date()
                        let dateFormatter1 = DateFormatter()
                        let dateFormatter2 = DateFormatter()
                        dateFormatter1.locale = Locale(identifier: "en_US")
                        dateFormatter1.setLocalizedDateFormatFromTemplate("MMMM") // set template after setting locale
                        self.today_month.text = dateFormatter1.string(from: date)
                        dateFormatter2.locale = Locale(identifier: "en_US")
                        dateFormatter2.setLocalizedDateFormatFromTemplate("dd")
                        self.today_day.text = dateFormatter2.string(from: date)
                        
                        var dayComponent    = DateComponents()
                        dayComponent.day    = 1 // For removing one day (yesterday): -1
                        let theCalendar     = Calendar.current
                        let tomorrow        = theCalendar.date(byAdding: dayComponent, to: Date())
                        let dateFormatter3 = DateFormatter()
                        let dateFormatter4 = DateFormatter()
                        dateFormatter3.locale = Locale(identifier: "en_US")
                        dateFormatter3.setLocalizedDateFormatFromTemplate("MMMM") // set template after setting locale
                        self.tomorrow_month.text = dateFormatter3.string(from: tomorrow!)
                        dateFormatter4.locale = Locale(identifier: "en_US")
                        dateFormatter4.setLocalizedDateFormatFromTemplate("dd")
                        self.tomorrow_day.text = dateFormatter4.string(from: tomorrow!)
                        print("Remote Notification Received in VC")
                        
                        self.loadFirstLft()
                    }
                })
        
        scrollView.showsVerticalScrollIndicator = false
        // July 13
        DispatchQueue.main.async{
            var indexes_temp: [NSManagedObject] = []
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
            do {
                indexes_temp = try managedContext.fetch(fetchRequest)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            print("There are \(indexes_temp.count) interests in Core Data")
            
            var indexes_temp2: [NSManagedObject] = []

            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
            do {
                indexes_temp2 = try managedContext.fetch(fetchRequest2)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            print("There are \(indexes_temp2.count) LFTs in Core Data")
            
        }
        
        
        
    }
    
    
 
    @objc func lftSwipe(sender: UISwipeGestureRecognizer){
        print("in lftSwipe")
       
        var indexes_temp: [NSManagedObject] = []
 
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Fetching the data -> NSFetchRequest is very flexible
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserLftIndex")
        
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // MARK: TEST
        /*
        var testarray: [NSManagedObject] = []
        let fetchRequestTest = NSFetchRequest<NSManagedObject>(entityName: "UserLftToday")
        
        do {
            testarray = try managedContext.fetch(fetchRequestTest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        for i in testarray{
            let desc = i.value(forKey: "desc")
            let ind = i.value(forKey: "index")
            print("lft desc is \(desc) and the index is \(ind)")
        }
 */
   
        
        var todayIndex = (indexes_temp[0].value(forKey: "todayIndex")) as! Int
        var tomorrowIndex = (indexes_temp[0].value(forKey: "tomorrowIndex")) as! Int
       
        
        let fetchRequest3 = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLftToday")

        
        
        
        var c = try! managedContext.count(for: fetchRequest3) as Int
        
        if c == 0{
            print("no LFTs for today")
        }
        else{
        print("user currently has", c, "in userLftToday coreData")
        
      
        if(sender.direction == .left){
            todayIndex = (todayIndex + 1) % c
            print("setting todays lftIndex to \(todayIndex), c (count of userlfttoday) is \(c)")
            setLftIndex(newIndex: todayIndex, day: "today")
        }
        else if(sender.direction == .right){
            todayIndex = (todayIndex + c - 1) % c
            print("setting todays lftIndex to \(todayIndex), c (count of userlfttoday) is \(c)")
            setLftIndex(newIndex: todayIndex, day: "today")
        }
        
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "UserLftToday")
        fetchRequest2.predicate = NSPredicate(format: "index == %d", todayIndex)
        
        
        var lft_temp: [NSManagedObject] = []
        do {
            lft_temp = try managedContext.fetch(fetchRequest2)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        lft_temp[0].value(forKey: "desc") as! String
        
   
        if sender.direction == .left {
            
    
            lft_today.slideInFromRight()
            lft_today.text = "Today, look forward to " + (lft_temp[0].value(forKey: "desc") as! String)
        }
        if sender.direction == .right {

            lft_today.slideInFromLeft()
            lft_today.text = "Today, look forward to " + (lft_temp[0].value(forKey: "desc") as! String)
       
        }
        }
    }
    
    @objc func lftSwipeTomorrow(sender: UISwipeGestureRecognizer){
       
        var indexes_temp: [NSManagedObject] = []
 
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Fetching the data -> NSFetchRequest is very flexible
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserLftIndex")
        
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
   
        
        var todayIndex = (indexes_temp[0].value(forKey: "todayIndex")) as! Int
        var tomorrowIndex = (indexes_temp[0].value(forKey: "tomorrowIndex")) as! Int
       

       
        
        // getting how many 'UserLftTodays' there are
        
        let fetchRequest3 = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLftTomorrow")
        var c = try! managedContext.count(for: fetchRequest3) as Int
        
        if c == 0{
            print("no LFTs for tomorrow")
        }
        else{
            
        
      
        if(sender.direction == .left){
            tomorrowIndex = (tomorrowIndex + 1) % c
            setLftIndex(newIndex: tomorrowIndex, day: "tomorrow")
        }
        else if(sender.direction == .right){
            tomorrowIndex = (tomorrowIndex + c - 1) % c
            setLftIndex(newIndex: tomorrowIndex, day: "tomorrow")
        }
        
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "UserLftTomorrow")
        fetchRequest2.predicate = NSPredicate(format: "index == %d", tomorrowIndex)
        
        
        var lft_temp: [NSManagedObject] = []
        do {
            lft_temp = try managedContext.fetch(fetchRequest2)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        lft_temp[0].value(forKey: "desc") as! String
        
   
        if sender.direction == .left {
            
    
            lft_tomorrow.slideInFromRight()
            lft_tomorrow.text = "Tomorrow, look forward to " + (lft_temp[0].value(forKey: "desc") as! String)
        }
        if sender.direction == .right {

            lft_tomorrow.slideInFromLeft()
            lft_tomorrow.text = "Tomorrow, look forward to " + (lft_temp[0].value(forKey: "desc") as! String)
       
        }
        }
    }

    func loadFirstLft(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Only for today rn
        
   
        
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "UserLftToday")
        fetchRequest2.predicate = NSPredicate(format: "index == %d", 0)

        var lft_temp: [NSManagedObject] = []
        do {
            lft_temp = try managedContext.fetch(fetchRequest2)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let fetchRequest3 = NSFetchRequest<NSManagedObject>(entityName: "UserLftTomorrow")
        fetchRequest3.predicate = NSPredicate(format: "index == %d", 0)

        var lft_temp2: [NSManagedObject] = []
        do {
            lft_temp2 = try managedContext.fetch(fetchRequest3)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if lft_temp.count > 0{
            var today_first_lft = lft_temp[0].value(forKey: "desc") as! String
            today_first_lft = "Today, look forward to " + today_first_lft
            lft_today.text = today_first_lft
        }
        else{
            //lft_today.text = "Looks like we couldn't find anything for today - try adding more interests!"
            lft_today.text = "Looks like we couldn't find anything for today - try adding more interests!"
        }
        
        if lft_temp2.count > 0 {
            var tomorrow_first_lft = lft_temp2[0].value(forKey: "desc") as! String
            tomorrow_first_lft = "Tomorrow, look forward to " + tomorrow_first_lft
            lft_tomorrow.text = tomorrow_first_lft
        }
        else{
            lft_tomorrow.text = "Looks like we couldn't find anything for tomorrow - try adding more interests!"
        }
        
     
    
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in viewDidLoad of ViewController.swift")
     //   addRain()
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.lftSwipe(sender:)))

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.lftSwipe(sender:)))

        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        let leftSwipe2 = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.lftSwipeTomorrow(sender:)))

        let rightSwipe2 = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.lftSwipeTomorrow(sender:)))

        leftSwipe2.direction = .left
        rightSwipe2.direction = .right
        
        // used to be view.addGestureRecognizer
        lft_today.isUserInteractionEnabled = true
        self.view.bringSubviewToFront(lft_today)
        lft_today.addGestureRecognizer(leftSwipe)
        lft_today.addGestureRecognizer(rightSwipe)
        
        lft_tomorrow.isUserInteractionEnabled = true
        self.view.bringSubviewToFront(lft_tomorrow)
        lft_tomorrow.addGestureRecognizer(leftSwipe2)
        lft_tomorrow.addGestureRecognizer(rightSwipe2)
        
        /*
        let longpress1 = UILongPressGestureRecognizer(target: self, action: #selector(show_long_press_menu))
        lft_today.addGestureRecognizer(longpress1)
        let longpress2 = UILongPressGestureRecognizer(target: self, action: #selector(show_long_press_menu))
        lft_tomorrow.addGestureRecognizer(longpress2)
 */
        let interaction = UIContextMenuInteraction(delegate: self)
        lft_today.addInteraction(interaction)
        let interaction2 = UIContextMenuInteraction(delegate: self)
        lft_tomorrow.addInteraction(interaction2)
        


        // Scroll view auto scroll management
        scrollView.delegate = self
        let tomorrow_tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tap_tomorrow))
        view_tomorrow_label.isUserInteractionEnabled = true
        view_tomorrow_label.addGestureRecognizer(tomorrow_tap)
      //  lft_today.addGestureRecognizer(tomorrow_tap)
        self.view.bringSubviewToFront(view_tomorrow_label)
        let today_tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tap_today))
        view_today_label.isUserInteractionEnabled  = true
        view_today_label.addGestureRecognizer(today_tap)
        
        // Date stuff
        let date = Date()
        let dateFormatter1 = DateFormatter()
        let dateFormatter2 = DateFormatter()
        dateFormatter1.locale = Locale(identifier: "en_US")
        dateFormatter1.setLocalizedDateFormatFromTemplate("MMMM") // set template after setting locale
        self.today_month.text = dateFormatter1.string(from: date)
        dateFormatter2.locale = Locale(identifier: "en_US")
        dateFormatter2.setLocalizedDateFormatFromTemplate("dd")
        self.today_day.text = dateFormatter2.string(from: date)
        
        var dayComponent    = DateComponents()
        dayComponent.day    = 1 // For removing one day (yesterday): -1
        let theCalendar     = Calendar.current
        let tomorrow        = theCalendar.date(byAdding: dayComponent, to: Date())
        let dateFormatter3 = DateFormatter()
        let dateFormatter4 = DateFormatter()
        dateFormatter3.locale = Locale(identifier: "en_US")
        dateFormatter3.setLocalizedDateFormatFromTemplate("MMMM") // set template after setting locale
        self.tomorrow_month.text = dateFormatter3.string(from: tomorrow!)
        dateFormatter4.locale = Locale(identifier: "en_US")
        dateFormatter4.setLocalizedDateFormatFromTemplate("dd")
        self.tomorrow_day.text = dateFormatter4.string(from: tomorrow!)
 
         print("in view did load of ViewController")
        
        // Loading the tutorial for the app
        print("about to load tutorial")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object contextt]
        var indexes_temp: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FirstLogin")

      //  fetchRequest.predicate = NSPredicate(format: "id == %ld", interest_id)
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        print("indexes_temp is \(indexes_temp)")
        if indexes_temp.count == 0{
            print("nothing has been initialized yet in firstLogin, fucking error")
        }
        else if indexes_temp[0].value(forKey: "firstLogin") as! Bool == true{
            print("Displaying tutorial")
            let alert = UIAlertController(title: "Hi!", message: "Thanks for downloading Sunrises! Swipe left and right to see everything you have to look forward to, up and down to switch between todays items and tomorrows items, and press and hold to send an item to someone else!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok!", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            var set_first_login_false: [NSManagedObject] = []
            let _fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FirstLogin")
            do {
                set_first_login_false = try managedContext.fetch(_fetchRequest)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            
            // 3: Setting name attribute (setting attributes for the object in general)

            indexes_temp[0].setValue(false, forKeyPath: "firstLogin")
            

            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            
            
        }
        
    }
    
    // Long press function
    /*
    @objc func show_long_press_menu(sender: UILongPressGestureRecognizer){
                Menu("Options") {
                    Button("Order Now", action: placeOrder)
                    Button("Adjust Order", action: adjustOrder)
                    Button("Cancel", action: cancelOrder)
                }
            

            func placeOrder() { }
            func adjustOrder() { }
            func cancelOrder() { }
    }
 */
    
    // Scroll view functions
    
    @objc func tap_tomorrow(sender: UITapGestureRecognizer){
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom+34)
            scrollView.setContentOffset(bottomOffset, animated: true)
    }
    @objc func tap_today(sender: UITapGestureRecognizer){
        let topOffset = CGPoint(x: 0, y: -34)
        scrollView.setContentOffset(topOffset, animated: true)
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {


        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if (actualPosition.y > 0){

            let topOffset = CGPoint(x: 0, y: -34)
                scrollView.setContentOffset(topOffset, animated: true)
            

            
        }else{

            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom + 34)
                scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }

    
    func initLftIndex(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object context
        let entity = NSEntityDescription.entity(forEntityName: "UserLftIndex", in: managedContext)!
        
        let indexes = NSManagedObject(entity: entity, insertInto: managedContext)
  
        // 3: Setting name attribute (setting attributes for the object in general)
        indexes.setValue(0, forKeyPath: "todayIndex")
        indexes.setValue(0, forKeyPath: "tomorrowIndex")

     
        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    
    func setLftIndex(newIndex: Int, day: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object contextt]
        var indexes_temp: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserLftIndex")
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        // 3: Setting name attribute (setting attributes for the object in general)
        if(day == "today"){
            //print("setting todayIndex to ", newIndex)
            indexes_temp[0].setValue(newIndex, forKeyPath: "todayIndex")
        }
        else{
            indexes_temp[0].setValue(newIndex, forKeyPath: "tomorrowIndex")
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        
    }
    
}


    


// MARK: - Extensions
extension NSManagedObjectContext
{
    func deleteAllData()
    {
        print("deleting all data once")
        guard let persistentStore = persistentStoreCoordinator?.persistentStores.last else {
            return
        }

        guard let url = persistentStoreCoordinator?.url(for: persistentStore) else {
            return
        }

        performAndWait { () -> Void in
            self.reset()
            do
            {
                try self.persistentStoreCoordinator?.remove(persistentStore)
                try FileManager.default.removeItem(at: url)
                try self.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            }
            catch { /*dealing with errors up to the usage*/ }
        }
    }
    
    
}




extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}


extension UIView {
     // Name this function in a way that makes sense to you...
     // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideInFromLeft(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
         // Create a CATransition animation
         let slideInFromLeftTransition = CATransition()
 
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = (delegate as! CAAnimationDelegate)
        }

        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed

        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    
    func slideInFromRight(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
         // Create a CATransition animation
         let slideInFromRightTransition = CATransition()
 
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromRightTransition.delegate = (delegate as! CAAnimationDelegate)
        }

        // Customize the animation's properties
        slideInFromRightTransition.type = CATransitionType.push
        slideInFromRightTransition.subtype = CATransitionSubtype.fromRight
        slideInFromRightTransition.duration = duration
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromRightTransition.fillMode = CAMediaTimingFillMode.removed

        // Add the animation to the View's layer
        self.layer.add(slideInFromRightTransition, forKey: "slideInFromRightTransition")
    }
}
/*
extension UILabel{
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = .clear
        }
    }
}
 */

extension ViewController: UIContextMenuInteractionDelegate {
    
  func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    configurationForMenuAtLocation location: CGPoint)
      -> UIContextMenuConfiguration? {
    if self.lft_today.frame.contains(interaction.location(in: self.view)){
    return UIContextMenuConfiguration(
      identifier: nil,
      previewProvider: nil,
      actionProvider: { _ in
        let aorInterest = self.addOrRemoveInterestToday()
        let _textLft = self.textTodayLft()
        let children = [aorInterest, _textLft]
        return UIMenu(title: "", children: children)
    })
    }
    else{
        return UIContextMenuConfiguration(
          identifier: nil,
          previewProvider: nil,
          actionProvider: { _ in
            let aorInterest = self.addOrRemoveInterestTomorrow()
            let _textLft = self.textTomorrowLft()
            let children = [aorInterest, _textLft]
            return UIMenu(title: "", children: children)
        })
    }
  }
    
    func textTodayLft() -> UIAction {
        return UIAction(
         // title: _title,
         // image: _image,
          title: "Send this to a friend",
          image: UIImage(systemName: "paperplane"),
          identifier: nil) { _ in
            
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self

        // Configure the fields of the interface.
        composeVC.recipients = ["123456789"]
            composeVC.body = self.lft_today.text

        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    }
    func textTomorrowLft() -> UIAction {
        return UIAction(
         // title: _title,
         // image: _image,
          title: "Send this to a friend",
          image: UIImage(systemName: "paperplane"),
          identifier: nil) { _ in
            
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self

        // Configure the fields of the interface.
        composeVC.recipients = ["123456789"]
            composeVC.body = self.lft_tomorrow.text

        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    }
    

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
       // if interaction.location(in: self.view).y < self.view.frame.size.height*0.6 {
        if self.lft_today.frame.contains(interaction.location(in: self.view)){
            var testframe: CGRect
            let frame = self.lft_today.superview?.convert(self.lft_today.frame, to: nil)

                    print(frame)
            testframe = frame!
                
            let previewTarget = UIPreviewTarget(container: self.view, center: CGPoint(x: self.lft_today.center.x, y: testframe.origin.y + self.lft_today.frame.size.height/2))
          //  let previewTarget = UIPreviewTarget(container: self.view, center: CGPoint(x: self.lft_today.center.x, y: self.lft_today.center.y + self.lft_today.frame.size.height*0.4))
          //  let previewTarget = UIPreviewTarget(container: self.view, center: CGPoint(x: self.lft_today.center.x, y: self.lft_today.frame.origin.y + self.lft_today.frame.size.height))
          //  let previewTarget = UIPreviewTarget(container: self.view, center: CGPoint(x: self.lft_today.center.x, y: self.view.frame.size.height*0.372 +  self.lft_today.frame.size.height/2))
            // 314
            let previewParams = UIPreviewParameters()
            previewParams.backgroundColor = .clear
            print("TAPPED LFT_TODAY")
            return UITargetedPreview(view: self.lft_today, parameters: previewParams, target: previewTarget)
        }
        else{
            var testframe: CGRect
            let frame = self.lft_tomorrow.superview?.convert(self.lft_tomorrow.frame, to: nil)

                    print(frame)
            testframe = frame!
                
            let previewTarget = UIPreviewTarget(container: self.view, center: CGPoint(x: self.lft_tomorrow.center.x, y: testframe.origin.y + self.lft_tomorrow.frame.size.height/2))
            let previewParams = UIPreviewParameters()
            previewParams.backgroundColor = .clear
            print("TAPPED LFT_TOMORROW")
            
            return UITargetedPreview(view: self.lft_tomorrow, parameters: previewParams, target: previewTarget)
            
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
    
    
    
    func addOrRemoveInterestTomorrow() -> UIAction {
      // 3
      //  lft_todayself.lft_today.text
        /*
        var lft_tomorrow_desc = self.lft_tomorrow.text
        lft_tomorrow_desc = String(lft_tomorrow_desc!.dropFirst(26))
        var _title = ""
        var _image: UIImage = UIImage()
        
        DispatchQueue.main.async{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        var user_interests: [NSManagedObject] = []
            var _user_interests: [NSManagedObject] = []
  
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
        fetchRequest.predicate = NSPredicate(format: "desc == %@", lft_tomorrow_desc!)
            print("lft_tomorrow_desc is \(lft_tomorrow_desc!)")
        do {
            _user_interests = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
            let interest_id = (_user_interests[0].value(forKey: "interest_id") as AnyObject).doubleValue
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Interest")
            print("interest_id in addOrRemoveInterestTomorrow() is \(interest_id)")
            fetchRequest2.predicate = NSPredicate(format: "id == %d", Int(interest_id!))
            do {
                user_interests = try managedContext.fetch(fetchRequest2)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if(!(user_interests[0].value(forKey: "user_added") as AnyObject).boolValue){
                _image = UIImage(systemName: "plus")!
                _title = "Add"
            }
            else{
                _image = UIImage(systemName: "delete.left")!
                _title = "Remove"
            }
        }
 */
        
      // 4
      return UIAction(
       // title: _title,
       // image: _image,
        title: "Add or remove interest",
        image: UIImage(systemName: "delete.left"),
        identifier: nil) { _ in
        //  self.currentUserRating = 0
        var lft_tomorrow_desc = self.lft_tomorrow.text
        lft_tomorrow_desc = String(lft_tomorrow_desc!.dropFirst(26))
// MARK: User Id here
        let user_id = self.get_user_id()
        let user_hash = self.get_user_hash()
        
        DispatchQueue.main.async{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        var _user_interests: [NSManagedObject] = []
        var user_interests: [NSManagedObject] = []
  
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
        fetchRequest.predicate = NSPredicate(format: "desc == %@", lft_tomorrow_desc!)
        do {
            _user_interests = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
            
            let interest_id = (_user_interests[0].value(forKey: "interest_id") as AnyObject).doubleValue
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Interest")
            fetchRequest2.predicate = NSPredicate(format: "id == %d", Int(interest_id!))
            do {
                user_interests = try managedContext.fetch(fetchRequest2)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            
            if((user_interests[0].value(forKey: "user_added") as? Bool)!){
              // remove as interest, need to remember to upload to server as well
                
                user_interests[0].setValue(false, forKey: "user_added")
                
                let string_selected_interest_id = (user_interests[0].value(forKey: "id") as AnyObject).doubleValue
                let url3 = NSURL(string: "https://www.sunrisesapp.com/remove_user_interest.php")
                var request = URLRequest(url: url3! as URL)
                request.httpMethod = "POST"
                var dataString = "user_id=" + String(user_id) + "&interest_id=" + String(string_selected_interest_id!) + "&user_hash=" + user_hash
              //  print("dataString is \(dataString)")
                let dataD = dataString.data(using: .utf8)
                do {
                    let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD){
                        data, response, error in
                        if error != nil {
                            print(error)
                        }
                        else {
                            var jsonResult = NSArray()
                            do{
                                jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                        
                                    } catch let error as NSError {
                                        print(error)
                                        
                                    }

                       
                        }
                    }
                    
                        uploadJob.resume()
                }
            }
            else{
               // add as interest
                user_interests[0].setValue(true, forKey: "user_added")
                let string_selected_interest_id = (user_interests[0].value(forKey: "id") as AnyObject).doubleValue
                
                let url4 = NSURL(string: "https://www.sunrisesapp.com/update_user_interests.php")
                var request4 = URLRequest(url: url4! as URL)
                request4.httpMethod = "POST"
                let dataString2 = "user_id=" + String(user_id) + "&interest_id=" + String(string_selected_interest_id!) + "&user_hash=" + user_hash
                
                let dataD2 = dataString2.data(using: .utf8)
                do {
                    let uploadJob2 = URLSession.shared.uploadTask(with: request4, from: dataD2){
                        data, response, error in
                        if error != nil {
                            print(error)
                        }
                        else {
                            print("no error!")
                        }

                    }
                    
                        uploadJob2.resume()
                    }
                
                let url3 = NSURL(string: "https://www.sunrisesapp.com/get_recommended_interests.php")
                var request = URLRequest(url: url3! as URL)
                request.httpMethod = "POST"
                var dataString = "interest_id=" + String(string_selected_interest_id!)
                //print("dataString is \(dataString)")
                let dataD = dataString.data(using: .utf8)
                do {
                    let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD){
                        data, response, error in
                        if error != nil {
                            print(error)
                        }
                        else {
                            var jsonResult = NSArray()
                            do{
                                jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                        
                                    } catch let error as NSError {
                                        print(error)
                                        
                                    }
                            
                            var jsonElement = NSDictionary()
                           // let persons = NSMutableArray()
                            //var lft_array: [String] = []
                           
                            //print(jsonResult)
                            for i in 0 ..< jsonResult.count{
                                DispatchQueue.main.async{
                                jsonElement = jsonResult[i] as! NSDictionary
                                print("the recommended interest id is")
                               // print(jsonElement["recommended_interest_id"])
                                
                                if let recommended_interest_id = (jsonElement["recommended_interest_id"] as AnyObject).doubleValue
                                   {
                                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                        return
                                    }
                                    // 1: Getting hands on NSManagedObjectContext
                                    let managedContext = appDelegate.persistentContainer.viewContext
                                    
                                    // 2: Creating new managed object and inserting into managed object contextt]
                                    var selected_interest: [NSManagedObject] = []
                                    
                                    
                                    
                                    var indexes_temp: [NSManagedObject] = []
                                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
                                    fetchRequest.predicate = NSPredicate(format: "id == %d", (recommended_interest_id as! NSNumber).intValue)
                                    do {
                                        indexes_temp = try managedContext.fetch(fetchRequest)
                                 
                                    } catch let error as NSError {
                                        print("Could not fetch. \(error), \(error.userInfo)")
                                    }
                                    
                                 //   print("setting \(indexes_temp[0]) to recommended = true in ViewController")
                                    indexes_temp[0].setValue(true, forKeyPath: "recommended")
                                    

                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                    //user_lft_ids.append(Int(lft_id))
                                
                                }
                                }
                            }
    
                       
                        }
                        //group.leave() -> did this change anything
                    }
                    
                        uploadJob.resume()
                  //  group.leave()
                }
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
      }
}
    
    func addOrRemoveInterestToday() -> UIAction {
      // 3
      //  lft_todayself.lft_today.text
        
        var lft_today_desc = self.lft_today.text
        lft_today_desc = String(lft_today_desc!.dropFirst(23))
        var _title = ""
        var _image: UIImage = UIImage()
        
        DispatchQueue.main.async{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        var user_interests: [NSManagedObject] = []
            var _user_interests: [NSManagedObject] = []
  
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
        fetchRequest.predicate = NSPredicate(format: "desc == %@", lft_today_desc!)
        do {
            _user_interests = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
            let interest_id = (_user_interests[0].value(forKey: "interest_id") as AnyObject).doubleValue
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Interest")
            fetchRequest2.predicate = NSPredicate(format: "id == %d", Int(interest_id!))
            do {
                user_interests = try managedContext.fetch(fetchRequest2)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if(!(user_interests[0].value(forKey: "user_added") as AnyObject).boolValue){
                _image = UIImage(systemName: "plus")!
                _title = "Add"
                print("add this to my interests")
            }
            else{
                _image = UIImage(systemName: "delete.left")!
                _title = "Remove"
                print("remove this from my interests")
            }
        }
      // 4
      return UIAction(
      //  title: _title,
      //  image: _image,
        title: "Add or remove interest",
        image: UIImage(systemName: "delete.left"),
        identifier: nil) { _ in
        //  self.currentUserRating = 0
        var lft_today_desc = self.lft_today.text
        lft_today_desc = String(lft_today_desc!.dropFirst(23))
// MARK: User Id here
        let user_id = self.get_user_id()
        let user_hash = self.get_user_hash()
        
        DispatchQueue.main.async{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        var _user_interests: [NSManagedObject] = []
        var user_interests: [NSManagedObject] = []
  
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
        fetchRequest.predicate = NSPredicate(format: "desc == %@", lft_today_desc!)
        do {
            _user_interests = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
            
            let interest_id = (_user_interests[0].value(forKey: "interest_id") as AnyObject).doubleValue
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Interest")
            fetchRequest2.predicate = NSPredicate(format: "id == %d", Int(interest_id!))
            do {
                user_interests = try managedContext.fetch(fetchRequest2)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            
            if((user_interests[0].value(forKey: "user_added") as? Bool)!){
              // remove as interest, need to remember to upload to server as well
                
                user_interests[0].setValue(false, forKey: "user_added")
                
                let string_selected_interest_id = (user_interests[0].value(forKey: "id") as AnyObject).doubleValue
                let url3 = NSURL(string: "https://www.sunrisesapp.com/remove_user_interest.php")
                var request = URLRequest(url: url3! as URL)
                request.httpMethod = "POST"
                var dataString = "user_id=" + String(user_id) + "&interest_id=" + String(string_selected_interest_id!) + "&user_hash=" + user_hash
              //  print("dataString is \(dataString)")
                let dataD = dataString.data(using: .utf8)
                do {
                    let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD){
                        data, response, error in
                        if error != nil {
                            print(error)
                        }
                        else {
                            var jsonResult = NSArray()
                            do{
                                jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                        
                                    } catch let error as NSError {
                                        print(error)
                                        
                                    }

                       
                        }
                    }
                    
                        uploadJob.resume()
                }
            }
            else{
               // add as interest
                user_interests[0].setValue(true, forKey: "user_added")
                let string_selected_interest_id = (user_interests[0].value(forKey: "id") as AnyObject).doubleValue
                let test = user_interests[0].value(forKey: "id")
            //    print("user_interests[0].value is \(test)")
            //    print("string_selected_interest_id  is \(string_selected_interest_id)")
                
                let url4 = NSURL(string: "https://www.sunrisesapp.com/update_user_interests.php")
                var request4 = URLRequest(url: url4! as URL)
                request4.httpMethod = "POST"
                let dataString2 = "user_id=" + String(user_id) + "&interest_id=" + String(string_selected_interest_id!) + "&user_hash=" + user_hash
                
                let dataD2 = dataString2.data(using: .utf8)
                do {
                    let uploadJob2 = URLSession.shared.uploadTask(with: request4, from: dataD2){
                        data, response, error in
                        if error != nil {
                            print(error)
                        }
                        else {
                            print("no error!")
                        }

                    }
                    
                        uploadJob2.resume()
                    }
                
                let url3 = NSURL(string: "https://www.sunrisesapp.com/get_recommended_interests.php")
                var request = URLRequest(url: url3! as URL)
                request.httpMethod = "POST"
                var dataString = "interest_id=" + String(string_selected_interest_id!)
              //  print("dataString is \(dataString)")
                let dataD = dataString.data(using: .utf8)
                do {
                    let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD){
                        data, response, error in
                        if error != nil {
                            print(error)
                        }
                        else {
                            var jsonResult = NSArray()
                            do{
                                jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                        
                                    } catch let error as NSError {
                                        print(error)
                                        
                                    }
                            
                            var jsonElement = NSDictionary()
                           // let persons = NSMutableArray()
                            //var lft_array: [String] = []
                           
                            //print(jsonResult)
                            for i in 0 ..< jsonResult.count{
                                DispatchQueue.main.async{
                                jsonElement = jsonResult[i] as! NSDictionary
                             //   print("the recommended interest id is")
                             //   print(jsonElement["recommended_interest_id"])
                                
                                if let recommended_interest_id = (jsonElement["recommended_interest_id"] as AnyObject).doubleValue
                                   {
                                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                        return
                                    }
                                    // 1: Getting hands on NSManagedObjectContext
                                    let managedContext = appDelegate.persistentContainer.viewContext
                                    
                                    // 2: Creating new managed object and inserting into managed object contextt]
                                    var selected_interest: [NSManagedObject] = []
                                    
                                    
                                    
                                    var indexes_temp: [NSManagedObject] = []
                                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
                                    fetchRequest.predicate = NSPredicate(format: "id == %d", (recommended_interest_id as! NSNumber).intValue)
                                    do {
                                        indexes_temp = try managedContext.fetch(fetchRequest)
                                 
                                    } catch let error as NSError {
                                        print("Could not fetch. \(error), \(error.userInfo)")
                                    }
                                    
                                   // print("setting \(indexes_temp[0]) to recommended = true in ViewController")
                                    indexes_temp[0].setValue(true, forKeyPath: "recommended")
                                    

                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                    //user_lft_ids.append(Int(lft_id))
                                
                                }
                                }
                            }
    
                       
                        }
                        //group.leave() -> did this change anything
                    }
                    
                        uploadJob.resume()
                  //  group.leave()
                }
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
      }
}
    
    func makeRatePreview() -> UIViewController {
      let viewController = UIViewController()
        viewController.view.backgroundColor = .red
      
      // 1
     // let imageView = UIImageView(image: UIImage(named: "rating_star"))
     // viewController.view = imageView
      
      // 2
     // imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
     // imageView.translatesAutoresizingMaskIntoConstraints = false
      
      // 3
     // viewController.preferredContentSize = imageView.frame.size
      
      return viewController
    }
}

extension Notification.Name {
    static let updateDateVCReceived = Notification.Name("uk.co.company.app.updateDateVCReceived")
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

