//
//  ViewController2.swift
//  shapeauthstoryboard
//
//  Created by Joshua Sylvester on 7/24/21.
//

import UIKit

class ViewController2: UIViewController {

    let imgView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // VIEW
        let view = UIView()
        view.backgroundColor = .white
        
        // LABEL
        let welcomeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 80))
        welcomeLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        welcomeLabel.font = welcomeLabel.font.withSize(22)
        welcomeLabel.lineBreakMode = .byWordWrapping
        welcomeLabel.numberOfLines = 2
        welcomeLabel.center = CGPoint(x: self.view.center.x, y: 150)
        welcomeLabel.textAlignment = .center
        welcomeLabel.textColor = .black
        welcomeLabel.text = "Authenticate With Your Shape"
        
        // BUTTON
        let evaluateShapeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 80))
        evaluateShapeButton.backgroundColor = .gray
        evaluateShapeButton.setTitle("Hold and Perform Motion", for: .normal)
        
        evaluateShapeButton.center = CGPoint(x: self.view.center.x, y:700)
        
        evaluateShapeButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        evaluateShapeButton.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])

        
        imgView.frame = CGRect(x: 200, y: 200, width: 200, height: 200)
        imgView.center = CGPoint(x: self.view.center.x, y:  self.view.center.y - 50)
        self.view.addSubview(imgView)//Add image to our view

        self.view.addSubview(welcomeLabel)
        self.view.addSubview(evaluateShapeButton)
    }
    

    @objc func buttonDown(sender: UIButton!) {
        print("Button pressed")
        // if we have time we should replace with an actual spinner
        imgView.image = UIImage(named: "engineering.png")//Assign image to ImageView
    }
    
    @objc func buttonUp(sender: UIButton!) {
        print("Button pressed2")
        imgView.image = UIImage(named: "check.png") // If motion was correct
//        imgView.image = UIImage(named: "cancel.png") // If motion was wrong
    }
    
}
