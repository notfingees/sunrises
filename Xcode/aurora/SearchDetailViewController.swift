//
//  SearchViewController.swift
//  aurora
//
//  Created by justin on 2/2/21.
//

import UIKit

//class SearchViewController: SkyBackgroundViewController, UITableViewDelegate, UITableViewDataSource {
class SearchDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // These strings will be the data for the table view cells
     let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
     
     let cellReuseIdentifier = "lftCell"
     let cellSpacingHeight: CGFloat = 5
     
     @IBOutlet var tableView: UITableView!
     
     override func viewDidLoad() {
         super.viewDidLoad()
        
         
         // These tasks can also be done in IB if you prefer.
         self.tableView.register(SearchDetailTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
         tableView.delegate = self
         tableView.dataSource = self
     }
     
     // MARK: - Table View delegate methods
     
     func numberOfSections(in tableView: UITableView) -> Int {
         return self.animals.count
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
         
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SearchDetailTableViewCell
         
         // note that indexPath.section is used rather than indexPath.row
         cell.interest_name.text = self.animals[indexPath.section]
         
         // add border and color
         cell.backgroundColor = UIColor.white
         cell.layer.borderColor = UIColor.black.cgColor
         cell.layer.borderWidth = 1
         cell.layer.cornerRadius = 8
         cell.clipsToBounds = true
         
         return cell
     }
     
     // method to run when table view cell is tapped
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         // note that indexPath.section is used rather than indexPath.row
         print("You tapped cell number \(indexPath.section).")
     }
 }
