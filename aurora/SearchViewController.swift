//
//  SearchViewController.swift
//  aurora
//
//  Created by justin on 2/2/21.
//

import UIKit

//class SearchViewController: SkyBackgroundViewController, UITableViewDelegate, UITableViewDataSource {
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categoriesTable: UITableView!
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
    var dsvcBackObserver: NSObjectProtocol?
    override func viewWillAppear(_ animated: Bool){
        dsvcBackObserver = NotificationCenter.default.addObserver(forName: Notification.Name.dsvcBack, object: nil, queue: nil, using: { (notification) in
                    DispatchQueue.main.async { // because the notification won't be received on the main queue and you want to update the UI which must be done on the main queue.
                        self.categoriesTable.isHidden = false
                        self.tabBarController!.tabBar.isHidden = false
                        
                        
                    }
                })
    }
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        // Do any additional setup after loading the view.
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
    /*
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      
        cell.backgroundColor = UIColor.red
        cell.layer.backgroundColor = UIColor.red.cgColor
        cell.layer.isOpaque = false
        cell.isOpaque = false
        cell.alpha = 0.2
        cell.layer.opacity = 0.2
    }
 */
        // create a cell for each table view row
    

    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cellIdentifier = "categorycell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchTableViewCell
            // Configure the cell...
            cell.cellCategory.text = categories[indexPath.section]
            
            cell.cellDescription.numberOfLines = 0
            cell.cellDescription.text = descriptions[indexPath.section]
            cell.cellDescription.baselineAdjustment = .none
            
            cell.cellIcon.image = UIImage(named: icons[indexPath.section])
 
            
            // add border and color
            cell.backgroundColor = UIColor(white: 1, alpha: 0.125)
            /*
            cell.backgroundColor = UIColor.red
            cell.layer.backgroundColor = UIColor.red.cgColor
            cell.layer.isOpaque = false
            cell.isOpaque = false
            cell.alpha = 0.2
            cell.layer.opacity = 0.2
 */

        //    cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 8
 
            cell.clipsToBounds = true
            
          //  cell.selectionStyle = .none
            
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
    
    /*
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "categorycell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchTableViewCell
        // Configure the cell...
        cell.cellCategory.text = categories[indexPath.row]
        cell.cellDescription.numberOfLines = 0
        cell.cellDescription.text = descriptions[indexPath.row]
        return cell
    }
 */
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 127.5;//Choose your custom row height
        
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchdetail" {
            if let indexPath = categoriesTable.indexPathForSelectedRow {
        
                let destinationController = segue.destination as! DetailSearchViewController
               
                destinationController.category = self.categories[indexPath.section]
                self.categoriesTable.isHidden = true
                self.tabBarController!.tabBar.isHidden = true
            }
        }
        print("in the prepare function")
 
    }
 
    /*    if segue.identifier == "showCategoryLFT" {
            if let indexPath = tableView(didSelect) {
    let destinationController = segue.destination as! SearchDetailViewController
    destinationController.category = self.categories[indexPath.section]
        }
    }
 */

 
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}

extension Notification.Name {
    static let dsvcBack = Notification.Name("uk.co.company.app.dsvcBack")
}
