//
//  Onboarding1ViewController.swift
//  aurora
//
//  Created by justin on 2/6/21.
//

import UIKit
import CoreData

class Onboarding1ViewController: UIViewController {
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var logInView: UIView!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var logIn: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var agree: UILabel!
    
    var remoteNotificationReceivedObserver: NSObjectProtocol?
    var userLoggedInObserver: NSObjectProtocol?
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    override open var shouldAutorotate: Bool {
            return false
        }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.signUpView.isHidden = false
        self.signUp.isHidden = false
        self.logIn.isHidden = false
        self.logInView.isHidden = false
        self.logo.isHidden = false
        self.agree.isHidden = false
        super.dismiss(animated: flag, completion: completion)
        
    }

    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.tabBarController!.tabBar.isHidden = true
        userLoggedInObserver = NotificationCenter.default.addObserver(forName: Notification.Name.userLoggedInReceived, object: nil, queue: nil, using: { (notification) in
            DispatchQueue.main.async{
                print("user Logged In Notification Received")
            self.tabBarController!.selectedIndex = 5
            }
            
        })
        
        remoteNotificationReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.remoteNotificationReceived, object: nil, queue: nil, using: { (notification) in
                    DispatchQueue.main.async { // because the notification won't be received on the main queue and you want to update the UI which must be done on the main queue.
                        self.signUpView.isHidden = false
                        self.signUp.isHidden = false
                        self.logIn.isHidden = false
                        self.logInView.isHidden = false
                        self.logo.isHidden = false
                        self.agree.isHidden = false
                        print("Remote Notification Received in Onboarding1ViewController")
                    }
                })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in view did load of Onboarding1ViewController")
        
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
        print("in Onboarding1VC, iNDEXES_TEMP = \(indexes_temp)")
 */
  
        
        signUpView.layer.cornerRadius = 10
        logInView.layer.cornerRadius = 10
        signUpView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        logInView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        let signUpTap = UITapGestureRecognizer(target: self, action: #selector(self.signUpFunc))
        let signUpTap2 = UITapGestureRecognizer(target: self, action: #selector(self.signUpFunc))
        signUpView.isUserInteractionEnabled = true
        signUpView.addGestureRecognizer(signUpTap2)
        signUp.addGestureRecognizer(signUpTap)
        let loginTap = UITapGestureRecognizer(target: self, action: #selector(self.logInFunc))
        let loginTap2 = UITapGestureRecognizer(target: self, action: #selector(self.logInFunc))
        logInView.isUserInteractionEnabled = true
        logInView.addGestureRecognizer(loginTap2)
        logIn.addGestureRecognizer(loginTap)
        
        // Do any additional setup after loading the view.
    }
    

    
    @objc func signUpFunc(sender: UITapGestureRecognizer){
        
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "SignUp1") as! SignUp1
        /*
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        print("in signUpFunc")
 */
        
        self.signUpView.isHidden = true
        self.logInView.isHidden = true
        self.signUp.isHidden = true
        self.logIn.isHidden = true
        self.logo.isHidden = true
        self.agree.isHidden = true
        
        let vc = signUpView

        presentTransition = RightToLeftTransition()
        dismissTransition = LeftToRightTransition()

        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self

        present(vc, animated: true, completion: { [weak self] in
            self?.presentTransition = nil
        })
        
  //      present(signUpView, animated: false, completion: nil)
    }
    @objc func logInFunc(sender: UITapGestureRecognizer){
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "Login1") as! Login1
        /*
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        print("in signUpFunc")
 */
        
        self.signUpView.isHidden = true
        self.logInView.isHidden = true
        self.signUp.isHidden = true
        self.logIn.isHidden = true
        self.logo.isHidden = true
        self.agree.isHidden = true
        
        let vc = signUpView

        presentTransition = RightToLeftTransition()
        dismissTransition = LeftToRightTransition()

        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self

        present(vc, animated: true, completion: { [weak self] in
            self?.presentTransition = nil
        })
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
    static let remoteNotificationReceived = Notification.Name("uk.co.company.app.remoteNotificationReceived")
}

extension Notification.Name {
    static let userLoggedInReceived = Notification.Name("uk.co.company.app.userLoggedInReceived")
}


extension Onboarding1ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}


class RightToLeftTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.25

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!

        container.addSubview(toView)
        toView.frame.origin = CGPoint(x: toView.frame.width, y: 0)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            toView.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}

class LeftToRightTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.25

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!

        container.addSubview(fromView)
        fromView.frame.origin = .zero

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            fromView.frame.origin = CGPoint(x: fromView.frame.width, y: 0)
        }, completion: { _ in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}

