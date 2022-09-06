//
//  SignUp1.swift
//  aurora
//
//  Created by justin on 2/6/21.
//

import UIKit
import FirebaseAuth

class SignUp1: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    
   
    var countryCode = "1"
    var customCountryCode = false
    
    var pickerData: [String] = [String]()
    

    @IBOutlet weak var back: UILabel!
    
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var google: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    
    @IBOutlet weak var areaCodePicker: UIPickerView!
    
    var signUpPEBackNotificationReceivedObserver: NSObjectProtocol?
    var hideEverythingSignUp1NotificationReceivedObserver: NSObjectProtocol?

    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    /*
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {

        let string = pickerData[row]
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
    }
 */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 17)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = pickerData[row]
        pickerLabel?.textColor = UIColor.white
        pickerLabel?.backgroundColor = .clear

        return pickerLabel!
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("countryCode selected is", pickerData[row])
        
        //pickerView.subviews[0].subviews[0].subviews[2].backgroundColor = .clear
      //  pickerView.subviews.first?.subviews.last?.backgroundColor = .clear
        
        
        
        if pickerData[row] == "+1 (US/Canada)"{
            countryCode = "1"
        }
        else if pickerData[row] == "+7 (Russia)"{
            
            
            countryCode = "7"
        }
        else if pickerData[row] == "Other (include own code in #)"{
            customCountryCode = true
        }
        else{
            countryCode = String(pickerData[row].prefix(3))
            countryCode = countryCode.replacingOccurrences(of: "+", with: "")
        }
        
    }
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag, completion: completion)
        NotificationCenter.default.post(name: Notification.Name.remoteNotificationReceived, object: nil)
        
        self.nameView.isHidden = false
        //self.googleView.isHidden = false
        self.emailView.isHidden = false
        self.nextView.isHidden = false
        self.createAccountLabel.isHidden = false
        self.nameField.isHidden = false
        self.emailField.isHidden = false
        self.nextButton.isHidden = false
        self.google.isHidden = false
        self.back.isHidden = false
        self.errorMessage.isHidden = true
        self.areaCodePicker.isHidden = false
        
        }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        signUpPEBackNotificationReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.signUpPEBackNotificationReceived, object: nil, queue: nil, using: { (notification) in
                    DispatchQueue.main.async { // because the notification won't be received on the main queue and you want to update the UI which must be done on the main queue.
                        self.nameView.isHidden = false
                       // self.googleView.isHidden = false
                        self.emailView.isHidden = false
                        self.nextView.isHidden = false
                        self.createAccountLabel.isHidden = false
                        self.nameField.isHidden = false
                        self.emailField.isHidden = false
                        self.nextButton.isHidden = false
                        self.google.isHidden = false
                        self.back.isHidden = false
                        self.errorMessage.isHidden = true
                        self.areaCodePicker.isHidden = false
                    }
                })
        
        hideEverythingSignUp1NotificationReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.hideEverythingSignUp1NotificationReceived, object: nil, queue: nil, using: { (notification) in DispatchQueue.main.async{
            self.nameView.isHidden = true
            //self.googleView.isHidden = true
            self.emailView.isHidden = true
            self.nextView.isHidden = true
            self.createAccountLabel.isHidden = true
            self.nameField.isHidden = true
            self.emailField.isHidden = true
            self.nextButton.isHidden = true
            self.google.isHidden = true
            self.back.isHidden = true
            self.errorMessage.isHidden = true
            self.areaCodePicker.isHidden = true
            
        }})
    }
    
    
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emailField.attributedPlaceholder = NSAttributedString(string: "Email or phone", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        areaCodePicker.setValue(UIColor.white, forKey: "textColor")
        

        //areaCodePicker.subviews.first?.subviews.last?.backgroundColor = UIColor.white
        
        pickerData = ["+1 (US/Canada)", "+7 (Russia)", "+44 (UK)", "+52 (Mexico)", "+61 (Australia)", "+81 (Japan)", "+82 (China)", "+86 (China)", "+91 (India)", "Other (include own code in #)"]
        self.areaCodePicker.delegate = self
        self.areaCodePicker.dataSource = self
        
        nameField.delegate = self
        emailField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        self.errorMessage.isHidden = true
      //  self.isModalInPresentation = true
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(backTap)
        // Do any additional setup after loading the view.
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.goBackSwipe(sender:)))

        rightSwipe.direction = .right
      
        self.view.addGestureRecognizer(rightSwipe)
        
        nameField.backgroundColor = UIColor.clear
        emailField.backgroundColor = UIColor.clear
        
        nameView.layer.cornerRadius = 10
        emailView.layer.cornerRadius = 10
        nextView.layer.cornerRadius = 10
        //googleView.layer.cornerRadius = 10
        nameView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        emailView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        //googleView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        nextView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        
        let nextTap = UITapGestureRecognizer(target: self, action: #selector(self.nextTapFunc))
        let nextTap2 = UITapGestureRecognizer(target: self, action: #selector(self.nextTapFunc))
        nextView.isUserInteractionEnabled = true
        nextButton.addGestureRecognizer(nextTap)
        nextView.addGestureRecognizer(nextTap2)
        
        
        let googleTap = UITapGestureRecognizer(target: self, action: #selector(self.logInWithGoogle))
        //googleView.isUserInteractionEnabled = true
        //googleView.addGestureRecognizer(googleTap)
        google.addGestureRecognizer(googleTap)
        
        
    }
    
    
    
    @objc func nextTapFunc(sender: UITapGestureRecognizer){
        
        
        // MARK: -need to do the text validation stuff - return before new scenes are presented
        print("in nextTapFunc")
        let numbersSet = CharacterSet(charactersIn: "+0123456789")
        let textCharacterSet = CharacterSet(charactersIn: emailField.text!)
        var trueIfEmail = false
        if textCharacterSet.isSubset(of: numbersSet) {
            trueIfEmail = false
        } else {
            trueIfEmail = true
        }
        print("in SignUp1 trueIfEmail is", trueIfEmail)
        
        if trueIfEmail{
            
            // email sign up
            
            if (emailField.text!.contains("@") &&  emailField.text!.contains(".")){
                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "SignUpEmail") as! SignUpEmail

                let vc = signUpView
                presentTransition = RightToLeftTransition()
                dismissTransition = LeftToRightTransition()
                vc.userEmail = emailField.text!
                vc.userName = nameField.text!
                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self

                present(vc, animated: true, completion: { [weak self] in
                    self?.presentTransition = nil
                })
                
                self.nameView.isHidden = true
                //self.googleView.isHidden = true
                self.emailView.isHidden = true
                self.nextView.isHidden = true
                self.createAccountLabel.isHidden = true
                self.nameField.isHidden = true
                self.emailField.isHidden = true
                self.nextButton.isHidden = true
                self.google.isHidden = true
                self.back.isHidden = true
                self.errorMessage.isHidden = true
                self.areaCodePicker.isHidden = true
            }
            else{
                self.errorMessage.isHidden = false
                self.errorMessage.text = "Please enter a valid email!"
            }
        }
        else{
            // phone sign up
            if (emailField.text!.count > 15 || emailField.text!.count < 7){
                self.errorMessage.isHidden = false
                self.errorMessage.text = "Please enter a valid phone number!"
            }
            else{
                
                var vID = ""
                
                var phoneNumber = ""
                
                if emailField.text!.contains("+"){
                    phoneNumber = emailField.text!.replacingOccurrences(of: "+", with: "")
                }
                else{
                    phoneNumber = emailField.text!
                }
                
                phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
                
                if customCountryCode{
                    print("customCountryCode - don't do anything")
                }
                else{
                    phoneNumber = self.countryCode + phoneNumber
                }
              
                    
                   
                    
                    PhoneAuthProvider.provider()
                        .verifyPhoneNumber("+"+phoneNumber, uiDelegate: nil) { verificationID, error in
                          if let error = error {
                           // self.showMessagePrompt(error.localizedDescription)
                            print("error in SignUp1 outer nest:", error.localizedDescription)
                            self.errorMessage.isHidden = false
                            self.errorMessage.text = error.localizedDescription
                            return
                        
                            
                          }
                          else{
                            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                            vID = verificationID!
          
                            NotificationCenter.default.post(name: Notification.Name.hideEverythingSignUp1NotificationReceived, object: nil)
                          }
                      
                      }

                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let signUpView  = mainStoryboard.instantiateViewController(withIdentifier: "SignUpPhone") as! SignUpPhone
                
                let vc = signUpView

                presentTransition = RightToLeftTransition()
                dismissTransition = LeftToRightTransition()
                    // MARK: must pass in phone number WITH area code but without + (e.g. 16505553434)
                vc.userName = nameField.text!
                vc.userPhone = phoneNumber
                    vc.vID = vID
                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self
                    
                    self.nameView.isHidden = true
                  //  self.googleView.isHidden = true
                    self.emailView.isHidden = true
                    self.nextView.isHidden = true
                    self.createAccountLabel.isHidden = true
                    self.nameField.isHidden = true
                    self.emailField.isHidden = true
                    self.nextButton.isHidden = true
                    self.google.isHidden = true
                    self.back.isHidden = true
                    self.areaCodePicker.isHidden = true
                    self.errorMessage.isHidden = true

                present(vc, animated: true, completion: { [weak self] in
                    self?.presentTransition = nil
                })
                
                
                
            
            
            }
        }
     
       
        

       
        
        
        

    }
    @objc func logInWithGoogle(sender: UITapGestureRecognizer){
        print("log in with google")
        // TODO: IMPLEMENT LATER
    }
    
    
    @objc func goBack(sender: UITapGestureRecognizer){
 
        
        dismissTransition = LeftToRightTransition()
                dismiss(animated: true)

    }
    @objc func goBackSwipe(sender: UISwipeGestureRecognizer){

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

extension Notification.Name {
    static let signUpPEBackNotificationReceived = Notification.Name("uk.co.company.app.signUpPEBack")
    static let hideEverythingSignUp1NotificationReceived = Notification.Name("uk.co.company.app.hideEverythingSignUp1")
}

extension SignUp1: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
