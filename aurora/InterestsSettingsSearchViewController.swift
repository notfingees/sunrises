//
//  SearchViewController.swift
//  aurora
//
//  Created by justin on 2/2/21.
//

import UIKit
import CoreData
import CryptoKit

var already_added_interest_ids: [Double] = []
//class SearchViewController: SkyBackgroundViewController, UITableViewDelegate, UITableViewDataSource {
class InterestsSettingsSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categoriesTable: UITableView!
  //  @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var back: UILabel!
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    let cellReuseIdentifier = "categorycell"
        let cellSpacingHeight: CGFloat = 17
    
    var categories = ["All", "Entertainment", "Gaming", "Shopping", "Music", "Sports", "Personal", "Global", "Local"]
    var descriptions = ["Everything to look forward to today and tomorrow!",
        "From movies and TV shows to Twitch streams and videos",
        "New games, updates and content about your favorite games, events, and more",
        "Sales, releases, and restocks from your favorite brands",
        "New releases, concerts, and more from your favorite artists",
        "Games, drafts, and other events from your favorite teams",
        "News related to your life, interests and hobbies",
        "Holidays, global good news, and more",
        "Good weather, local events, and more"]
    
    var icons = ["all.png", "entertainment.png", "gaming.png", "shopping.png", "music.png", "sports.png", "personal.png", "global.png", "local.png"]
    
    
    
    var isvcBackObserver: NSObjectProtocol?
    var interestsDoneObserver: NSObjectProtocol?
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag, completion: completion)
        
            NotificationCenter.default.post(name: Notification.Name.backToInterestsSettingsReceived, object: nil)
        
        }
    override func viewWillAppear(_ animated: Bool){
        

        isvcBackObserver = NotificationCenter.default.addObserver(forName: Notification.Name.isvcBack, object: nil, queue: nil, using: { (notification) in
                    DispatchQueue.main.async { // because the notification won't be received on the main queue and you want to update the UI which must be done on the main queue.
                        self.categoriesTable.isHidden = false
                        self.back.isHidden = false
                    }
                })
        interestsDoneObserver = NotificationCenter.default.addObserver(forName: Notification.Name.interestsDone, object: nil, queue: nil, using: { (notification) in
            print("in interests Done Observer")
            let group = DispatchGroup()
 
            //MARK: - Uploading interests (need to get user ID)
            let user_id = self.get_user_id()
            let user_hash = self.get_user_hash()


            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{

                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext

                var indexes_temp: [NSManagedObject] = []
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
              //  fetchRequest.predicate = NSPredicate(format: "id == %ld", Int(interest_id))
                fetchRequest.predicate = NSPredicate(format: "user_added == true")
                do {
 
                    indexes_temp = try managedContext.fetch(fetchRequest)

             
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
            
            var new_interests: [Double] = []
            for i in indexes_temp{
                let ni_id = (i.value(forKey: "id") as AnyObject).doubleValue
                new_interests.append(ni_id!)
            }
            let temp_set = Set(already_added_interest_ids)
            new_interests = new_interests.filter { !temp_set.contains($0) }
                
            //    print("indexes temp is \(indexes_temp)")
                if indexes_temp.count > 0{
                    for i in new_interests{
                    let interest_id = String(i)
                    let url4 = NSURL(string: "https://www.sunrisesapp.com/update_user_interests.php")
                    var request4 = URLRequest(url: url4! as URL)
                    request4.httpMethod = "POST"
                        let dataString2 = "user_id=" + String(user_id) + "&interest_id=" + interest_id + "&user_hash=" + user_hash
                    
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
                    }
                }
                else {
                    // MARK: - DISPLAY ALERT saying ' you have no interests added, are you sure you would liek to proceed'
                }

            
 

            //MARK: - Generating relevant lfts
            /*
            group.enter()
         //   DispatchQueue.main.async{
                print("about to generate lfts")
                self.generate_lfts()
                group.leave()
          //  }
 */
            
            


            group.wait()
            group.enter()
            print("about to redirect")
      //      var vcs = self.tabBarController!.viewControllers
        //    vcs!.remove(at: 3)
          //  self.tabBarController!.viewControllers = vcs
            
            self.dismissTransition = LeftToRightTransition()
            self.dismiss(animated: true)
            group.leave()
             
            })
    }
    
    @objc func isDone(sender: UITapGestureRecognizer){
        NotificationCenter.default.post(name: Notification.Name.interestsDone, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneTap = UITapGestureRecognizer(target: self, action: #selector(self.isDone))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(doneTap)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
            var indexes_temp: [NSManagedObject] = []
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
          //  fetchRequest.predicate = NSPredicate(format: "id == %ld", Int(interest_id))
            fetchRequest.predicate = NSPredicate(format: "user_added == true")
            do {
                indexes_temp = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        for i in indexes_temp{
            var interest_id = ((i.value(forKey: "id") as AnyObject).doubleValue)
            already_added_interest_ids.append(interest_id!)
        }
        
    }
  
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return self.categories.count
        }
        
        // There is just one row in every section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        // Set the spacing between sections
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return cellSpacingHeight
        }
        
        // Make the background color show through
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.clear
            return headerView
        }

        // create a cell for each table view row
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cellIdentifier = "categorycell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchTableViewCell
            // Configure the cell...
            cell.cellCategory.text = categories[indexPath.section]
            
            cell.cellIcon.image = UIImage(named: icons[indexPath.section])
            cell.cellDescription.numberOfLines = 0
            cell.cellDescription.text = descriptions[indexPath.section]
            cell.cellDescription.baselineAdjustment = .none
 
            cell.backgroundColor = UIColor(white: 1, alpha: 0.125)

            cell.layer.cornerRadius = 8
 
            cell.clipsToBounds = true
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(white: 1, alpha: 0.625)
            cell.selectedBackgroundView = backgroundView
         
            return cell
        }
        
        // method to run when table view cell is tapped
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // note that indexPath.section is used rather than indexPath.row
          //  print("You tapped cell number \(indexPath.section).")
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 127.5;//Choose your custom row height
        
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "interestssettingssegue" {
            if let indexPath = categoriesTable.indexPathForSelectedRow {
        
                let destinationController = segue.destination as! InterestsSettingsDetailSearchViewController
               
                destinationController.category = self.categories[indexPath.section]
                self.categoriesTable.isHidden = true
                self.back.isHidden = true
            }
        }
        print("in the prepare function")
 
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
       
    
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
    
       

       
    
       
       
    
    


}

extension Notification.Name {
    static let isvcSettingsBack = Notification.Name("uk.co.company.app.isvcBack")
}

extension Notification.Name {
    static let interestsSettingsDone = Notification.Name("uk.co.company.app.interestsDone")
}

extension InterestsSettingsSearchViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
