//
//  HelpViewController.swift
//  rockPaperScissorsUI
//
//  Created by Noah Rubin on 7/18/18.
//  Copyright © 2018 Noah Rubin. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var images = [#imageLiteral(resourceName: "Copy of Bluetooth Connect (1)"), #imageLiteral(resourceName: "Connect Bluetooth Example"), #imageLiteral(resourceName: "Host and Join Game"), #imageLiteral(resourceName: "Select Object and Press Ready"), #imageLiteral(resourceName: "Win and Lose")]
    var currentImage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        currentImage = 0
        imageView.image = images[currentImage]
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextImage(_ sender: UIButton) {
        print("CurrentImg: \(String(currentImage))")
        if(currentImage < images.count-1){ //not the last image
            currentImage += 1 //adds one to current
            imageView.image = images[currentImage] //displays
            
        }
        else if(currentImage == images.count - 1){
            performSegue(withIdentifier: "goBack", sender: self) //go back to the ViewController
        }
    }
    
    @IBAction func backImage(_ sender: UIButton) {
        if(currentImage > 0){ //if its not the first image
            currentImage -= 1 //move back
            imageView.image = images[currentImage] //displays
            
        }
        else if(currentImage == 0){
            performSegue(withIdentifier: "goBack", sender: self) //goes back to the ViewController
        }
    }

}
