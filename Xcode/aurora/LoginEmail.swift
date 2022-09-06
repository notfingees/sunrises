//
//  LoginEmail.swift
//  aurora
//
//  Created by justin on 2/7/21.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import CoreData
import CryptoKit

class LoginEmail: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var back: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    var loginEmailDownloadDoneReceived: NSObjectProtocol?
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    var userEmail: String = ""
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag, completion: completion)
        NotificationCenter.default.post(name: Notification.Name.loginPEBackNotificationReceived, object: nil)
        self.back.isHidden = true
        self.passwordLabel.isHidden = true
        self.passwordField.isHidden = true
        self.passwordView.isHidden = true
        self.nextView.isHidden = true
        self.nextButton.isHidden = true
        self.errorMessage.isHidden = true
        
        
        
        }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)

        loginEmailDownloadDoneReceived = NotificationCenter.default.addObserver(forName: Notification.Name.LoginEmailDownloadDone, object: nil, queue: nil, using: { (notification) in
            DispatchQueue.main.async{
                
                let parent = self.presentingViewController
                if parent == nil {
                    print("in the else of LoginEmail testing going back and then logging in")
                    
                    /*
                    var vcs = self.tabBarController?.viewControllers
                    vcs!.remove(at: 3)
                    
                    self.tabBarController?.viewControllers = vcs
                    self.tabBarController?.selectedIndex = 2
                    
                    self.dismiss(animated: false, completion: nil)
                     */
                    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                    
                    guard let tabBarController = appDelegate.window?.rootViewController as? UITabBarController else { return }
                    var vcs = tabBarController.viewControllers
                    vcs!.remove(at: 3)
                    
                    tabBarController.viewControllers = vcs
                    tabBarController.selectedIndex = 2
                    
                    self.dismiss(animated: false, completion: nil)

                    
                }
                else{
                    print("parent is")
                    print(parent)
                    let grandparent = parent?.presentingViewController as! TabBarViewController
                    print("grandparent is")
                    print(grandparent)
                    print(grandparent.viewControllers)
                    self.dismiss(animated: false, completion: nil)
                    parent!.dismiss(animated: false, completion: nil)
                 
                    var vcs = grandparent.viewControllers
                    vcs!.remove(at: 3)
                    
                    

                    grandparent.viewControllers = vcs
                    print("after remove:")
                    print(grandparent.viewControllers)

                    grandparent.selectedIndex = 2
                }
                
            }
            
        })

    }
    
    override func viewDidLoad() {
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        self.back.isHidden = false
        self.passwordLabel.isHidden = false
        self.passwordField.isHidden = false
        self.passwordView.isHidden = false
        self.nextView.isHidden = false
        self.nextButton.isHidden = false

        
        
        passwordField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        
        self.errorMessage.isHidden = true
        
        passwordView.layer.cornerRadius = 10
        passwordView.backgroundColor = UIColor(white: 1, alpha: 0.1)
       
        nextView.layer.cornerRadius = 10
        nextView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        passwordField.backgroundColor = UIColor.clear
        
        
        super.viewDidLoad()
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(backTap)
        // Do any additional setup after loading the view.
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.goBackSwipe(sender:)))

        rightSwipe.direction = .right
      
        self.view.addGestureRecognizer(rightSwipe)
        
        let loginTap = UITapGestureRecognizer(target: self, action: #selector(self.loginEmail(sender:)))
        let loginTap2 = UITapGestureRecognizer(target: self, action: #selector(self.loginEmail(sender:)))
        nextView.isUserInteractionEnabled = true
        nextView.addGestureRecognizer(loginTap)
        nextButton.addGestureRecognizer(loginTap2)
      //  self.isModalInPresentation = true
        
        // Do any additional setup after loading the view.
    }
    @objc func goBack(sender: UITapGestureRecognizer){
        
        dismissTransition = LeftToRightTransition()
        dismiss(animated: true)

    }
    @objc func goBackSwipe(sender: UISwipeGestureRecognizer){
        dismissTransition = LeftToRightTransition()
        dismiss(animated: true)

    }
    
    @objc func loginEmail(sender: UITapGestureRecognizer){
        print("about to l;oginEmail")
        print("user email is ", userEmail)
        Auth.auth().signIn(withEmail: userEmail, password: passwordField.text!) { (user, error) in
           if error == nil{
            
            let group = DispatchGroup()
            group.enter()
            var user_id = "0"
            
            let user_hash = self.generate_hash(str: self.passwordField.text!)
            // get User ID back
            let url3 = NSURL(string: "https://www.sunrisesapp.com/get_user_id.php")
            var request3 = URLRequest(url: url3! as URL)
            request3.httpMethod = "POST"
            var dataString3 = "email=" + self.userEmail
            
            let dataD3 = dataString3.data(using: .utf8)
            do {
                let uploadJob = URLSession.shared.uploadTask(with: request3, from: dataD3){
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

                        for i in 0 ..< jsonResult.count{
                            jsonElement = jsonResult[i] as! NSDictionary
                            user_id = jsonElement["user_id"] as! String
                            print("user_id is ", user_id)
                           // print("about to saveUser in LoginEmail")
                            
                            
                            
                            
                            group.leave()
                        }
                   
      
                    }
                    //group.leave() -> did this change anything
                }
                uploadJob.resume()
            }
            group.wait()
            // save user information to coredata
            
            /* SEPTEMBER 2
             DispatchQueue.main.async{
                 self.saveUser(email: self.userEmail, password: self.passwordField.text!, userid: user_id)
             }
             */
 
            
            // Downloading the users' interests and setting recommended (July 14)
            
            group.enter()
            
            
            var user_interest_ids: [Double] = []

            let url5 = NSURL(string: "https://www.sunrisesapp.com/download_user_interests.php")
            var request5 = URLRequest(url: url5! as URL)
            request5.httpMethod = "POST"
            let dataString5 = "user_id=" + String(user_id)

            let dataD5 = dataString5.data(using: .utf8)
            var interests_done = 0
            
            do {
                let uploadJob = URLSession.shared.uploadTask(with: request5, from: dataD5){
                    data, response, error in
                    if error != nil {
                        print(error as Any)
                    }
                    else {
                        var jsonResult = NSArray()
                        do{
                       //     jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                            
                            jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                    
                                } catch let error as NSError {
                                    print(error)
                                    
                                }
                        print("count of download_user_interests in LoginEmail is", jsonResult.count)
                        
                        var interests_done_flag = false
                        
                        var jsonElement = NSDictionary()
                       // let persons = NSMutableArray()
                        //var lft_array: [String] = []
                       // print(jsonResult)
                        //self.howManyInterestsTotal = jsonResult.count
                        for i in 0 ..< jsonResult.count{
                            print("interests_done is \(interests_done), jsonResult.count is \(jsonResult.count)")
                            if interests_done + 1 == jsonResult.count{
                                print("setting interests_done_flag to true")
                                
                                interests_done_flag = true
                            }
                            else{

                            }
                            
                            
                            jsonElement = jsonResult[i] as! NSDictionary

                            if let interest_id = (jsonElement["interest_id"] as AnyObject).doubleValue{
                               // print("in the viewdiappear part of saving \(interest_id) for user")
                              //  DispatchQueue.main.async{
                                self.save_user_interest(user_id: Double(user_id)!, interest_id: interest_id)
                                user_interest_ids.append(interest_id)
                            
                            
                            }
   

                        }
                        group.leave()
                    }
                }
               
                    uploadJob.resume()
                
            }
            
            group.wait()
            group.enter()
            for iid in user_interest_ids{
                DispatchQueue.main.async{
                    self.save_user_recommended(interest_id: iid)
                }
            }
            group.leave()
            group.wait()
 
            

            let urlPath2 = "https://www.sunrisesapp.com/set_user_uptodate.php?user_id=" + String(user_id) + "&user_hash=" + user_hash
            let url2 = URL(string: urlPath2)!
            let defaultSession2 = Foundation.URLSession(configuration: URLSessionConfiguration.default)
            let task2 = defaultSession2.dataTask(with: url2){ (data, response, error) in
                if error != nil {
                    print("Failed to download data")
                } else {
                    
                    var jsonResult = NSArray()
                    do{
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                
                            } catch let error as NSError {
                                print(error)
                                
                            }

                    }

                    print("Set user up to date")
                
                
                
                

                }
                
            task2.resume()

           // group.enter()
            
            DispatchQueue.main.async{
                self.saveUser(email: self.userEmail, password: self.passwordField.text!, userid: user_id, user_hash: user_hash)
                NotificationCenter.default.post(name: Notification.Name.LoginEmailDownloadDone, object: nil)
           //     group.leave()
            }
           // group.wait()
            
            // End of downloading the users' interests and setting recommended
            /*
            let parent = self.presentingViewController
            print("parent is")
            print(parent)
            let grandparent = parent?.presentingViewController as! TabBarViewController
            print("grandparent is")
            print(grandparent)
            print(grandparent.viewControllers)
            self.dismiss(animated: false, completion: nil)
            parent!.dismiss(animated: false, completion: nil)
           // self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
           // self.navigationController?.popToRootViewController(animated: true)

            //NotificationCenter.default.post(name: Notification.Name.userLoggedInReceived, object: nil)
            var vcs = grandparent.viewControllers
            vcs!.remove(at: 3)
    //        vcs!.remove(at: 3)
            grandparent.viewControllers = vcs
            print("after remove:")
            print(grandparent.viewControllers)
            
            /*
            self.back.isHidden = true
            self.passwordLabel.isHidden = true
            self.passwordField.isHidden = true
            self.passwordView.isHidden = true
            self.nextView.isHidden = true
            self.nextButton.isHidden = true
            self.errorMessage.isHidden = true
 */
            grandparent.selectedIndex = 2
            /* July 20 edit ^^ nd vv
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                grandparent.selectedIndex = 2
                // Put your code which should be executed with a delay here
            }
 */
 */
           // grandparent.selectedIndex = 4 // should be 5 i'm pretty sure
            
            
            
                          }
            else{
                self.errorMessage.isHidden = false
                self.errorMessage.text = error?.localizedDescription
                
                print("error in log in Email", error)
    }
        }
        
    }
    
    func save_user_recommended(interest_id: Double){
            print("at the top of save_user_recommended")
         
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
                print("in save_user_recommended of launchscreen, saving interest_id \(interest_id)")
            // 1: Getting hands on NSManagedObjectContext
            let managedContext = appDelegate.persistentContainer.viewContext
            let url3 = NSURL(string: "https://www.sunrisesapp.com/get_recommended_interests.php")
            var request = URLRequest(url: url3! as URL)
            request.httpMethod = "POST"
            let string_selected_interest_id = String(interest_id)
            let dataString = "interest_id=" + string_selected_interest_id
            //print("dataString is \(dataString)")
            let dataD = dataString.data(using: .utf8)
            do {
                let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD){
                    data, response, error in
                    if error != nil {
                        print(error as Any)
                    }
                    else {
                        var jsonResult = NSArray()
                        do{
                            jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                                    
                                } catch let error as NSError {
                                    print(error)
                                    // try notifiations
                                }
                        
                        var jsonElement = NSDictionary()
                       // let persons = NSMutableArray()
                        //var lft_array: [String] = []
                        
                        //print(jsonResult)
                        for i in 0 ..< jsonResult.count{

                            jsonElement = jsonResult[i] as! NSDictionary
                         //   print("the recommended interest id is")
                         //   print(jsonElement["recommended_interest_id"])
                            
                            if let recommended_interest_id = (jsonElement["recommended_interest_id"] as AnyObject).doubleValue
                               {
                                
                                
                                // 2: Creating new managed object and inserting into managed object contextt]
                            
                                
                                var indexes_temp: [NSManagedObject] = []
                                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
                                fetchRequest.predicate = NSPredicate(format: "id == %d", (recommended_interest_id as NSNumber).intValue)
                                do {
                                    indexes_temp = try managedContext.fetch(fetchRequest)
                             
                                } catch let error as NSError {
                                    print("Could not fetch. \(error), \(error.userInfo)")
                                }
                                
                            //    print("setting \(indexes_temp[0]) to recommended = true")
                                if indexes_temp.count > 0{
                                    indexes_temp[0].setValue(true, forKeyPath: "recommended")
                                }
                                //indexes_temp[0].setValue(true, forKeyPath: "recommended")
                                

                                do {
                                    try managedContext.save()
                                } catch let error as NSError {
                                    print("Could not save. \(error), \(error.userInfo)")
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
    
    func saveUser(email: String, password: String, userid: String, user_hash: String){
        print("at the top of saveUser")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2: Creating new managed object and inserting into managed object context
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        
        let interest = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3: Setting name attribute (setting attributes for the object in general)
        
        interest.setValue(email, forKeyPath: "email")
    
        interest.setValue(password, forKeyPath: "password")
        interest.setValue(userid, forKeyPath: "user_id")
        interest.setValue("09 00 AM", forKeyPath: "today_notification")
        interest.setValue("09 00 PM", forKeyPath: "tomorrow_notification")
        interest.setValue(user_hash, forKeyPath: "user_hash")

        print("about to save in saveUser with", userid )
        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
            print("save worked with", userid )
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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

}

extension LoginEmail: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}

extension Notification.Name {
    static let LoginEmailDownloadDone = Notification.Name("uk.co.company.app.loginEmailDownloadDone")
}
