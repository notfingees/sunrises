//
//  SettingsViewController.swift
//  aurora
//
//  Created by justin on 2/17/21.
//

import UIKit
import SafariServices
import CryptoKit


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categoriesTable: UITableView!
    @IBOutlet weak var settingsLabel: UILabel!
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    let cellReuseIdentifier = "settingscell"
   //     let cellSpacingHeight: CGFloat = 17
    /*
    var settings = ["Notifications", "Interests/Content Settings", "Account", "Premium", "Help", "About", "Suggestions", "Business"]
    var settings_images = ["Everything to look forward to today and tomorrow!",
        "From movies and TV shows to Twitch streams and videos",
        "New games, updates and content about your favorite games, events, and more",
        "Sales, releases, and restocks from your favorite brands",
        "New releases, concerts, and more from your favorite artists",
        "Games, drafts, and other events from your favorite teams",
        "News related to your life, interests and hobbies",
        "Holidays, global good news, and more",
        "Good weather, local events, and more"
    ]
 */
    var settings = ["Notifications", "Interests/Content Settings", "Account", "Help", "About", "Suggestions", "Business"]

    
    var backToSettingsReceivedObserver: NSObjectProtocol?
    var userLoggedOutReceivedObserver: NSObjectProtocol?
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    
 
    override func viewWillAppear(_ animated: Bool){
        backToSettingsReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.backToSettingsReceived, object: nil, queue: nil, using: { (notification) in
                    DispatchQueue.main.async { // because the notification won't be received on the main queue and you want to update the UI which must be done on the main queue.
                        self.categoriesTable.isHidden = false
                        self.settingsLabel.isHidden = false
                        self.tabBarController!.tabBar.isHidden = false
                    }
                })
        userLoggedOutReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.userLoggedOutReceived, object: nil, queue: nil, using: { (notification) in
                    DispatchQueue.main.async { // because the notification won't be received on the main queue and you want to update the UI which must be done on the main queue.
                        print("in userJustLoggedOut")
                        
                        self.categoriesTable.isHidden = true
                        self.settingsLabel.isHidden = true
                        
                        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let vc  = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                        let searchvc  = mainStoryboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
                        let launchscreenvc  = mainStoryboard.instantiateViewController(withIdentifier: "Launchscreen") as! LaunchscreenViewController
                        let onboarding1vc  = mainStoryboard.instantiateViewController(withIdentifier: "Onboarding1ViewController") as! Onboarding1ViewController
                        let interestssearchvc  = mainStoryboard.instantiateViewController(withIdentifier: "InterestsSearchViewController") as! InterestsSearchViewController
                        let loginloadingvc  = mainStoryboard.instantiateViewController(withIdentifier: "LoginLoadingViewController") as! LoginLoadingViewController
                        let settingsvc  = mainStoryboard.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
                        /*
                        let vc = ViewController()
                        let searchvc = SearchViewController()
                        let launchscreenvc = LaunchscreenViewController()
                        let onboarding1vc = Onboarding1ViewController()
                        let interestssearchvc = InterestsSearchViewController()
                        let loginloadingvc = LoginLoadingViewController()
                        let settingsvc = SettingsViewController()
                        */
                        let tabbarvc = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                       // var vcs = self.tabBarController!.viewControllers
                       // vcs!.append(signUpView)
                        var vcs = [vc, searchvc, launchscreenvc, onboarding1vc, interestssearchvc, loginloadingvc, settingsvc]
                        print("self.tabbarcontroller is \(self.tabBarController)")
                        print("before: \(self.tabBarController!.viewControllers)")
                        DispatchQueue.main.async{
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                            return
                        }
                        let managedContext = appDelegate.persistentContainer.viewContext
                        
                            managedContext.deleteAllData()
                            
                            

                        }
                     //   self.tabBarController!.setViewControllers(vcs, animated: false)
                        //print("after: \(self.tabBarController!.viewControllers)")
                        //self.tabBarController!.selectedIndex = 3
                        DispatchQueue.main.async{
                            UIApplication.shared.windows.first?.rootViewController = tabbarvc
                            UIApplication.shared.windows.first?.makeKeyAndVisible()
                        }
                        
                        
                    }
                })
        
        
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in view did load of settings")
        categoriesTable.delegate = self
        categoriesTable.dataSource = self
    }
  
     func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }


        // There is just one row in every section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("returning \(settings.count) for settings.count")
            return settings.count
        }
        
        // create a cell for each table view row
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cellIdentifier = "settingscell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SettingsTableViewCell
            // Configure the cell...
            cell.settingsDescription.text = settings[indexPath.row]
            cell.backgroundColor = UIColor(white: 1, alpha: 0)
            cell.clipsToBounds = true
         
            return cell
        }
        
        // method to run when table view cell is tapped
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // note that indexPath.section is used rather than indexPath.row
          //  print("You tapped cell number \(indexPath.section).")
            tableView.deselectRow(at: indexPath, animated: true)
            
            if settings[indexPath.row] == "Notifications"{
                
                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "NotificationSettings") as! NotificationSettingsViewController

                let vc = signUpView
                presentTransition = RightToLeftTransition()
                dismissTransition = LeftToRightTransition()

                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self

                present(vc, animated: true, completion: { [weak self] in
                    self?.presentTransition = nil
                })
                
                self.categoriesTable.isHidden = true
                self.settingsLabel.isHidden = true
                self.tabBarController!.tabBar.isHidden = true
                
                
            }
            
            else if settings[indexPath.row] == "Interests/Content Settings"{
                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "InterestsSettings") as! InterestsSettingsViewController

                let vc = signUpView
                presentTransition = RightToLeftTransition()
                dismissTransition = LeftToRightTransition()

                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self

                present(vc, animated: true, completion: { [weak self] in
                    self?.presentTransition = nil
                })
                
                self.categoriesTable.isHidden = true
                self.settingsLabel.isHidden = true
                self.tabBarController!.tabBar.isHidden = true
            }
            
            else if settings[indexPath.row] == "Account"{
                
                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "AccountSettings") as! AccountSettingsViewController

                let vc = signUpView
                presentTransition = RightToLeftTransition()
                dismissTransition = LeftToRightTransition()

                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self

                present(vc, animated: true, completion: { [weak self] in
                    self?.presentTransition = nil
                })
                
                self.categoriesTable.isHidden = true
                self.settingsLabel.isHidden = true
                self.tabBarController!.tabBar.isHidden = true
                
                
            }
            /*
            else if settings[indexPath.row] == "Premium"{
                
                let alert = UIAlertController(title: "Thanks", message: "Thanks for downloading Sunrises! We're giving all our new users a year of free premium and we hope you have a nice day!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Thanks!", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            else if settings[indexPath.row] == "Help"{
                let alert = UIAlertController(title: "Help", message: "Thanks for downloading Sunrises! Swipe left and right to see everything you have to look forward to, up and down to switch between todays items and tomorrows items, and press and hold to send an item to someone else!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok!", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
 */
            
            else if settings[indexPath.row] == "About"{
                
                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController

                let vc = signUpView
                presentTransition = RightToLeftTransition()
                dismissTransition = LeftToRightTransition()

                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self

                present(vc, animated: true, completion: { [weak self] in
                    self?.presentTransition = nil
                })
                
                self.categoriesTable.isHidden = true
                self.settingsLabel.isHidden = true
                self.tabBarController!.tabBar.isHidden = true
                
                
            }
            
            else if settings[indexPath.row] == "Suggestions"{
                showSuggestion()
            }
            else if settings[indexPath.row] == "Business"{
                showBusiness()
            }
            
        }
    
    func showSuggestion() {
        if let url = URL(string: "https://www.sunrisesapp.com/contact.php") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    func showBusiness() {
        if let url = URL(string: "https://www.sunrisesapp.com/business.php") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
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
    
 /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchdetail" {
            if let indexPath = categoriesTable.indexPathForSelectedRow {
        
                let destinationController = segue.destination as! DetailSearchViewController
               
                destinationController.category = self.settings[indexPath.section]
                self.categoriesTable.isHidden = true
            }
        }
        print("in the prepare function")
 
    }
 */
 
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
    static let backToSettingsReceived = Notification.Name("uk.co.company.app.backToSettingsReceived")
    static let userLoggedOutReceived = Notification.Name("uk.co.company.app.userLoggedOutReceived")
}

extension SettingsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
