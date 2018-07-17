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
    
    @IBOutlet weak var rockButton: UIButton!
    
    @IBOutlet weak var scissorsButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    
    let moveNames = ["Rock", "Paper", "Scissor"]
    
    var player1: Int = 10
    var player2: Int = 1 //11
    
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
    
    func sendChoice (_ choice: String) {
        if mcSession.connectedPeers.count > 0 {
            if let choice1 = DataManager.loadData(choice) {
                do {
                    try mcSession.send(choice1, toPeers: mcSession.connectedPeers, with: .reliable)
                }catch{
                    fatalError("Could not send todo item")
                }
            }
        }else{
            print("you are not connected to another device")
        }
    }
    
    @IBAction func showConnectivityActions(_ sender: Any) {
        let actionSheet = UIAlertController(title: "New Game!", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action:UIAlertAction) in
            
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ba-td", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action:UIAlertAction) in
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
        
        do {
            let choice = try JSONDecoder().decode(String.self, from: data)
            
            DataManager.save(choice, with: choice)
            
            DispatchQueue.main.async {
                self.player2 = Int(choice)!
                self.checkForWinner()
            }
            
        }catch{
            fatalError("Unable to process recieved data")
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
        loadData()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loadData(){
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

