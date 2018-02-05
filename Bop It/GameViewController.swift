//
//  GameViewController.swift
//  Bop It
//
//  Created by Erin Harris on 1/16/18.
//  Copyright © 2018 Erin Harris. All rights reserved.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    @IBOutlet var background: UILabel!
    
    @IBOutlet var label: UILabel!
    
    @IBOutlet var playAgainButton: UIButton!
    
    @IBOutlet var highScoreLabel: UILabel!
    
    @IBOutlet var scoreLabel: UILabel!
    
    //background music
    var player = AVAudioPlayer()
    
    //noise player
    var noise = AVAudioPlayer()
    
    //voice player
    var voice = AVAudioPlayer()
    
    //timer for the game
    var gameTimer = Timer()
    
    //timer for flipping
    var flipTimer = Timer()
    
    //seconds between commands
    var seconds = 5.0
    
    //all the types of the game
    let types = ["Shake" , "Tap", "Swipe", "Flip", "Pass"]
    
    let sounds = ["zap.mp3","cork_pop.mp3","slide_up_new.mp3","boing.mp3"]
    
    //all background colors
    let colors = [["r": 104.0,"g": 90.0,"b": 115.0], ["r": 133.0,"g": 199.0,"b": 217.0], ["r": 96.0,"g":187.0,"b": 177.0], ["r": 237.0,"g": 213.0,"b": 105.0], ["r": 243.0,"g": 61.0,"b": 53.0]]
    
    //current type
    var current = -1
    
    //orientation of the phone; 1 = face up, -1 = face down
    var orientation = 1
    
    //checks if motion was complete; 0 = true, 1 = false
    var complete = 0
    
    //score
    var score = 0
    var level = 1
    var highscore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //get highscore
        highscore = UserDefaults.standard.object(forKey: "highscore") as! Int
        
        if let hs = highscore as Int?{
            highScoreLabel.text = "Highscore: " + String(hs)
        }else{
            highscore = 0
        }
        
        //hide buttons and labels
        playAgainButton.isHidden = true
        highScoreLabel.isHidden = true
        scoreLabel.isHidden = true
        
        
        
        //set up swipes
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swiped(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swiped(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(GameViewController.tapped(gesture:)))
        self.view.addGestureRecognizer(tap)
        
        //set up the gameTimer
        gameTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(GameViewController.mainGame), userInfo: nil, repeats: true)
        
        //set up timer to check flipping
        flipTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(GameViewController.trackOrientationChanges), userInfo: nil, repeats: true)
        
        //background music starts
        let audioPath = Bundle.main.path(forResource: "backgroundmusic", ofType: "wav")
        
        do{
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
            player.numberOfLoops = -1
            player.volume = 0.5
            player.play()
            
        }catch{
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateTimers(){
        //update the gameTimer
        gameTimer.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(GameViewController.mainGame), userInfo: nil, repeats: true)
        
        //set up timer to check flipping
        flipTimer.invalidate()
        flipTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(GameViewController.trackOrientationChanges), userInfo: nil, repeats: true)
    }
    
    @objc func mainGame(){
        //lost
        if complete == 1{
            //change background
            background.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            
            //change text color
            label.textColor = UIColor.white
            
            //change text
            label.text = "You lost"
            
            //pause sound
            player.pause()
            
            //stop timer
            gameTimer.invalidate()
            
            //play losing sound
            let audioPath = Bundle.main.path(forResource: "lost", ofType: "wav")
            let voiceAudioPath = Bundle.main.path(forResource:"voices/bummer", ofType: "mp3")
            
            do{
                try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
                player.play()
            }catch{
                
            }
            do{
                try voice = AVAudioPlayer(contentsOf: URL(fileURLWithPath: voiceAudioPath!))
                voice.volume = 1
                voice.play()
            }catch{
                
            }
            //check score against high score
            if score > highscore{
                highscore = score
                UserDefaults.standard.set(highscore, forKey: "highscore")
                highScoreLabel.text = "Highscore: " + String(highscore)
            }

            //update score label
            scoreLabel.text = "Score: " + String(score)
            
            //show play again button and labels
            playAgainButton.isHidden = false
            highScoreLabel.isHidden = false
            scoreLabel.isHidden = false
        }else{
        
            //pick random number 0-4
            current = Int(arc4random_uniform(5))
            print(current)
            
            //change label to next type
            label.text = types[current] + " it!"
            
            //change background color
            background.backgroundColor = UIColor(red: CGFloat(colors[current]["r"]!/255.0), green: CGFloat(colors[current]["g"]!/255.0), blue: CGFloat(colors[current]["b"]!/255.0), alpha: 1.0)
            
            //if current is not passing, change complete to 1
            if current != 4{
                complete = 1
                
            }
            
            //if current is for flipped, change orientation
            orientation = orientation * -1
            
            //say command
            let voiceAudioPath = Bundle.main.path(forResource:"voices/" + types[current], ofType: "mp3")
            do{
                try voice = AVAudioPlayer(contentsOf: URL(fileURLWithPath: voiceAudioPath!))
                voice.volume = 1
                voice.play()
            }catch{
                
            }
            
            //check score to change level
            if score == 15{
                level = 2
                seconds = 2.0
                updateTimers()
            }
            if score == 50{
                level = 3
                seconds = 1.5
                updateTimers()
            }
            if score == 75{
                level = 4
                seconds = 1.0
                updateTimers()
            }
            
        }
        
    }
    
    //checks shaking
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {

        if event?.subtype == UIEventSubtype.motionShake{
            //play sound
            let sound_str : [String] = sounds[0].components(separatedBy: ".")
            
            let audioPath = Bundle.main.path(forResource: "sounds/"+sound_str[0], ofType:  sound_str[1])
            
            do{
                try noise = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
                noise.volume = 0.5
                noise.play()
            }catch{
                
            }
            
            //if the current type is shake, then proper motion completed
            if current == 0{
                //change complete to 0
                complete = 0
                
                // change score
                score = score + 5*level
            }else{
                complete = 1
            }
            print("Shaken")
        }
    }
    
    @objc func tapped(gesture:UIGestureRecognizer){
        if gesture is UITapGestureRecognizer{
            //play sound
            let sound_str : [String] = sounds[1].components(separatedBy: ".")
            
            let audioPath = Bundle.main.path(forResource: "sounds/"+sound_str[0], ofType:  sound_str[1])
            
            do{
                try noise = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
                noise.volume = 0.5
                noise.play()
            }catch{
                
            }
            
            //if the current type is tapped, then proper motion completed
            if current == 1{
                //change complete to 0
                complete = 0
                
                //change score
                score = score + 5*level
                
            }else{
                complete = 1
            }
            print("Tapped!")
        }
    }
    
    //checks swiping
    @objc func swiped(gesture: UIGestureRecognizer){
        if gesture is UISwipeGestureRecognizer{
            //play sound
            let sound_str : [String] = sounds[2].components(separatedBy: ".")
            
            let audioPath = Bundle.main.path(forResource: "sounds/"+sound_str[0], ofType:  sound_str[1])
            
            do{
                try noise = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
                noise.volume = 0.5
                noise.play()
            }catch{
                
            }
            //if the current type is swiped, then proper motion completed
            if current == 2{
                //change complete to 0
                complete = 0
                
                //change score
                score = score + 5*level
                
            }else{
                complete = 1
            }
            print("Swiped!")
        }
    }
    
    //TODO: checks "flipping"
    @objc func trackOrientationChanges() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIDeviceOrientationDidChange, object: nil, queue: nil, using:
            { notificiation in
                
                //play sound
                let sound_str : [String] = self.sounds[3].components(separatedBy: ".")
                
                let audioPath = Bundle.main.path(forResource: "sounds/"+sound_str[0], ofType:  sound_str[1])
                
                do{
                    try self.noise = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
                    self.noise.volume = 0.5
                    self.noise.play()
                }catch{
                    
                }
                //if the current type is sflipping, then proper motion completed
                if self.current == 3{
                    if UIDevice.current.orientation == .faceDown && self.orientation == -1{
                        //change complete to 0
                        self.complete = 0
                        
                        //TODO: change score
                        self.score = self.score + 5*self.level
                        
                    } else if UIDevice.current.orientation == .faceUp && self.orientation == 1{
                        //change complete to 0
                        self.complete = 0
                        
                        //change score
                        self.score = self.score + 5*self.level
                    }
                    else{
                        self.complete = 1
                    }
                }
                print("Flipped")
        })
    }

}
