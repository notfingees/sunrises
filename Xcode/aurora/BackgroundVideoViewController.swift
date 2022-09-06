//
//  BackgroundVideoViewController.swift
//  aurora
//
//  Created by justin on 7/30/21.
//

import UIKit
import AVFoundation

class BackgroundVideoViewController: UIViewController {
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    var changeBackgroundNotificationReceivedObserver: NSObjectProtocol?
    override open var shouldAutorotate: Bool {
            return false
        }
    
    func choose_video() -> URL{
        
        var theURL: URL
        
        let hour = Calendar.current.component(.hour, from: Date())
        let sod = Calendar.current.startOfDay(for: Date())
        let minutes_passed  = Date().minutes(from: sod)
        
        if (minutes_passed <= 240 || minutes_passed >= 1261){
            // NIGHT - TEMPLATE for random generation
            /*/
            let variant = Int.random(in: 1..<3) // two possiblities
            if variant == 1{
                theURL = Bundle.main.url(forResource:"night_1", withExtension: "mov")!
            }
            else{
                theURL = Bundle.main.url(forResource:"night_2", withExtension: "mov")!
            }
 */
            theURL = Bundle.main.url(forResource: "night_1", withExtension: "mov")!
            
        }
        else if (minutes_passed >= 241 && minutes_passed <= 330){
            let variant = Int.random(in: 1..<3)
            if variant == 1{
                theURL = Bundle.main.url(forResource:"pre_night_1", withExtension: "mov")!
            }
            else {
                theURL = Bundle.main.url(forResource:"pre_night_2", withExtension: "mov")!
            }
            // EARLY MORNING - pre-sunrise
          
        }
        else if (minutes_passed >= 331 && minutes_passed <= 450){
            
            // SUNRISE
            
            let variant = Int.random(in: 1..<6)
            if variant == 1{
                theURL = Bundle.main.url(forResource:"sunrises_1", withExtension: "mov")!
            }
            else if variant == 2{
                theURL = Bundle.main.url(forResource:"sunrises_2", withExtension: "mov")!
            }
            else{
                theURL = Bundle.main.url(forResource:"sunrises_3", withExtension: "mov")!
            }
           
            
        }
        else if (minutes_passed >= 451 && minutes_passed <= 660){
            
            // EARLY DAY - NOT ACTUALLY DONE
            
            theURL = Bundle.main.url(forResource:"early_day_1", withExtension: "mov")!
        
            
        }
        else if (minutes_passed >= 661 && minutes_passed <= 1050){
            // MID LATE DAY
      
            theURL = Bundle.main.url(forResource:"day_1", withExtension: "mov")!
           
          
        }

        else if (minutes_passed >= 1051 && minutes_passed <= 1170){
            // SUNSET
            let variant = Int.random(in: 1..<6)
            if variant == 1{
                theURL = Bundle.main.url(forResource:"sunrises_1", withExtension: "mov")!
            }
            else if variant == 2{
                theURL = Bundle.main.url(forResource:"sunrises_2", withExtension: "mov")!
            }
            else{
                theURL = Bundle.main.url(forResource:"sunrises_3", withExtension: "mov")!
            }
         
        }
      //  else if (minutes_passed >= 1171 && minutes_passed <= 1260){
        else{
            
            // EARLY NIGHT - NOT ACTUALLY DONE
            let variant = Int.random(in: 1..<3)
            if variant == 1{
                theURL = Bundle.main.url(forResource:"pre_night_1", withExtension: "mov")!
            }
            else {
                theURL = Bundle.main.url(forResource:"pre_night_2", withExtension: "mov")!
            }
         
            
        }
        
        return theURL
    }
    
    override func viewDidLoad() {
        
        
        
        changeBackgroundNotificationReceivedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.changeBackgroundNotificationReceived, object: nil, queue: nil, using: {(notification) in
            
            print("in notification of changeBackgroundNotificationReceivedObserver, about to print subviews")
            var theURL: URL
            
            // Determining the background of the AVPlayer/App
         
            theURL = self.choose_video()
            
            let url_to_asset = AVURLAsset(url: theURL)
            let newPlayerItem = AVPlayerItem(asset: url_to_asset)
            
            /*
            var url1 = Bundle.main.url(forResource:"mid_late_day_1080p", withExtension: "mp4")!
            let mld_1080p = AVURLAsset(url: url1)
            let firstPlayerItem = AVPlayerItem(asset: mld_1080p)
            
            var url2 = Bundle.main.url(forResource:"mid_late_day_1080p_fast", withExtension: "mp4")!
            let mld_1080p_fast = AVURLAsset(url: url2)
            let secondPlayerItem = AVPlayerItem(asset: mld_1080p_fast)
            
            if randomInt == 1{
                self.avPlayer.replaceCurrentItem(with: secondPlayerItem)
            }
            else{
                self.avPlayer.replaceCurrentItem(with: firstPlayerItem)
            }
 */
            self.avPlayer.replaceCurrentItem(with: newPlayerItem)
            
            
            
        })
        
    //    print("Creating a new BackgroundVideoViewController")
        //let randomInt = Int.random(in: 1..<3)
        var theURL = self.choose_video()

        avPlayer = AVPlayer(url: theURL)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = .resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none

        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.tag = 100
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        

        
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            self.avPlayer.seek(to: CMTime.zero)
            print("in this loopVideo mf once")
            self.avPlayer.play()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
        loopVideo(videoPlayer: avPlayer)
    }

}
