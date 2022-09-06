//
//  SignUp1.swift
//  aurora
//
//  Created by justin on 2/6/21.
//

import UIKit
import CoreData

class InterestsSettingsViewController: UIViewController {

    @IBOutlet weak var back: UILabel!
    @IBOutlet weak var iLabel: UILabel!
    @IBOutlet weak var addInterestsLabel: UILabel!
    @IBOutlet weak var modifyInterestsLabel: UILabel!
    
    
    var backToInterestsSettingsReceivedObserver: NSObjectProtocol?

    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    // for dismissing this one and sending to settingsvc
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag, completion: completion)
        NotificationCenter.default.post(name: Notification.Name.backToSettingsReceived, object: nil)
        
        }
    
    // for showing the stuff here
    override func viewWillAppear(_ animated: Bool){
        
        
        
        super.viewWillAppear(animated)
        backToInterestsSettingsReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.backToInterestsSettingsReceived, object: nil, queue: nil, using: { (notification) in
                    DispatchQueue.main.async { // because the notification won't be received on the main queue and you want to update the UI which must be done on the main queue.
                        self.back.isHidden = false
                        self.iLabel.isHidden = false
                        self.addInterestsLabel.isHidden = false
                        self.modifyInterestsLabel.isHidden = false
                        
                    }
                })
    }
    
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  self.isModalInPresentation = true
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(backTap)
        // Do any additional setup after loading the view.
        
        let modifyInterestsTap = UITapGestureRecognizer(target: self, action: #selector(self.mInterests))
        modifyInterestsLabel.isUserInteractionEnabled = true
        modifyInterestsLabel.addGestureRecognizer(modifyInterestsTap)
        
        let addInterestsTap = UITapGestureRecognizer(target: self, action: #selector(self.aInterests))
        addInterestsLabel.isUserInteractionEnabled = true
        addInterestsLabel.addGestureRecognizer(addInterestsTap)
        
        /*
        addInterestsLabel.backgroundColor = UIColor(white: 1, alpha: 0.1)
        addInterestsLabel.layer.cornerRadius = 5
        addInterestsLabel.layer.masksToBounds = true
        
        modifyInterestsLabel.backgroundColor = UIColor(white: 1, alpha: 0.1)
        modifyInterestsLabel.layer.cornerRadius = 5
        modifyInterestsLabel.layer.masksToBounds = true
 */
    }
    
    @objc func aInterests(sender: UITapGestureRecognizer){
        
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "InterestsSettingsSearchViewController") as! InterestsSettingsSearchViewController
        
        let vc = signUpView

        presentTransition = RightToLeftTransition()
        dismissTransition = LeftToRightTransition()
        //vc.userName = nameField.text!
        //vc.userPhone = emailField.text!
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self

        present(vc, animated: true, completion: { [weak self] in
            self?.presentTransition = nil
        })
 
        self.back.isHidden = true
        self.iLabel.isHidden = true
        self.addInterestsLabel.isHidden = true
        self.modifyInterestsLabel.isHidden = true

    }
    @objc func mInterests(sender: UITapGestureRecognizer){
 
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "InterestsSettingsRemoveViewController") as! InterestsSettingsRemoveViewController
        
        let vc = signUpView

        presentTransition = RightToLeftTransition()
        dismissTransition = LeftToRightTransition()
        //vc.userName = nameField.text!
        //vc.userPhone = emailField.text!
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self

        present(vc, animated: true, completion: { [weak self] in
            self?.presentTransition = nil
        })
        
        self.back.isHidden = true
        self.iLabel.isHidden = true
        self.addInterestsLabel.isHidden = true
        self.modifyInterestsLabel.isHidden = true
   
    }
    
    @objc func goBack(sender: UITapGestureRecognizer){
 
        
        dismissTransition = LeftToRightTransition()
                dismiss(animated: true)
        self.generate_lfts()

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

extension Notification.Name {
    static let backToInterestsSettingsReceived = Notification.Name("uk.co.company.app.backToInterestsSettingsReceived")
}

extension InterestsSettingsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
