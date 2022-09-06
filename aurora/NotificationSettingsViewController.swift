//
//  NotificationSettingsViewController.swift
//  aurora
//
//  Created by justin on 2/17/21.
//

import UIKit
import CoreData

class NotificationSettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - If user didn't press save, have a pop that's like "Do you want to save?"
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    override open var shouldAutorotate: Bool {
            return false
        }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return pickerData[0].count
        }
        else if component == 1{
            return pickerData[1].count
        }
        else if component == 2{
            return pickerData[2].count
        }
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
           return pickerData[component][row]
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           
            print("in the picker view function, \(pickerData[component][row])")
       // var currentPickerView = pickerData[0][pickerView.selectedRow(inComponent: 0)] + pickerData[1][pickerView.selectedRow(inComponent: 1)] + pickerData[2][pickerView.selectedRow(inComponent: 2)]
       // print(currentPickerView)
        var currentMorningPickerView = pickerData[0][morningPicker.selectedRow(inComponent: 0)] + " " + pickerData[1][morningPicker.selectedRow(inComponent: 1)] + " " + pickerData[2][morningPicker.selectedRow(inComponent: 2)]
         print(currentMorningPickerView)
        var currentEveningPickerView = pickerData[0][eveningPicker.selectedRow(inComponent: 0)] + " " + pickerData[1][eveningPicker.selectedRow(inComponent: 1)] + " " + pickerData[2][eveningPicker.selectedRow(inComponent: 2)]
         print(currentEveningPickerView)
        
        // MARK: - User id here
        let user_id = self.get_user_id()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        var indexes_temp: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
       // fetchRequest.predicate = NSPredicate(format: "user_id == %d", user_id)
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    //    let current_password = indexes_temp[0].value(forKey: "password") as? String
// hour : minute : am/pm
        indexes_temp[0].setValue(currentMorningPickerView, forKeyPath: "today_notification")
        indexes_temp[0].setValue(currentEveningPickerView, forKeyPath: "tomorrow_notification")
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        // MARK: - Need to reposition this at some point -> maybe call the other thing here?
        
        
        do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
        
       }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            super.dismiss(animated: flag, completion: completion)
        NotificationCenter.default.post(name: Notification.Name.backToSettingsReceived, object: nil)
        
        }
    
    @IBOutlet weak var back: UILabel!
    @IBOutlet weak var morningPicker: UIPickerView!
    @IBOutlet weak var eveningPicker: UIPickerView!
    @IBOutlet weak var enableNotificationsLabel: UILabel!
    @IBOutlet weak var enableNotificationsSwitch: UISwitch!
    
    
    var pickerData: [[String]] = [[String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerData = [["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"], ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"], ["AM", "PM"]]
        
        self.morningPicker.dataSource = self
        self.morningPicker.delegate = self
        
        self.eveningPicker.dataSource = self
        self.eveningPicker.delegate = self// Do any additional setup after loading the view.
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(backTap)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        var indexes_temp: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
       // fetchRequest.predicate = NSPredicate(format: "user_id == %d", user_id)
        do {
            indexes_temp = try managedContext.fetch(fetchRequest)
     
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        let today_notification_string = ((indexes_temp[0].value(forKey: "today_notification") as? String)!)
        let tomorrow_notification_string = ((indexes_temp[0].value(forKey: "tomorrow_notification") as? String)!)
        // split into HOUR  MINUTE  AM/PM
        let today_array = today_notification_string.split(separator: " ")
        let tomorrow_array = tomorrow_notification_string.split(separator: " ")
        
        morningPicker.selectRow(Int(today_array[0])!-1, inComponent: 0, animated: false)
        if today_array[1] == "00"{
            morningPicker.selectRow(0, inComponent: 1, animated: false)
        }
        else{
            morningPicker.selectRow(Int(today_array[1])!-1, inComponent: 1, animated: false)
        }
        
        if today_array[2] == "PM"{
            morningPicker.selectRow(0, inComponent: 2, animated: false)
        }
        else{
            morningPicker.selectRow(1, inComponent: 2, animated: false)
        }
        eveningPicker.selectRow(Int(tomorrow_array[0])!-1, inComponent: 0, animated: false)
        
        if tomorrow_array[1] == "00"{
            eveningPicker.selectRow(0, inComponent: 1, animated: false)
        }
        else{
            eveningPicker.selectRow(Int(tomorrow_array[1])!-1, inComponent: 1, animated: false)
        }
        if tomorrow_array[2] == "PM"{
            eveningPicker.selectRow(0, inComponent: 2, animated: false)
        }
        else{
            eveningPicker.selectRow(1, inComponent: 2, animated: false)
        }
        
        
        
        enableNotificationsSwitch.addTarget(self, action: #selector(self.switchIsChanged(_:)), for: UIControl.Event.valueChanged)
        
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            enableNotificationsSwitch.setOn(true, animated: false)
        } else {
            enableNotificationsSwitch.setOn(false, animated: false)
             // Show alert user is not registered for notification
        }
        
      //  self.isModalInPresentation = true
        
        // Do any additional setup after loading the view.
    }
    
    @objc func goBack(sender: UITapGestureRecognizer){
        
        dismissTransition = LeftToRightTransition()
        dismiss(animated: true)
      
       // self.schedule_today_notifications(hour: pickerData[0][morningPicker.selectedRow(inComponent: 0)], minute: pickerData[1][morningPicker.selectedRow(inComponent: 1)], ampm: pickerData[2][morningPicker.selectedRow(inComponent: 2)])
    }
        
    


    @objc func switchIsChanged(_ sender: UISwitch) {
        if enableNotificationsSwitch.isOn {
            
            print("Turning on notifications")
            UIApplication.shared.registerForRemoteNotifications()
            
            
            
          //  switchState.text = "UISwitch is ON"
        } else {
            
            
            let alert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to turn notifications off? You can re-enable them any time here or in your Settings app", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { action in
                
                // Turn off
                print("Turning off notifications")
                UIApplication.shared.unregisterForRemoteNotifications()
                
                
            }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

                    // show the alert
            self.present(alert, animated: true, completion: nil)
         //   switchState.text = "UISwitch is OFF"
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
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    func schedule_today_notifications(hour: String, minute: String, ampm: String){
        print("in schedule today notifications")
        let group = DispatchGroup()
        group.enter()
        let user_id = self.get_user_id()
            let url5 = NSURL(string: "http://localhost:8888/get_user_today_notification.php")
            var request5 = URLRequest(url: url5! as URL)
            request5.httpMethod = "POST"
            var notif_message = ""
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

                            if let nm = jsonElement["today_notification"] as? String{
                               // print("in the viewdiappear part of saving \(interest_id) for user")
                                print(nm)
                        
                                    notif_message = nm
                                print("notif_message in for loop is \(notif_message)")
                                group.leave()
                              //      self.save_user_interest(user_id: Double(user_id), interest_id: interest_id)
                              //      self.save_user_recommended(interest_id: interest_id)
                                
                            
                            }
                            
                            //print(type(of: jsonElement["updated"]))
                         //   let updated = jsonElement["updated"]!
                         //   if (updated as AnyObject).doubleValue == 1{
                          //      print("so true")
                          //  }

                        }
                    }
                }
               
                    uploadJob.resume()
                
            }
        group.wait()
        let _minute = Int(minute)
        var _hour = 0
        if ampm == "AM"{
            _hour = Int(hour)!
        }
        else{
            _hour = Int(hour)! + 12
        }
        var dateComponents = DateComponents()
        dateComponents.hour = _hour
        dateComponents.minute = _minute
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        print(notif_message)
            content.body = "Today, look forward to " + notif_message
        //    content.categoryIdentifier = "alarm"
        //    content.userInfo = ["customData": "fizzbuzz"]
            content.sound = UNNotificationSound.default
    //    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 65, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        
        
    }
    func schedule_tomorrow_notifications(){
    }
        // Number of columns of data

}

extension NotificationSettingsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
