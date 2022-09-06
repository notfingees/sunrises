//
//  AboutViewController.swift
//  aurora
//
//  Created by justin on 8/30/21.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var back: UILabel!
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    var presentTransition: UIViewControllerAnimatedTransitioning?
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag, completion: completion)
        NotificationCenter.default.post(name: Notification.Name.backToSettingsReceived, object: nil)
        
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(backTap)
        // Do any additional setup after loading the view.
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

extension AboutViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
