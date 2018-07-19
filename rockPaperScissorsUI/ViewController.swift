//
//  ViewController.swift
//  Rock-Paper-Scissors
//
//  Created by Jason Dong, Noah Rubin, Emeka Ezike on 7/16/18.
//  Copyright © 2018 Jason Dong, Noah Rubin, Emeka Ezike. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CloudKit
import AudioToolbox.AudioServices
import AVFoundation

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    
    @IBOutlet weak var fireImagge: UIImageView!
    @IBOutlet weak var opponentImage: UIImageView!
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var scissorsButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var tauntImage: UIImageView!
    @IBOutlet weak var winLoseLabel: UILabel!
    
    /*
     rock is 0
     paper is 1
     scissors are 2
     */
    var msg = "" //this is recieved String
    var player1: Int = 10 //10 is nothing
    var player2: Int = 11 //11 is nothing (10 != 11)
    var meReady = false //once you press ready, you can't change your answer (use: line 86)
    var connected = false //for images
    var wins = 0
    var losses = 0 //for the record on bottom right
    let defaultColor = UIColor(red: 255/255, green: 140/255, blue: 0, alpha: 1) //the screen background (custom orange color)
    var hosting = false //Making sure that you aren't hosting more than one session at once
    
    //multipeer connection
    var peerID:MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!
    
    var pop = SystemSoundID(4095) //vibration when you TAUNT!
    var audioPlayer: AVAudioPlayer?
    
    //========================================== FIRE
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
    //========================================== FIRE
    
    @IBOutlet weak var bgView: UIView! //the background that changes color when you win or lose
    
    func deselect ()  //sets player1 to 10(nothing) and sets background to blank
    {
        player1 = 10 //nothing
        rockButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
        scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
    }
    
    //========================================== SELECTION
    @IBAction func rButton(_ sender: Any)
    {
        print("regular tap")
        if !meReady && mcSession.connectedPeers.count > 0 //If you are connected to someone and have not selected ready
        {
            if(player1 != 0){ //if player1 is not ALREADY rock then select rock
                player1 = 0 //rock
                rockButton.setBackgroundImage(#imageLiteral(resourceName: "selected"), for: UIControlState.normal)
                paperButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                scissorsButton.setBackgroundImage(#imageLiteral(resourceName: "transparent-square-tiles"), for: UIControlState.normal)
                playSoundWithFileName(file: "Sounds/rock", fileExt: ".mp3")
            }
            else{ //they are rock -> they want deselect
                deselect ()
            }
        }
        else if mcSession.connectedPeers.count <= 0 { helpDisplay()}
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
                playSoundWithFileName(file: "Sounds/paper", fileExt: ".mp3")
            }
            else{
                deselect ()
            }
        }
        else if mcSession.connectedPeers.count <= 0 { helpDisplay()}
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
                playSoundWithFileName(file: "Sounds/scissors", fileExt: ".mp3")
            }
            else
            {
                deselect ()
            }
        }
        else if mcSession.connectedPeers.count <= 0 { helpDisplay()}
    }
    //========================================== SELECTION
    
    //========================================== TAUNT
    @IBAction func rTaunt(_ sender: UIButton) { //resease on exit -> swipe out of the button, drag button to corner
        if !meReady && mcSession.connectedPeers.count > 0 {
            AudioServicesPlaySystemSound(pop) //VIBRATE
            send (sendMessage: "Rock T") //TAUNT MESSAGE, treated differently in recieve message function
        }
    }
    
    @IBAction func pTaunt(_ sender: UIButton) {
        if !meReady && mcSession.connectedPeers.count > 0 {
            AudioServicesPlaySystemSound(pop)
            send (sendMessage: "Paper T")
        }
    }
    
    @IBAction func sTaunt(_ sender: UIButton) {
        if !meReady && mcSession.connectedPeers.count > 0 {
            AudioServicesPlaySystemSound(pop)
            send (sendMessage: "Scissors T")
        }
    }
    //========================================== TAUNT
    
    //========================================== READY
    @IBAction func readyButton(_ sender: Any)
    {
        if player1 != 10 && !meReady //if its not already Readyed and you have selected something
        {
            meReady = true //disables buttons
            var sendMsg = "" //creates a var
            
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
            send (sendMessage: sendMsg)
            //==============================================
            
            if (msg != "") //you have recieved something from Player2
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
                fireImagge.image = #imageLiteral(resourceName: "transparent-square-tiles") //extinguish fire
                gifTimer.invalidate()
                checkForWinner()
            }
        }
    }
    
    func send (sendMessage: String) //multipeer
    {
        let message = sendMessage.data(using: String.Encoding.utf8, allowLossyConversion: false) //encode the message into type Data
        let _: NSError?
        do
        {
            try self.mcSession.send(message!,toPeers: self.mcSession.connectedPeers, with: .reliable)
            //attempts to send a message if it fails goes to catch
        }
        catch
        {
            print ("Error sending data")
        }
    }
    
    func checkForWinner() {
        if (player1 == 0 && player2 == 2) || (player1 == 1 && player2 == 0) || (player1 == 2 && player2 == 1) { //win cases
            bgView.backgroundColor = UIColor.green
            winAlert(msg: "You won!")
           wins += 1
            
        }
        if (player2 == 0 && player1 == 2) || (player2 == 1 && player1 == 0) || (player2 == 2 && player1 == 1) { //lose cases
            bgView.backgroundColor = UIColor.red
            winAlert(msg: "You Lose!")
            losses += 1
            
        }
        if (player1 == player2) {
            winAlert(msg: "It's tie!")
            losses += 1
        }
        winLoseLabel.text = "\(wins)/\(wins+losses)" //sets record at bottom right
    }
    
    func winAlert(msg: String)
    {
        playSoundWithFileName(file: "Sounds/win", fileExt: ".mp3")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        { //delays alert so you can see results
            let alert = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
            { //auto takes away the alert and chnges background color
                self.bgView.backgroundColor = self.defaultColor //orange
                alert.dismiss(animated: true, completion: nil)
            }
            //===================== RESET
            self.player2 = 11
            self.player1 = 10
            self.msg = ""
            self.opponentImage.image = #imageLiteral(resourceName: "transparent-square-tiles")
            self.meReady = false
            self.deselect()
            self.tauntImage.image = #imageLiteral(resourceName: "transparent-square-tiles")
            //===================== RESET
        }
    }
    
    @IBAction func showConnectivityActions(_ sender: Any) { //when you click the connect button at the top of the screen\
        if !connected && !hosting //if you are NOT connected and NOT hosting, you can choose to host or join a game
        {
            let actionSheet = UIAlertController(title: "RPS Game!", message: "Do you want to Host or Join a game?", preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Host Game", style: .default, handler: { (action:UIAlertAction) in
                
                self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ur-gay", discoveryInfo: nil, session: self.mcSession)
                self.mcAdvertiserAssistant.start()
                self.hosting = true
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Join Game", style: .default, handler: { (action:UIAlertAction) in
                let mcBrowser = MCBrowserViewController(serviceType: "ur-gay", session: self.mcSession)
                mcBrowser.delegate = self
                self.present(mcBrowser, animated: true, completion: nil)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(actionSheet, animated: true, completion: nil)
        }
        else if hosting{ //if you are already hosting :
            let hostingAlert = UIAlertController(title: "You are hosting", message: "would you like to disconnect?", preferredStyle: .alert)
            hostingAlert.addAction(UIAlertAction(title: "Disconnect", style: .destructive, handler: { (action:UIAlertAction) in
                self.mcSession.disconnect()
                DispatchQueue.main.async {
                    self.connectionButton.setImage(#imageLiteral(resourceName: "disconnected"), for: .normal)
                    self.performSegue(withIdentifier: "backToHome", sender: self)
                }
                self.connected = false
            }))
            hostingAlert.addAction(UIAlertAction(title: "Keep Hosting", style: .default, handler: nil))
            self.present(hostingAlert, animated: true, completion: nil)
        }
        
        else //you joined and want to leave
        {
            print("GOT TO ELSE")
            let dActionSheet = UIAlertController(title: "Disconnect", message: "Are you sure you want to disconnect?", preferredStyle: .actionSheet)
            
            dActionSheet.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action:UIAlertAction) in
                self.mcSession.disconnect()
                DispatchQueue.main.async {
                    self.connectionButton.setImage(#imageLiteral(resourceName: "disconnected"), for: .normal)
                    self.performSegue(withIdentifier: "backToHome", sender: self)
                }
                self.connected = false
            }))
            dActionSheet.addAction(UIAlertAction(title: "Keep Playing!", style: .default, handler: nil))
            self.present(dActionSheet, animated: true, completion: nil)
        }
    }

    //====================================
    //Multipeer functions
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.connectionButton.setImage(#imageLiteral(resourceName: "link"), for: .normal)
                self.connected = true
                print("connected")
            }
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.connectionButton.setImage(#imageLiteral(resourceName: "disconnected"), for: .normal)
                self.connected = false
                
            }
            
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) { //recieved something!
        
        DispatchQueue.main.async {
            self.msg = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) as! String
            switch self.msg{ //DID YOU RECIEVE A TAUNT?
            case "Rock T":
                self.tauntImage.image =  #imageLiteral(resourceName: "rock")
            case "Paper T":
                self.tauntImage.image = #imageLiteral(resourceName: "paper")
            case "Scissors T":
                self.tauntImage.image = #imageLiteral(resourceName: "scissors")
            default:
                self.tauntImage.image = #imageLiteral(resourceName: "transparent-square-tiles")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
                self.tauntImage.image = #imageLiteral(resourceName: "transparent-square-tiles") //turns off taunt after .7 secs
            }
            if self.meReady //if you are ready to display the oppents sent image:
            {
                switch self.msg
                {
                case "rock":
                    self.player2 = 0
                    self.opponentImage.image = #imageLiteral(resourceName: "rock")
                    self.fireImagge.image = #imageLiteral(resourceName: "transparent-square-tiles")
                    self.gifTimer.invalidate()
                    self.checkForWinner()
                case "paper":
                    self.player2 = 1
                    self.opponentImage.image = #imageLiteral(resourceName: "paper")
                    self.fireImagge.image = #imageLiteral(resourceName: "transparent-square-tiles")
                    self.gifTimer.invalidate()
                    self.checkForWinner()
                case "scissors":
                    self.player2 = 2
                    self.opponentImage.image = #imageLiteral(resourceName: "scissors")
                    self.fireImagge.image = #imageLiteral(resourceName: "transparent-square-tiles")
                    self.gifTimer.invalidate()
                    self.checkForWinner()
                default:
                    break
                }

            }
            else //NOT YET CHOSEN AND READYED UP
            {
                switch self.msg
                {
                case "rock":
                    self.player2 = 0 //store the number , when you click ready it will be displayed and your choice will be sent
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
        peerID = MCPeerID(displayName: UIDevice.current.name) //your display name
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required) //no security
        mcSession.delegate = self
        opponentImage.image = #imageLiteral(resourceName: "transparent-square-tiles")
        connectionButton.setImage(#imageLiteral(resourceName: "disconnected"), for: .normal)
        connected = false
        //================================
        //For fire animation
        for index in 0...23{
            fireAnimation.append(UIImage(named: "fire\(index)")!)
            
        }
        self.tauntImage.image = #imageLiteral(resourceName: "transparent-square-tiles")
       //==================================
        wins = 0
        losses = 0
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func helpDisplay(){
        let helpAlert = UIAlertController(title: "You are not connected to another player.", message: nil, preferredStyle: .alert)
        helpAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        helpAlert.addAction(UIAlertAction(title: "Help", style: .default)
        {(action) in self.performSegue(withIdentifier: "alertToHelp", sender: self)}) //GOES TO HELPVIEWCONTROLLER
        self.present(helpAlert, animated: true, completion: nil)
    }
    
    //====================== SOUNDS
    func playSoundWithFileName(file: String, fileExt: String)-> Void {
        let audioSourceURL: URL!
        audioSourceURL = Bundle.main.url(forResource: file, withExtension: fileExt)
        if audioSourceURL == nil{
            print("No Audio")
        }
        else{
            do {
                audioPlayer = try AVAudioPlayer.init(contentsOf: audioSourceURL!)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch{
                print(error)
            }
        }
    }
    //====================== SOUNDS
}

