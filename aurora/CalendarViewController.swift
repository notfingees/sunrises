//
//  AccountSettingsViewController.swift
//  aurora
//
//  Created by justin on 2/17/21.
//

import UIKit
import CoreData


class CalendarViewController: UIViewController, UITextFieldDelegate {
    
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag, completion: completion)


            NotificationCenter.default.post(name: Notification.Name.backToSettingsReceived, object: nil)
        
        }
    
  //  @IBOutlet weak var back: UILabel!
    @IBOutlet weak var addEvent: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventDescription: UITextField!


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventDescription.attributedPlaceholder = NSAttributedString(string: "Event description", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        eventDescription.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        /*
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(backTap)
 */
 
        let addEventTap = UITapGestureRecognizer(target: self, action: #selector(self.addPersonalLft))
        addEvent.isUserInteractionEnabled = true
        addEvent.addGestureRecognizer(addEventTap)
        
        /*
        addEvent.backgroundColor = UIColor(white: 1, alpha: 0.1)
        addEvent.layer.cornerRadius = 5
        addEvent.layer.masksToBounds = true
 */
        
     
        // Do any additional setup after loading the view.
    }
    
    
    @objc func addPersonalLft(sender: UITapGestureRecognizer){
        DispatchQueue.main.async{
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            // 1: Getting hands on NSManagedObjectContext
            let managedContext = appDelegate.persistentContainer.viewContext
            
            // 2: Creating new managed object and inserting into managed object context
            let entity = NSEntityDescription.entity(forEntityName: "LookForwardTo", in: managedContext)!
            
            let interest = NSManagedObject(entity: entity, insertInto: managedContext)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy"
            let event_date = dateFormatter.string(from: self.datePicker.date)
            
            // 3: Setting name attribute (setting attributes for the object in general)
            interest.setValue(0, forKeyPath: "interest_id")
            //MARK: - Setting nothing for ID, i wonder if that will be bad
            // Should also do a validation to make sure desc is not empty
           // interest.setValue(items[1], forKeyPath: "id")
            interest.setValue(self.eventDescription.text, forKeyPath: "desc")
            interest.setValue("personal", forKeyPath: "category")
            interest.setValue(2, forKeyPath: "importance")
            interest.setValue(event_date, forKeyPath: "date")
            interest.setValue("Personal", forKeyPath: "interest_name")
            
            print("saving look forward to \(interest)")
            
            // 4: Commiting the changes -> save
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            
        }
        let alert = UIAlertController(title: "Success!", message: "Your event to look forward to was successfully added! We can't wait!", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)

    }
    
    @objc func goBack(sender: UITapGestureRecognizer){
        
        dismissTransition = LeftToRightTransition()
        dismiss(animated: true)

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

extension CalendarViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
