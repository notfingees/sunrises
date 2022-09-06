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
class InterestsSettingsRemoveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    
    var searchController: UISearchController!
    @IBOutlet weak var back: UILabel!
    @IBOutlet weak var searchControllerView: UIView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var categoriesTable: UITableView!
    @IBOutlet weak var searchBarView: UIView!
   // @IBOutlet weak var doneLabel: UILabel!
    let cellReuseIdentifier = "categorycell"
    let cellSpacingHeight: CGFloat = 17
    
   // var category = ""
    var allInterests: [NSManagedObject] = []
    var recommendedInterests: [NSManagedObject] = []
    var searchInterests: [NSManagedObject] = []

    var done: Bool = false
    
    override open var shouldAutorotate: Bool {
            return false
        }

    
    // SEARCH CONTROLLER
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        interestsSearch(searchText: searchBar.text!)
        
        
        self.categoriesTable.reloadData()

      }
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    @objc func goBack(sender: UITapGestureRecognizer){
        dismiss(animated: true)
    }
    @objc func isDone(sender: UITapGestureRecognizer){
        self.done = true
        dismiss(animated: true)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if isFiltering{
            super.dismiss(animated: flag, completion: completion)
        }
        else{
            super.dismiss(animated: flag, completion: completion)
        }
        
            super.dismiss(animated: flag, completion: completion)
        
            NotificationCenter.default.post(name: Notification.Name.backToInterestsSettingsReceived, object: nil)
        
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(backTap)
        /*
        let doneTap = UITapGestureRecognizer(target: self, action: #selector(self.isDone))
        doneLabel.isUserInteractionEnabled = true
        doneLabel.addGestureRecognizer(doneTap)
        */
    
        searchController = UISearchController(searchResultsController: nil)
        self.view.addSubview(searchController.searchBar)
        searchController.searchBar.backgroundImage = UIImage()
        var sbTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        sbTextField!.textColor = .white
        
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        
        searchController.searchBar.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 17).isActive = true
        //searchController.searchBar.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 100).isActive = true
        searchController.searchBar.topAnchor.constraint(equalTo: margins.topAnchor, constant: 59.5).isActive = true
        //searchController.searchBar.widthAnchor.constraint(equalToConstant: self.view.frame.width-34).isActive = true
        searchController.searchBar.widthAnchor.constraint(equalToConstant: self.view.frame.width-68).isActive = true
 
        self.definesPresentationContext = true
        
        searchController.searchBar.isTranslucent = true
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
 
        searchController.searchBar.placeholder = "Search any interest"
        searchController.searchBar.delegate = self
        
       // self.searchBarView.insertSubview(searchController.searchBar, at: 10)
       // searchBarView.isUserInteractionEnabled = true

        
        //searchController.delegate = self
        //searchController.searchBar.delegate = self
        //self.definesPresentationContext = true
        
    //    category = self.category.lowercased()
        categoriesTable.rowHeight = UITableView.automaticDimension
        categoriesTable.estimatedRowHeight = 34
        
        DispatchQueue.main.async{
            self.recommendedInterests = self.getAllInterests()
        }
        
        
    }
    
    func getAllInterests() -> [NSManagedObject]{
        var _recommendedInterests: [NSManagedObject] = []
        var _allInterests: [NSManagedObject] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return []
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        

            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
            fetchRequest.predicate = NSPredicate(format: "user_added == true")
            // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
            do {
                _allInterests = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            
            
            
        
        
/*
        
        _recommendedInterests = _recommendedInterests + _allInterests
        _recommendedInterests = _recommendedInterests.uniquesInterest
        print("recommended_interests in isdsvc is \(_recommendedInterests)")
        return _recommendedInterests
 */
        return _allInterests
    }
    
    
    func interestsSearch(searchText: String = ""){

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
     
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
        
            let predicate1 = NSPredicate(format: "desc CONTAINS[c] %@ OR name CONTAINS[c] %@", searchText, searchText)
 
        let predicate2 = NSPredicate(format: "user_added == true")
    
    fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
           
                // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
                do {
                    searchInterests = try managedContext.fetch(fetchRequest)
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
        
        
    }
   
 
    func numberOfSections(in tableView: UITableView) -> Int {
            if isFiltering {
                return searchInterests.count
            }
            else{
            return recommendedInterests.count
        }
        
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
            // need to make new cell
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DetailSearchTableViewCell
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate!.persistentContainer.viewContext
            
            // 2: Fetching the data -> NSFetchRequest is very flexible
                let interest: NSManagedObject
                if isFiltering {
                    interest = searchInterests[indexPath.section]
                }
                else {
                    interest = recommendedInterests[indexPath.section]
                }
             
                cell.cellCategory.text = interest.value(forKeyPath: "name") as? String
                cell.cellDescription.text = interest.value(forKeyPath: "desc") as? String
            if ((interest.value(forKeyPath: "user_added") as? Bool)!){
                cell.addOrRemoveButton.setTitle("-", for: .normal)
                cell.cellCategory.textColor = .white
                cell.cellDescription.textColor = .white
            }
            else {
                cell.addOrRemoveButton.setTitle("+", for: .normal)
                cell.cellCategory.textColor = .white
                cell.cellDescription.textColor = .white
            }
            
            if cell.addOrRemoveButton.state == .disabled{
                cell.addOrRemoveButton.tintColor = .white
            }
    
            
            
           
            
            // add border and color
            cell.backgroundColor = UIColor(white: 1, alpha: 0.125)

            cell.layer.cornerRadius = 8
 
            cell.clipsToBounds = true
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(white: 1, alpha: 0.625)
            cell.selectedBackgroundView = backgroundView
         
            return cell
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

        
        // method to run when table view cell is tapped
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // note that indexPath.section is used rather than indexPath.row
            //print("You tapped cell number \(indexPath.section).")
            let group = DispatchGroup()
            var selected_interest: NSManagedObject
            if isFiltering {
                selected_interest = searchInterests[indexPath.section]
            }
            else {
                selected_interest = recommendedInterests[indexPath.section]
            }
            
            
            
            var selected_interest_id = selected_interest.value(forKeyPath: "id") as! NSNumber
            
            DispatchQueue.main.async{
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            // 1: Getting hands on NSManagedObjectContext
            let managedContext = appDelegate.persistentContainer.viewContext
            
            // 2: Creating new managed object and inserting into managed object contextt]
            var selected_interest: [NSManagedObject] = []
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Interest")
            fetchRequest2.predicate = NSPredicate(format: "id == %d", (selected_interest_id).intValue)
            do {
                selected_interest = try managedContext.fetch(fetchRequest2)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
                
             
                    selected_interest[0].setValue(false, forKeyPath: "user_added")
                    print("setting user added in \(selected_interest[0]) to false")
                        do {
                            try managedContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                let interest_name = selected_interest[0].value(forKey: "name") as? String
                let interest_added = selected_interest[0].value(forKey: "user_added") as? Bool
                print("\(interest_name) is now \(interest_added)")
                    return
            }
            
            
          //  group.enter()
            // MARK: - NEED A USER ID HERE
            let user_id = self.get_user_id()
            let user_hash = self.get_user_hash()
            let string_selected_interest_id = selected_interest_id.stringValue
            let url3 = NSURL(string: "https://www.sunrisesapp.com/remove_user_interest.php")
            var request = URLRequest(url: url3! as URL)
            request.httpMethod = "POST"
            var dataString = "user_id=" + String(user_id) + "&interest_id=" + string_selected_interest_id + "&user_hash=" + user_hash
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
                        
                    
                        
                     //   group.leave()
                   
                    }
                    //group.leave() -> did this change anything
                }
                
                    uploadJob.resume()
              //  group.leave()
            }
            
            
            
            DispatchQueue.main.async{
              //  group.enter()
            self.recommendedInterests = self.getAllInterests()
            //    group.leave()
             //   group.wait()
            }
           // group.wait()
          
                DispatchQueue.main.async{
            //tableView.reloadData()
                    UIView.transition(with: self.categoriesTable, duration: 1.0, options: .transitionCrossDissolve, animations: {self.categoriesTable.reloadData()}, completion: nil)
                    //group.leave()
                }
            
            
            
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

