//
//  AccountSettingsViewController.swift
//  aurora
//
//  Created by justin on 2/17/21.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseCore

class AccountSettingsViewController: UIViewController, UITextFieldDelegate {
    
    var userLoggedOut = false
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag, completion: completion)
        if userLoggedOut{
            NotificationCenter.default.post(name: Notification.Name.userLoggedOutReceived, object: nil)
        }
        else{
            NotificationCenter.default.post(name: Notification.Name.backToSettingsReceived, object: nil)
        }
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    @IBOutlet weak var back: UILabel!
    @IBOutlet weak var changePassword: UILabel!
    @IBOutlet weak var logOut: UILabel!
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordConfirm: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPassword.attributedPlaceholder = NSAttributedString(string: "Current password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        newPassword.attributedPlaceholder = NSAttributedString(string: "New password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        newPasswordConfirm.attributedPlaceholder = NSAttributedString(string: "Confirm new password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        self.hideKeyboardWhenTappedAround()
        currentPassword.delegate = self
        newPassword.delegate = self
        newPasswordConfirm.delegate = self
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(backTap)
        
        let changePasswordGesture = UITapGestureRecognizer(target: self, action: #selector(self.updateUserPassword))
        changePassword.isUserInteractionEnabled = true
        changePassword.addGestureRecognizer(changePasswordGesture)

        let logoutGesture = UITapGestureRecognizer(target: self, action: #selector(self.logOutFunc))
        logOut.isUserInteractionEnabled = true
        logOut.addGestureRecognizer(logoutGesture)
        
        currentPassword.backgroundColor = UIColor(white: 1, alpha: 0.1)
        newPassword.backgroundColor = UIColor(white: 1, alpha: 0.1)
        newPasswordConfirm.backgroundColor = UIColor(white: 1, alpha: 0.1)
        
        /*
        logOut.backgroundColor = UIColor(white: 1, alpha: 0.1)
        logOut.layer.cornerRadius = 10
        logOut.layer.masksToBounds = true

        changePassword.backgroundColor = UIColor(white: 1, alpha: 0.1)
        changePassword.layer.cornerRadius = 5
        changePassword.layer.masksToBounds = true

 */
        // Do any additional setup after loading the view.
    }
    
    @objc func goBack(sender: UITapGestureRecognizer){
        
        dismissTransition = LeftToRightTransition()
        dismiss(animated: true)

    }
    
    @objc func logOutFunc(sender: UITapGestureRecognizer){
        
        do {
                    try Auth.auth().signOut()
                }
             catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
        userLoggedOut = true
        dismissTransition = LeftToRightTransition()
        dismiss(animated: true)
        // MARK: Don't forget this is here
        firstTimeRemovingVCSTabBar = true
        userLoggedInVCS = false
        
        

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
    
    @objc func updateUserPassword(sender: UITapGestureRecognizer){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // MARK: Need a user ID here
        let user_id = self.get_user_id()
        // 1: Getting hands on NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        var indexes_temp: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "user")
        fetchRequest.predicate = NSPredicate(format: "user_id == %d", user_id)
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        let current_password = indexes_temp[0].value(forKey: "password") as? String
        
        if currentPassword.text == current_password{
            if newPassword.text == newPasswordConfirm.text{
                Auth.auth().currentUser?.updatePassword(to: newPassword.text!) { (error) in
                  print("error updating password \(error)")
                }
                
                indexes_temp[0].setValue(currentPassword.text!, forKeyPath: "password")
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            else {
                // alert that the passwords do not match, need to do validation/sanitation stuff here too probably, and also update user stuff
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

}

extension AccountSettingsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
