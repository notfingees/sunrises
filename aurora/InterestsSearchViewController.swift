//
//  SearchViewController.swift
//  aurora
//
//  Created by justin on 2/2/21.
//

import UIKit
import CoreData
import CryptoKit

//class SearchViewController: SkyBackgroundViewController, UITableViewDelegate, UITableViewDataSource {
class InterestsSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categoriesTable: UITableView!
    @IBOutlet weak var doneLabel: UILabel!
    let cellReuseIdentifier = "categorycell"
        let cellSpacingHeight: CGFloat = 17
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
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
 
    /*
    var categories = ["All", "Marvel's Loki", "Minecraft", "Adidas", "Drake", "New England Patriots", "You!", "Uplifting News", "Weather"]
    var descriptions = ["Everything to look forward to today and tomorrow!",
    "New episodes, actor news, and everything else related to Marvel's new TV show 'Loki'",
    "New updates and snapshots from Minecraft as well as big community events such as Minecraft Live and MMC",
    "Shoe drops, sales, and more from fashion and sportswear retailer Adidas",
    "Album and single drops and news related to hip hop artist Drake",
    "Games, player news and updates, and more about the New England Patriots",
    "Birthdays, parties, and everything else your personal life has to look forward to!",
    "Uplifting news around the world",
    "80 degrees and sunny all day today!"
    ]
 */
    var icons = ["all.png", "entertainment.png", "gaming.png", "shopping.png", "music.png", "sports.png", "personal.png", "global.png", "local.png"]
    
    var isvcBackObserver: NSObjectProtocol?
    var interestsDoneObserver: NSObjectProtocol?
    override func viewWillAppear(_ animated: Bool){
        isvcBackObserver = NotificationCenter.default.addObserver(forName: Notification.Name.isvcBack, object: nil, queue: nil, using: { (notification) in
                    DispatchQueue.main.async { // because the notification won't be received on the main queue and you want to update the UI which must be done on the main queue.
                        self.categoriesTable.isHidden = false
                        self.doneLabel.isHidden = false
                        self.tabBarController?.tabBar.isHidden = true
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
                
            //    print("indexes temp is \(indexes_temp)")
                if indexes_temp.count > 0{
                    for i in indexes_temp{
                    let interest_id = (i.value(forKey: "id") as AnyObject).stringValue
                    let url4 = NSURL(string: "https://www.sunrisesapp.com/update_user_interests.php")
                    var request4 = URLRequest(url: url4! as URL)
                    request4.httpMethod = "POST"
                    let dataString2 = "user_id=" + String(user_id) + "&interest_id=" + interest_id! + "&user_hash=" + user_hash
                    
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
            group.enter()
         //   DispatchQueue.main.async{
                print("about to generate lfts")
                self.generate_lfts()
            self.updateCurrentUpdatedDate()
                group.leave()
          //  }
            
            


            group.wait()
            group.enter()
            print("about to redirect")
      //      var vcs = self.tabBarController!.viewControllers
        //    vcs!.remove(at: 3)
          //  self.tabBarController!.viewControllers = vcs
            
            // CRASHES HERE FUCK MY ASS
            self.tabBarController!.selectedIndex = 0
            group.leave()
             
            })
    }
    
    
    @objc func isDone(sender: UITapGestureRecognizer){
        NotificationCenter.default.post(name: Notification.Name.interestsDone, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneTap = UITapGestureRecognizer(target: self, action: #selector(self.isDone))
        doneLabel.isUserInteractionEnabled = true
        doneLabel.addGestureRecognizer(doneTap)
        
       // self.tabBarController?.tabBar.isHidden = true
        

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
        if segue.identifier == "interestsegue" {
            if let indexPath = categoriesTable.indexPathForSelectedRow {
        
                let destinationController = segue.destination as! InterestsDetailSearchViewController
               
                destinationController.category = self.categories[indexPath.section]
                self.categoriesTable.isHidden = true
                self.doneLabel.isHidden = true
                self.tabBarController!.tabBar.isHidden = true
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
    static let isvcBack = Notification.Name("uk.co.company.app.isvcBack")
}
extension Notification.Name {
    static let interestsDone = Notification.Name("uk.co.company.app.interestsDone")
}

extension Array where Element: Hashable {
    var uniqueArray: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}

