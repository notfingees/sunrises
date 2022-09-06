//
//  SignUpEmail.swift
//  aurora
//
//  Created by justin on 2/7/21.
//

import FirebaseAuth
import FirebaseCore
import CoreData
import UIKit
import CryptoKit

class SignUpEmail: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var back: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    var userEmail: String = ""
    var userName: String = ""
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag, completion: completion)
        NotificationCenter.default.post(name: Notification.Name.signUpPEBackNotificationReceived, object: nil)
        
    
        }
    
    override func viewDidLoad() {
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "Confirm password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        self.errorMessage.isHidden = true
        passwordView.layer.cornerRadius = 10
        passwordView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        confirmPasswordView.layer.cornerRadius = 10
        confirmPasswordView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        nextView.layer.cornerRadius = 10
        nextView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        confirmPasswordField.backgroundColor = UIColor.clear
        passwordField.backgroundColor = UIColor.clear
        
        
        super.viewDidLoad()
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(backTap)
        // Do any additional setup after loading the view.
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.goBackSwipe(sender:)))

        rightSwipe.direction = .right
      
        self.view.addGestureRecognizer(rightSwipe)
        
        let signUp = UITapGestureRecognizer(target: self, action: #selector(self.registerUserEmail(sender:)))
        let signUp2 = UITapGestureRecognizer(target: self, action: #selector(self.registerUserEmail(sender:)))
        nextView.isUserInteractionEnabled = true
        nextView.addGestureRecognizer(signUp)
        nextButton.addGestureRecognizer(signUp2)
        
        
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
    
    
    @objc func registerUserEmail(sender: UITapGestureRecognizer){
        
        if passwordField.text! != confirmPasswordField.text!{
            self.errorMessage.isHidden = false
            self.errorMessage.text = "Two passwords are not identical"
        }
        else{
        
        Auth.auth().createUser(withEmail: userEmail, password: passwordField.text!){ (user, error) in
         if error == nil {
            
            // save information to CoreData, upload to MySQL, get user ID back, save user ID in coreData
            
            let group = DispatchGroup()
            print("right after group declaration")
            // upload to MySQL
            group.enter()
            
            let user_hash = self.generate_hash(str: self.passwordField.text!)
            print("Generating hash! It is \(user_hash)")
            let url = NSURL(string: "https://www.sunrisesapp.com/add_user_email.php")
            var request = URLRequest(url: url! as URL)
            request.httpMethod = "POST"
            var dataString = "name=" + self.userName + "&email=" + self.userEmail + "&user_hash=" + user_hash
            
            let dataD = dataString.data(using: .utf8)
            do {
                let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD){
                    data, response, error in
                    if error != nil {
                        print(error)
                    }
                    else {
                        print("no error!")
                    }
                    group.leave()
                }
                
                    uploadJob.resume()
            }
            
            group.wait()
            group.enter()
            print("right before declaring url3")
            var user_id = "0"
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
                           
                            group.leave()
                        }
                   
      
                    }
                    //group.leave() -> did this change anything
                }
                uploadJob.resume()
            }
            group.wait()
            // save user information to coredata
            // SEP 2 MODIFICATION (MOVED UPWARDS A LITTLE)
            DispatchQueue.main.async{
                self.saveUser(name: self.userName, email: self.userEmail, password: self.passwordField.text!, userid: user_id, user_hash: user_hash)
            }
 
            
            let parent = self.presentingViewController
            print("parent is")
            print(parent)
            let grandparent = parent?.presentingViewController as! TabBarViewController
            print("grandparent is")
            print(grandparent)
            print(grandparent.viewControllers)
            
            grandparent.tabBar.isHidden = true
            
            
            // TEST JULY 7
            /*
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            var indexes_temp: [NSManagedObject] = []
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Interest")
            
            do {
                indexes_temp = try managedContext.fetch(fetchRequest)
         
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            print("in signUPEmail, iNDEXES_TEMP = \(indexes_temp)")
 */
            
            
            
            self.dismiss(animated: false, completion: nil)
            parent!.dismiss(animated: false, completion: nil)
           // self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
           // self.navigationController?.popToRootViewController(animated: true)

            //NotificationCenter.default.post(name: Notification.Name.userLoggedInReceived, object: nil)
            
            var vcs = grandparent.viewControllers
          //  print("before remove: \(vcs) count is \(vcs!.count), at [5] is \(vcs![5])")
            vcs!.remove(at: 3)
    //        vcs!.remove(at: 3)
            grandparent.viewControllers = vcs
          //  print("after remove: \(vcs) count is \(vcs!.count), at [5] is \(vcs![5])")
            //print(grandparent.viewControllers)
            
            // should be redirecting to interests search (adding interests)
            print("grandparent.viewControllers is \(grandparent.viewControllers)")
            grandparent.selectedIndex = 7 // should be 5 i'm pretty sure
            
 
            
            }
         else{
            print("FIREBASE ERROR", error?.localizedDescription)
            self.errorMessage.isHidden = false
            self.errorMessage.text = error?.localizedDescription
            print("error registering user with Email", error)
         }
        }
        }
    }
    
    func saveUser(name: String, email: String, password: String, userid: String, user_hash: String){
        print("in saveUser in SignUpEmail saving the user with userid", userid)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // July 13: Deleting all previous users (if they exist)
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
                let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                do
                {
                    try managedContext.execute(deleteRequest)
                    try managedContext.save()
                }
                catch
                {
                    print ("There was an error")
                }
        
        // 2: Creating new managed object and inserting into managed object context
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        
        let interest = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3: Setting name attribute (setting attributes for the object in general)
        
        print("saving user ",name, email, password, userid)
        interest.setValue(name, forKeyPath: "name")
        interest.setValue(email, forKeyPath: "email")
    
        interest.setValue(password, forKeyPath: "password")
        interest.setValue(userid, forKeyPath: "user_id")
        interest.setValue("09 00 AM", forKeyPath: "today_notification")
        interest.setValue("09 00 PM", forKeyPath: "tomorrow_notification")
        interest.setValue(user_hash, forKeyPath: "user_hash")

        
        // 4: Commiting the changes -> save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        // JUly 13 mod
        
        var indexes_temp_2: [NSManagedObject] = []
        let fetchRequest_2 = NSFetchRequest<NSManagedObject>(entityName: "User")
        
        do {
            indexes_temp_2 = try managedContext.fetch(fetchRequest_2)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        print("in saveUesr, just saved the user, indexes_temp.count is \(indexes_temp_2.count)")
 
        
        
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

extension SignUpEmail: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
