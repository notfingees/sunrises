//
//  OnboardingNavigationController.swift
//  aurora
//
//  Created by justin on 2/6/21.
//

import UIKit

class OnboardingNavigationController: UINavigationController {
    override open var shouldAutorotate: Bool {
            return false
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   self.view.insertSubview(SkyBackgroundViewController().view, at: 0)
        //self.view.backgroundColor = UIColor.red
        // Do any additional setup after loading the view.
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
