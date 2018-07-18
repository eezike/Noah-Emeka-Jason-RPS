//
//  ViewController.swift
//  Rock-Paper-Scissors
//
//  Created by Jason Dong on 7/16/18.
//  Copyright © 2018 Jason Dong. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CloudKit


class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    
    @IBOutlet weak var fireImagge: UIImageView!
    /*
     rock is 0
     paper is 1
     scissors are 2
     */
    
    
    @IBOutlet weak var opponentImage: UIImageView!
    @IBOutlet weak var connectionButton: UIButton!
    
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var scissorsButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    @IBOutlet weak var readyButton: UIButton!
    
    let moveNames = ["Rock", "Paper", "Scissor"]
    
    var msg = "" //this is recieved String
    var player1: Int = 10
    var player2: Int = 11
    var meReady = false
    var counter = 0
    let defaultColor = UIColor(red: 255/255, green: 140/255, blue: 0, alpha: 1)
    
    var peerID:MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!
    
    //==========================================
    //Fire Animation
    var fireAnimation = [UIImage]()
    var gifTimer = Timer()
    var cycle = 0.0
    var index = 0
    func resetTimer()
    {
        cycle = 0.07
        gifTimer.invalidate()
        gifTimer = Timer.scheduledTimer(timeInterval: cycle, target: self, selector: #selector(updateDisplay), userInfo: nil, repeats: true)
    }
    
    @objc func updateDisplay()
    {
        resetTimer()
        index += 1
        if index == 23
        {
            index = 0
        }
        fireImagge.image = fireAnimation[index]
    }
    //==========================================
    
    @IBOutlet weak var bgView: UIView!
    
    @IBAction func rButton(_ sender: Any)
    {
        if !meReady && mcSession.connectedPeers.count > 0
        {
            if(player1 != 0){
                player1 = 0 //rock
                rockButton.setBackgroundImage(#imageLiteral(resourceName: "selected"), for: UIControlState.normal)
                paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
            }
            else{
                player1 = 10 //nothing
                rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
            }
        }
    }
    @IBAction func pButton(_ sender: Any)
    {
        if !meReady && mcSession.connectedPeers.count > 0
        {
            if(player1 != 1){
                player1 = 1 // paper
                paperButton.setBackgroundImage(#imageLiteral(resourceName: "selected"), for: UIControlState.normal)
                rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
            }
            else{
                player1 = 10 //nothing
                rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
            }
        }
    }
    @IBAction func sButton(_ sender: Any)
    {
        if !meReady && mcSession.connectedPeers.count > 0
        {
            if(player1 != 2){
                player1 = 2 // scissors
                scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "selected"), for: UIControlState.normal)
                paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
            }
            else{
                player1 = 10 //nothing
                rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
            }
        }
    }
    
    @IBAction func readyButton(_ sender: Any)
    {
        if player1 != 10 && !meReady
        {
            meReady = true //disables buttons
            var sendMsg = ""
            
            switch player1
            {
            case 0:
                sendMsg = "rock"
            case 1:
                sendMsg = "paper"
            case 2:
                sendMsg = "scissors"
            default:
                break
            }
            updateDisplay() //start fire
            
            
            //==============================================
            //Send choice to other player
            let message = sendMsg.data(using: String.Encoding.utf8, allowLossyConversion: false)
            let _: NSError?
            do
            {
                try self.mcSession.send(message!,toPeers: self.mcSession.connectedPeers, with: .reliable)
            }
            catch
            {
                print ("Error sending data")
            }
            //==============================================
            
            if (msg != "")
            {
                switch msg
                {
                case "rock":
                    player2 = 0
                    opponentImage.image = #imageLiteral(resourceName: "rock")
                case "paper":
                    player2 = 1
                    opponentImage.image = #imageLiteral(resourceName: "paper")
                case "scissors":
                    player2 = 2
                    opponentImage.image = #imageLiteral(resourceName: "scissors")
                default:
                    break
                }
                fireImagge.image = #imageLiteral(resourceName: "transparent-square-tiles")
                gifTimer.invalidate()
                checkForWinner()
            }
        }
        
        
        
    }
    
    func winAlert(msg: String)
    {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            let alert = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                {
                    self.bgView.backgroundColor = self.defaultColor
                    alert.dismiss(animated: true, completion: nil)
                }
                self.player2 = 11
                self.player1 = 10
                self.msg = ""
                self.opponentImage.image = #imageLiteral(resourceName: "transparent-square-tiles")
                self.meReady = false
                self.paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                self.rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                self.scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)

            
        }
        
    }
    
    func checkForWinner() {
        if (player1 == 0 && player2 == 2) || (player1 == 1 && player2 == 0) || (player1 == 2 && player2 == 1) {
            bgView.backgroundColor = UIColor.green
            winAlert(msg: "You won!")
           
            
        }
        if (player2 == 0 && player1 == 2) || (player2 == 1 && player1 == 0) || (player2 == 2 && player1 == 1) {
            bgView.backgroundColor = UIColor.red
            winAlert(msg: "You Lose!")
            
        }
        if (player1 == player2) {
            winAlert(msg: "It's tie!")
        }
    }
    
    @IBAction func showConnectivityActions(_ sender: Any) {
        let actionSheet = UIAlertController(title: "RPS Game!", message: "Do you want to Host or Join a game?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Game", style: .default, handler: { (action:UIAlertAction) in
            
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ba-td", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Game", style: .default, handler: { (action:UIAlertAction) in
            let mcBrowser = MCBrowserViewController(serviceType: "ba-td", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.connectionButton.setImage(#imageLiteral(resourceName: "link"), for: .normal)
            }
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.connectionButton.setImage(#imageLiteral(resourceName: "disconnected"), for: .normal)
            }        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            self.msg = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) as! String
            if self.meReady
            {
                switch self.msg
                {
                case "rock":
                    self.player2 = 0
                    self.opponentImage.image = #imageLiteral(resourceName: "rock")
                case "paper":
                    self.player2 = 1
                    self.opponentImage.image = #imageLiteral(resourceName: "paper")
                case "scissors":
                    self.player2 = 2
                    self.opponentImage.image = #imageLiteral(resourceName: "scissors")
                default:
                    break
                }
                self.fireImagge.image = #imageLiteral(resourceName: "transparent-square-tiles")
                self.gifTimer.invalidate()
                self.checkForWinner()
            }
            else
            {
                switch self.msg
                {
                case "rock":
                    self.player2 = 0
                case "paper":
                    self.player2 = 1
                case "scissors":
                    self.player2 = 2
                default:
                    break
                }
            }
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        opponentImage.image = #imageLiteral(resourceName: "transparent-square-tiles")
        connectionButton.setImage(#imageLiteral(resourceName: "disconnected"), for: .normal)
        //================================
        for index in 0...23{
            fireAnimation.append(UIImage(named: "fire\(index)")!)
            
        }
       //==================================
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

