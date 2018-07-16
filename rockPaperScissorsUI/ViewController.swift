//
//  ViewController.swift
//  Rock-Paper-Scissors
//
//  Created by Jason Dong on 7/16/18.
//  Copyright © 2018 Jason Dong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    /*
     rock is 0
     paper is 1
     scissors are 2
     */
    
    @IBOutlet weak var rockButton: UIButton!
    
    @IBOutlet weak var scissorsButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    
    let moveNames = ["Rock", "Paper", "Scissor"]
    
    var player1: Int = 10
    var player2: Int = 1 //11
    
    let defaultColor = UIColor(red: 255/255, green: 140/255, blue: 0, alpha: 1)
    
    @IBOutlet weak var bgView: UIView!
    
    @IBAction func rButton(_ sender: Any) {
        player1 = 0 //rock
        rockButton.setBackgroundImage(#imageLiteral(resourceName: "selected"), for: UIControlState.normal)
        paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
    }
    @IBAction func pButton(_ sender: Any) {
        player1 = 1 // paper
        paperButton.setBackgroundImage(#imageLiteral(resourceName: "selected"), for: UIControlState.normal)
        rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
    }
    @IBAction func sButton(_ sender: Any) {
        player1 = 2 // scissors
        scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "selected"), for: UIControlState.normal)
        paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        
    }
    

    @IBAction func readyButton(_ sender: Any) {
        checkForWinner()
    }
    
    
    
    func winAlert(msg: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            let alert = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            self.player1 = 10
        }
        
    }
    
    func checkForWinner() {
        if (player1 == 0 && player2 == 2) || (player1 == 1 && player2 == 0) || (player1 == 2 && player2 == 1) {
            winAlert(msg: "You won!")
            bgView.backgroundColor = UIColor.green
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                self.bgView.backgroundColor = self.defaultColor
            }
        }
        if (player2 == 0 && player1 == 2) || (player2 == 1 && player1 == 0) || (player2 == 2 && player1 == 1) {
            winAlert(msg: "You Lose!")
            bgView.backgroundColor = UIColor.red
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                self.bgView.backgroundColor = self.defaultColor
            }
        }
        if (player1 == player2) {
            winAlert(msg: "It's tie!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

