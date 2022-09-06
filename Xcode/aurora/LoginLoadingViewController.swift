//
//  LoginLoadingViewController.swift
//  aurora
//
//  Created by justin on 2/9/21.
//

import UIKit
import CoreData
import CryptoKit

class LoginLoadingViewController: UIViewController {

    override func viewDidLoad(){
        super.viewDidLoad()
        print("in view did load of login loading view controller")
    }
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // load user interests, save them
        
        super.viewDidAppear(animated)
        
        print("in view did appear of Login Loading View Controller")
        //print("presenting login loading view controller is \(self.presentingViewController)")
        let group = DispatchGroup()
      //  var user_lft_ids: [Int] = []
        
        // DELETES EVERYTHING FROM CORE DATA

        
        
        //
        

        
        /*
        DispatchQueue.main.async{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.deleteAllData()

        }
 */
        

        //MARK: - USER ID NEEDS TO BE GOTTEN FROM OBJECT IN ACTUAL IMPLEMENTATION
        let user_id = self.get_user_id()

        
 
        
        
        // MARK: - CHANGE!!

            
      
            group.enter()
            let url5 = NSURL(string: "https://www.sunrisesapp.com/download_user_interests.php")
            var request5 = URLRequest(url: url5! as URL)
            request5.httpMethod = "POST"
            let dataString5 = "user_id=" + String(user_id)

            let dataD5 = dataString5.data(using: .utf8)
            do {
                let uploadJob = URLSession.shared.uploadTask(with: request5, from: dataD5){
                    data, response, error in
                    if error != nil {
                        print(error)
                    }
                    else {
                        var jsonResult = NSArray()
                        do{
                       //     jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                            
                            jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                    
                                } catch let error as NSError {
                                    print(error)
                                    
                                }
                        print(jsonResult.count)
                        var jsonElement = NSDictionary()
                       // let persons = NSMutableArray()
                        //var lft_array: [String] = []
                       // print(jsonResult)

                        for i in 0 ..< jsonResult.count{
                            jsonElement = jsonResult[i] as! NSDictionary

                            if let interest_id = (jsonElement["interest_id"] as AnyObject).doubleValue{
                                
                                DispatchQueue.main.async{
                                self.save_user_interest(user_id: Double(user_id), interest_id: interest_id)
                                    self.save_user_recommended(interest_id: interest_id)
                                }
                            
                            }
                            
                            //print(type(of: jsonElement["updated"]))
                         //   let updated = jsonElement["updated"]!
                         //   if (updated as AnyObject).doubleValue == 1{
                          //      print("so true")
                          //  }

                        }
                        group.leave()
                    }
                }
               
                    uploadJob.resume()
                
            }
        
       // group.wait()
      //  group.enter()
        DispatchQueue.main.async{
            self.generate_lfts()
         //   group.leave()
        }
        group.wait()
        self.tabBarController!.selectedIndex = 0
        /*
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        let vc = signUpView
        
        present(vc, animated: false, completion: nil)
 */
        
    }
    

    
    func save_user_recommended(interest_id: Double){
        let url3 = NSURL(string: "https://www.sunrisesapp.com/get_recommended_interests.php")
        var request = URLRequest(url: url3! as URL)
        request.httpMethod = "POST"
        let string_selected_interest_id = String(interest_id)
        var dataString = "interest_id=" + string_selected_interest_id
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
                            //print("the recommended interest id is")
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
                            
                        //    print("setting \(indexes_temp[0]) to recommended = true")
                            if indexes_temp.count > 0{
                                indexes_temp[0].setValue(true, forKeyPath: "recommended")
                            }
                            

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
    

    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

