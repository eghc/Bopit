//
//  ViewController.swift
//  Bop It
//
//  Created by Erin Harris on 1/16/18.
//  Copyright © 2018 Erin Harris. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var button: UIButton!
    
    @IBOutlet var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        button.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedImage(gesture:)))
        
        self.image.addGestureRecognizer(tap)
        self.image.isUserInteractionEnabled = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func tappedImage(gesture:UIGestureRecognizer){
        if gesture is UITapGestureRecognizer{
            self.performSegue(withIdentifier: "startGame", sender: self)
        }
    }
}

