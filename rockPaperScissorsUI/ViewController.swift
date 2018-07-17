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
    
    
    /*
     rock is 0
     paper is 1
     scissors are 2
     */
    
    
    @IBOutlet weak var opponentImage: UIImageView!
    
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var scissorsButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    
    let moveNames = ["Rock", "Paper", "Scissor"]
    
    var player1: Int = 10
    var player2: Int = 10 //11
    var opponentImgVar = #imageLiteral(resourceName: "transparent-square-tiles")
    var meReady = false
    var counter = 0
    //var rock2 = #imageLiteral(resourceName: "rock")
    //var paper2 = #imageLiteral(resourceName: "paper")
    //var scissors2 = #imageLiteral(resourceName: "scissors")
    
    var peerID:MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!
    
    
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
        let message = "".data(using: String.Encoding.utf8, allowLossyConversion: false)
        let _: NSError?
        do{
            try self.mcSession.send(message!,toPeers: self.mcSession.connectedPeers, with: .reliable)
        }
        catch{
            print ("Error sending data")
        }
        print("Self: \(player1)")
        print("P2: \(player2)")
        meReady = true
        switch player1{
        case 0:
            sendChoice(#imageLiteral(resourceName: "rock"))
        case 1:
            sendChoice(#imageLiteral(resourceName: "paper"))
        case 2:
            sendChoice(#imageLiteral(resourceName: "scissors"))
        default: break
        }
        
        
        if(player1 != 10){
            opponentImage.image = opponentImgVar
            print("Image: \(opponentImgVar) Is Eq: \(#imageLiteral(resourceName: "rock"))")
            if(opponentImgVar.isEqual(UIImagePNGRepresentation(#imageLiteral(resourceName: "rock")))){ player2 = 0}
            else if(opponentImgVar.isEqual(UIImagePNGRepresentation(#imageLiteral(resourceName: "paper")))){ player2 = 1}
            else if(opponentImgVar.isEqual(UIImagePNGRepresentation(#imageLiteral(resourceName: "scissors")))){ player2 = 2}
            else{ player2 = 100}
//            switch opponentImgVar{
//            case #imageLiteral(resourceName: "rock"):
//                player2 = 0
//            case #imageLiteral(resourceName: "paper"):
//                player2 = 1
//            case #imageLiteral(resourceName: "scissors"):
//                player2 = 2
//            default: player2 = 100
//            }
            print("Self: \(player1)")
            print("P2: \(player2)")
            checkForWinner()
        }
    }

    func winAlert(msg: String)
    {
        meReady = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            let alert = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            self.player2 = 10
        }
        opponentImage.image = #imageLiteral(resourceName: "transparent-square-tiles")
        
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
    
    func sendChoice (_ img: UIImage) {
        if mcSession.connectedPeers.count > 0 {
            if let imageData =  UIImagePNGRepresentation(img){
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                }catch{
                    fatalError("Could not send todo item")
                }
            }
        }else{
            print("you are not connected to another device")
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
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            let msg = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
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
        opponentImage.image = opponentImgVar
        counter = 0
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

