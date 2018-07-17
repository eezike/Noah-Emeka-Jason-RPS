//
//  StartViewController.swift
//  rockPaperScissorsUI
//
//  Created by Noah Rubin on 7/16/18.
//  Copyright © 2018 Noah Rubin. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var scissorsButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    @IBOutlet weak var rockButton: UIButton!
    
    @IBOutlet weak var imageCycleView: UIImageView!
    let moveImages = [#imageLiteral(resourceName: "rock"), #imageLiteral(resourceName: "paper"), #imageLiteral(resourceName: "scissors")]
    var timer = Timer()
    var cycle = 0.0
    var index = 0
   
    
    func resetTimer() {
        cycle += 0.2
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: cycle, target: self, selector: #selector(updateDisplay), userInfo: nil, repeats: true)
    }
    
    @objc func updateDisplay(){
        resetTimer()
        index += 1
        if(index == moveImages.count){
            index = 0
        }
        imageCycleView.image = moveImages[index]
        player2 = index
    }
    
    var player1: Int = 10
    var player2: Int = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDisplay()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rButton(_ sender: Any) {
        player1 = 0 //rock
        rockButton.setBackgroundImage(#imageLiteral(resourceName: "selected"), for: UIControlState.normal)
        paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        checkForWinner()
    }
    
    @IBAction func pButton(_ sender: Any) {
        player1 = 1 // paper
        paperButton.setBackgroundImage(#imageLiteral(resourceName: "selected"), for: UIControlState.normal)
        rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        checkForWinner()
    }
    
    @IBAction func sButton(_ sender: Any) {
        player1 = 2 // scissors
        scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "selected"), for: UIControlState.normal)
        paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        checkForWinner()
    }
    
    func winAlert(msg: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            let alert = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) {(action) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3)
                {
                    self.updateDisplay()
                }
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            self.player1 = 10
        }
        
    }
    
    func checkForWinner() {
        timer.invalidate()
        var winLoseMessage = "The computer chose "
        switch player2{
        case 0:
            winLoseMessage += "rock. "
        case 1:
            winLoseMessage += "paper. "
        case 2:
            winLoseMessage += "scissors. "
        default: break
        }
        if (player1 == 0 && player2 == 2) || (player1 == 1 && player2 == 0) || (player1 == 2 && player2 == 1) {
            winAlert(msg: "\(winLoseMessage)You won!")
            //bgView.backgroundColor = UIColor.green
            
                
                //self.bgView.backgroundColor = self.defaultColor
        }
        if (player2 == 0 && player1 == 2) || (player2 == 1 && player1 == 0) || (player2 == 2 && player1 == 1) {
            winAlert(msg: "\(winLoseMessage)You Lose!")
            //bgView.backgroundColor = UIColor.red
            
                //self.bgView.backgroundColor = self.defaultColor
        }
        if (player1 == player2) {
            winAlert(msg: "\(winLoseMessage)It's tie!")
            
        }
    }
    
}
