//
//  ViewController.swift
//  shapeauthstoryboard
//
//  Created by Joshua Sylvester on 7/14/21.
//

import UIKit

class ViewController: UIViewController {

    let imgView = UIImageView()
    
    let nextScreenButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 80))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // VIEW
        let view = UIView()
        view.backgroundColor = .white
        
        // WELCOME LABEL
        let welcomeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 80))
        welcomeLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        welcomeLabel.font = welcomeLabel.font.withSize(22)
        welcomeLabel.lineBreakMode = .byWordWrapping
        welcomeLabel.numberOfLines = 3
        welcomeLabel.center = CGPoint(x: self.view.center.x, y: 150)
        welcomeLabel.textAlignment = .center
        welcomeLabel.textColor = .black
        welcomeLabel.text = "Welcome to the 7339 Authenticator"
        self.view.addSubview(welcomeLabel)
        
        // INSTRUCTION LABEL
        let instructionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 160))
        instructionLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        instructionLabel.font = welcomeLabel.font.withSize(16)
        instructionLabel.lineBreakMode = .byWordWrapping
        instructionLabel.numberOfLines = 3
        instructionLabel.center = CGPoint(x: self.view.center.x, y: 230)
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .black
        instructionLabel.text = "Press the below button and draw a shape with your phone. This will set your shape login credentials."
        self.view.addSubview(instructionLabel)

        // TRAIN BUTTON
        let evaluateShapeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 80))
        evaluateShapeButton.backgroundColor = .gray
        evaluateShapeButton.setTitle("Press and Perform Motion", for: .normal)
        evaluateShapeButton.center = CGPoint(x: self.view.center.x, y:700)
        evaluateShapeButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        evaluateShapeButton.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
        self.view.addSubview(evaluateShapeButton)
        
        // NEXT SCREEN BUTTON
        nextScreenButton.backgroundColor = .gray
        nextScreenButton.setTitle("Test Shape", for: .normal)
        nextScreenButton.center = CGPoint(x: self.view.center.x, y:800)
        nextScreenButton.addTarget(self, action: #selector(nextScreenButtonDown), for: .touchDown)


        imgView.frame = CGRect(x: 200, y: 200, width: 200, height: 200)
        imgView.center = CGPoint(x: self.view.center.x, y:  self.view.center.y - 50)
        self.view.addSubview(imgView)//Add image to our view
    }
    

    @objc func buttonDown(sender: UIButton!) {
        print("Button pressed")
        // if we have time we should replace with an actual spinner
        imgView.image = UIImage(named: "engineering.png")//Assign image to ImageView
    }

    @objc func buttonUp(sender: UIButton!) {
        print("Button pressed")
        imgView.image = UIImage(named: "check.png") // If the shape was recorded
//        imgView.image = UIImage(named: "cancel.png") // If something screwed up
        
        self.view.addSubview(nextScreenButton) // Show the next button
    }

    
    @objc func nextScreenButtonDown(sender: UIButton!) {
        print("pressed the navigate button")
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "View Controller2") as! ViewController2
//        self.navigationController?.pushViewController(secondViewController, animated: true)
        self.present(secondViewController, animated:true, completion:nil)
    }
}

