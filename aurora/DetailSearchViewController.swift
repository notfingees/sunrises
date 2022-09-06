//
//  SearchViewController.swift
//  aurora
//
//  Created by justin on 2/2/21.
//

import UIKit
import CoreData

//class SearchViewController: SkyBackgroundViewController, UITableViewDelegate, UITableViewDataSource {
class DetailSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    
    var searchController: UISearchController!
    @IBOutlet weak var back: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchControllerView: UIView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var categoriesTable: UITableView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var todayOrTomorrowLabel: UILabel!
    let cellReuseIdentifier = "categorycell"
    let cellSpacingHeight: CGFloat = 17
    
    var category = ""
    var lftsToday: [NSManagedObject] = []
    var lftsTomorrow: [NSManagedObject] = []
    var userLftsToday: [NSManagedObject] = []
    var userLftsTomorrow: [NSManagedObject] = []
    var filteredLftsToday: [NSManagedObject] = []
    var filteredLftsTomorrow: [NSManagedObject] = []
    
    // SEGMENTED CONTROL
    var whichSegmentedControl = 0
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        if whichSegmentedControl == 0{
            whichSegmentedControl = 1
            todayOrTomorrowLabel.text = "Tomorrow, look forward to..."
        }
        else{
            whichSegmentedControl = 0
            todayOrTomorrowLabel.text = "Today, look forward to..."
        }
        self.categoriesTable.reloadData()
    }
    
    func setupSegmentedControl() {
        // Configure Segmented Control
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Today", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Tomorrow", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)

        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
    }
    
    // SEARCH CONTROLLER
    
    func updateSearchResults(for searchController: UISearchController) {
        print("\n\n IN UPDATESEARCHRESULTS ONCE \n\n")
        let searchBar = searchController.searchBar
        if whichSegmentedControl == 0{
            lftSearchToday(searchText: searchBar.text!)
        }
        else {
            lftSearchTomorrow(searchText: searchBar.text!)
        }
        
        
        
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
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if isFiltering{
            print("in the second dismiss - TEST")
            super.dismiss(animated: flag, completion: completion)
        }
        else{
            print("not in the second dismiss - isFiltering was false")
            // Added september 6
            super.dismiss(animated: flag, completion: completion)
            
        }
        
            super.dismiss(animated: flag, completion: completion)
        
        
        NotificationCenter.default.post(name: Notification.Name.dsvcBack, object: nil)
        
        
    
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .disabled)
        
        //segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.disabled)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.selected)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(backTap)
        // Do any additional setup after loading the view.
        
        
        
      //  self.isModalInPresentation = true
        
        // Do any additional setup after loading the view.
    
    
        
        
        setupSegmentedControl()
        searchController = UISearchController(searchResultsController: nil)
        self.view.addSubview(searchController.searchBar)
        searchController.searchBar.backgroundImage = UIImage()
        var sbTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        sbTextField!.textColor = .white
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        
        searchController.definesPresentationContext = true
        
        searchController.searchBar.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 17).isActive = true
        //searchController.searchBar.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 100).isActive = true
        searchController.searchBar.topAnchor.constraint(equalTo: margins.topAnchor, constant: 59.5).isActive = true
        //searchController.searchBar.widthAnchor.constraint(equalToConstant: self.view.frame.width-34).isActive = true
        searchController.searchBar.widthAnchor.constraint(equalToConstant: self.view.frame.width-68).isActive = true
 
        searchController.searchBar.isTranslucent = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search any interest"
        
     
        
        
      //  self.searchBarView.addSubview(searchController.searchBar)
      //  searchBarView.isUserInteractionEnabled            = true

        
        //searchController.delegate = self
        //searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        
        category = self.category.lowercased()
        categoriesTable.rowHeight = UITableView.automaticDimension
        categoriesTable.estimatedRowHeight = 34
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let todays_date = dateFormatter.string(from: Date())
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight)!
        let tomorrows_date = dateFormatter.string(from: tomorrow)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if category == "all"{
            var lftsToday_2: [NSManagedObject] = []
            var lftsToday_1: [NSManagedObject] = []
            var lftsToday_0: [NSManagedObject] = []
            var lftsTomorrow_2: [NSManagedObject] = []
            var lftsTomorrow_1: [NSManagedObject] = []
            var lftsTomorrow_0: [NSManagedObject] = []

            
            let fetchRequest_2 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
           fetchRequest_2.predicate = NSPredicate(format: "date == %@ AND importance > 1", todays_date)
            // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
            do {
                lftsToday_2 = try managedContext.fetch(fetchRequest_2)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            
            let fetchRequest_1 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
           fetchRequest_1.predicate = NSPredicate(format: "date == %@ AND importance == 1", todays_date)
            // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
            do {
                lftsToday_1 = try managedContext.fetch(fetchRequest_1)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let fetchRequest_0 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
           fetchRequest_0.predicate = NSPredicate(format: "date == %@ AND importance == 0", todays_date)
            // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
            do {
                lftsToday_0 = try managedContext.fetch(fetchRequest_0)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            lftsToday = lftsToday_2 + lftsToday_1 + lftsToday_0
            
            
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
            fetchRequest2.predicate = NSPredicate(format: "date == %@ AND importance > 1", tomorrows_date)
            do {
                lftsTomorrow_2 = try managedContext.fetch(fetchRequest2)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let fetchRequest1 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
            fetchRequest1.predicate = NSPredicate(format: "date == %@ AND importance == 1", tomorrows_date)
            do {
                lftsTomorrow_1 = try managedContext.fetch(fetchRequest1)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let fetchRequest0 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
            fetchRequest0.predicate = NSPredicate(format: "date == %@ AND importance == 0", tomorrows_date)
            do {
                lftsTomorrow_0 = try managedContext.fetch(fetchRequest0)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            lftsTomorrow = lftsTomorrow_2 + lftsTomorrow_1 + lftsTomorrow_0
            
            let fetchRequest3 = NSFetchRequest<NSManagedObject>(entityName: "UserLftToday")
            // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
            do {
                userLftsToday = try managedContext.fetch(fetchRequest3)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let fetchRequest4 = NSFetchRequest<NSManagedObject>(entityName: "UserLftTomorrow")
            do {
                userLftsTomorrow = try managedContext.fetch(fetchRequest4)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        else{
        // 2: Fetching the data -> NSFetchRequest is very flexible
            /*
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
       fetchRequest.predicate = NSPredicate(format: "category == %@ AND date == %@", category, todays_date)
        // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
        do {
            lftsToday = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
        fetchRequest2.predicate = NSPredicate(format: "category == %@ AND date == %@", category, tomorrows_date)
        do {
            lftsTomorrow = try managedContext.fetch(fetchRequest2)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
 */
            var lftsToday_2: [NSManagedObject] = []
            var lftsToday_1: [NSManagedObject] = []
            var lftsToday_0: [NSManagedObject] = []
            var lftsTomorrow_2: [NSManagedObject] = []
            var lftsTomorrow_1: [NSManagedObject] = []
            var lftsTomorrow_0: [NSManagedObject] = []

            
            let fetchRequest_2 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
           fetchRequest_2.predicate = NSPredicate(format: "date == %@ AND category == %@ AND importance > 1", todays_date, category)
            // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
            do {
                lftsToday_2 = try managedContext.fetch(fetchRequest_2)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            
            let fetchRequest_1 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
           fetchRequest_1.predicate = NSPredicate(format: "date == %@ AND category == %@ AND importance == 1", todays_date, category)
            // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
            do {
                lftsToday_1 = try managedContext.fetch(fetchRequest_1)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let fetchRequest_0 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
           fetchRequest_0.predicate = NSPredicate(format: "date == %@ AND category == %@ AND importance == 0", todays_date, category)
            // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
            do {
                lftsToday_0 = try managedContext.fetch(fetchRequest_0)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            lftsToday = lftsToday_2 + lftsToday_1 + lftsToday_0
            
            
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
            fetchRequest2.predicate = NSPredicate(format: "date == %@ AND category == %@ AND importance > 1", tomorrows_date, category)
            do {
                lftsTomorrow_2 = try managedContext.fetch(fetchRequest2)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let fetchRequest1 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
            fetchRequest1.predicate = NSPredicate(format: "date == %@ AND category == %@ AND importance == 1", tomorrows_date, category)
            do {
                lftsTomorrow_1 = try managedContext.fetch(fetchRequest1)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let fetchRequest0 = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
            fetchRequest0.predicate = NSPredicate(format: "date == %@ AND category == %@ AND importance == 0", tomorrows_date, category)
            do {
                lftsTomorrow_0 = try managedContext.fetch(fetchRequest0)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            lftsTomorrow = lftsTomorrow_2 + lftsTomorrow_1 + lftsTomorrow_0
        
        let fetchRequest3 = NSFetchRequest<NSManagedObject>(entityName: "UserLftToday")
        fetchRequest3.predicate = NSPredicate(format: "category == %@", category)
        // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
        do {
            userLftsToday = try managedContext.fetch(fetchRequest3)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let fetchRequest4 = NSFetchRequest<NSManagedObject>(entityName: "UserLftTomorrow")
        fetchRequest4.predicate = NSPredicate(format: "category == %@", category)
        do {
            userLftsTomorrow = try managedContext.fetch(fetchRequest4)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        }
        lftsToday = userLftsToday + lftsToday
        print("\n\nlftsToday is initially")
        print(lftsToday.count)
        print("afterwards it is")
       // lftsToday = lftsToday.uniques
        print(lftsToday.count)
        lftsTomorrow = userLftsTomorrow + lftsTomorrow
       // lftsTomorrow = lftsTomorrow.uniques
    }
    
    
    func lftSearchToday(searchText: String = ""){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let todays_date = dateFormatter.string(from: Date())
        let calendar = Calendar.current
   //     let midnight = calendar.startOfDay(for: Date())
    //    let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight)!
   //     let tomorrows_date = dateFormatter.string(from: tomorrow)
    
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
        if category == "all"{
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
        
            let predicate1 = NSPredicate(format: "interest_name CONTAINS[c] %@ OR desc CONTAINS[c] %@", searchText, searchText)
            let predicate2 = NSPredicate(format: "date == %@", todays_date)
        
        fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
                // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
                do {
                    filteredLftsToday = try managedContext.fetch(fetchRequest)
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
        }
        else {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
        
            let predicate1 = NSPredicate(format: "interest_name CONTAINS[c] %@ OR desc CONTAINS[c] %@", searchText, searchText)
            let predicate2 = NSPredicate(format: "date == %@ AND category == %@", todays_date, category)
        
        fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
                // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
                do {
                    filteredLftsToday = try managedContext.fetch(fetchRequest)
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
        }
    }
    func lftSearchTomorrow(searchText: String = ""){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let todays_date = dateFormatter.string(from: Date())
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight)!
        let tomorrows_date = dateFormatter.string(from: tomorrow)
        
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
        
        if category == "all"{
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
    
        let predicate1 = NSPredicate(format: "interest_name CONTAINS[c] %@ OR desc CONTAINS[c] %@", searchText, searchText)
        let predicate2 = NSPredicate(format: "date == %@", tomorrows_date)
    
    fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])

            do {
                filteredLftsTomorrow = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        else {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LookForwardTo")
        
            let predicate1 = NSPredicate(format: "interest_name CONTAINS[c] %@ OR desc CONTAINS[c] %@", searchText, searchText)
            let predicate2 = NSPredicate(format: "date == %@ AND category == %@", tomorrows_date, category)
        
        fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
                // 3: Sending over fetch request -> fetch() returns array of managed objects meeting the criteria of the search request
                do {
                    filteredLftsTomorrow = try managedContext.fetch(fetchRequest)
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
        }
    }
    
 
  
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if whichSegmentedControl == 0{
            if isFiltering {
                return filteredLftsToday.count
            }
            else{
            return lftsToday.count
        }
        }
        else {
            if isFiltering {
                return filteredLftsTomorrow.count
            }
            else {
            return lftsTomorrow.count
            }
 
        }
 
       // return 1
           // return self.interest_names_array.count
        }
        
        // There is just one row in every section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
             return 1
            /*
            if whichSegmentedControl == 0{
                if isFiltering {
                    return filteredLftsToday.count
                }
                else{
                return lftsToday.count
            }
            }
            else {
                if isFiltering {
                    return filteredLftsTomorrow.count
                }
                else {
                return lftsTomorrow.count
                }
            }
 */
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
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DetailSearchTableViewCell
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate!.persistentContainer.viewContext
            
            // 2: Fetching the data -> NSFetchRequest is very flexible
            print("segmentedCnotrol rn is " + String(whichSegmentedControl))
            if whichSegmentedControl == 0{
                let lft: NSManagedObject
                if isFiltering {
                    print("in table view: isFiltering is true")
                    lft = filteredLftsToday[indexPath.section]
                }
                else {
                    print("in table view: isFiltering is false")
                    lft = lftsToday[indexPath.section]
                }
             
                cell.cellCategory.text = lft.value(forKeyPath: "interest_name") as? String
                cell.cellDescription.text = lft.value(forKeyPath: "desc") as? String
            }
            
            else {
                let lft: NSManagedObject
                if isFiltering {
                    lft = filteredLftsTomorrow[indexPath.section]
                }
                else {
                    lft = lftsTomorrow[indexPath.section]
                }
                cell.cellCategory.text = lft.value(forKeyPath: "interest_name") as? String
                cell.cellDescription.text = lft.value(forKeyPath: "desc") as? String
            }
            
           
            
            // add border and color
            cell.backgroundColor = UIColor(white: 1, alpha: 0.125)

            cell.layer.cornerRadius = 8
 
            cell.clipsToBounds = true
         
            return cell
        }
        
        // method to run when table view cell is tapped
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // note that indexPath.section is used rather than indexPath.row
            print("You tapped cell number \(indexPath.row).")
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



extension Array where Element: NSManagedObject {
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains{$0.value(forKeyPath: "desc") as? String == elem.value(forKeyPath: "desc") as? String} {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
