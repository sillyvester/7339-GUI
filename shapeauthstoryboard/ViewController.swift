//
//  ViewController.swift
//  shapeauthstoryboard
//
//  Created by Joshua Sylvester on 7/14/21.
//

import UIKit
import CoreMotion
import CoreML

class ViewController: UIViewController, URLSessionDelegate {

    let imgView = UIImageView()
    
    let SERVER_URL = "http://192.168.1.131:8000"
    
    let nextScreenButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
    
    let changeLabelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
    
    let motion = CMMotionManager()
    
    var timer = Timer()
    
    var acc_x: [Double] = []
    var acc_y: [Double] = []
    var acc_z: [Double] = []
    
    var ctr:Float = 0
    
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        
        return URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }()
    
    let operationQueue = OperationQueue()

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
        evaluateShapeButton.center = CGPoint(x: self.view.center.x, y:500)
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
        imgView.image = UIImage(named: "engineering.png")//Assign image to ImageView\
        
        self.acc_x = []
        self.acc_y = []
        self.acc_z = []
        
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
            self.motion.startAccelerometerUpdates()


            // Configure a timer to fetch the data.
            
            let sensor_timer = Timer(fire: Date(), interval: (1.0/30), repeats: true, block: { (sensor_timer) in
              // Get the accelerometer data.
                if let data = self.motion.accelerometerData {
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z
                    
                    self.acc_x.append(x)
                    self.acc_y.append(y)
                    self.acc_z.append(z)

                 // Use the accelerometer data in your app.
                }
                
                if self.acc_x.count == 90{
                    print("done")
                    sensor_timer.invalidate()
                }

            
            })
            
            RunLoop.current.add(sensor_timer, forMode: .common)
            
        }

    }

    @objc func buttonUp(sender: UIButton!) {
        print("Button pressed")
        imgView.image = UIImage(named: "check.png") // If the shape was recorded
//        imgView.image = UIImage(named: "cancel.png") // If something screwed up
        
        self.view.addSubview(nextScreenButton) // Show the next button
        self.timer.invalidate()
        self.ctr = 0
        
        var sensors:[Double] = []
        
        for sensor in [self.acc_x, self.acc_y, self.acc_z]{
            sensors.append(mean(with: sensor))
            sensors.append(standard_deviation(with: sensor, mean: mean(with: sensor)))
        }
    
        
        //self.sendSample(sensor_data: [-0.07, 1.416, -0.69, 0.17, -0.799, 0.264], data_label: "Vertical")
        //self.sendSample(sensor_data: sensors, data_label: "Horizontal")
        self.predictOne(sensor_data: sensors)
    }

    
    @objc func nextScreenButtonDown(sender: UIButton!) {
        print("pressed the navigate button")
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "View Controller2") as! ViewController2
//        self.navigationController?.pushViewController(secondViewController, animated: true)
        self.present(secondViewController, animated:true, completion:nil)
    }
    
    // Send sample to server
    func sendSample(sensor_data:[Double], data_label: String){
        let baseURL = "\(SERVER_URL)/DoPostExample"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["sensor_data":sensor_data, "label":data_label]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{
                        (data, response, error) in
                        if(error != nil){
                            if let res = response{
                                print("Response:\n",res)
                            }
                        }
                        else{ // no error we are aware of
                            let jsonDictionary = self.convertDataToDictionary(with: data)
                            
                            
                            if let labelResponse = jsonDictionary["prediction"]{
                                print(labelResponse)
                                //self.displayLabelResponse(labelResponse as! String)
                            }

                        }
        })
        
        postTask.resume() // start the task
    }
    
    // Get Prediction
    func predictOne(sensor_data:[Double]){
        let baseURL = "\(SERVER_URL)/PredictOne"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["sensor_data":sensor_data]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{
                        (data, response, error) in
                        if(error != nil){
                            if let res = response{
                                print("Response:\n",res)
                            }
                        }
                        else{ // no error we are aware of
                            let jsonDictionary = self.convertDataToDictionary(with: data)
                            
                            
                            if let labelResponse = jsonDictionary["prediction"]{
                                print(labelResponse)
                                //self.displayLabelResponse(labelResponse as! String)
                            }

                        }
        })
        
        postTask.resume() // start the task
    }
    
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func standard_deviation(with arr:[Double], mean:Double)->Double {
        var sse:Double = 0
        for val in arr{
            sse += pow(abs(val-mean),2)
        }
        sse = sse/Double(arr.count)
        sse = sse.squareRoot()
        return(sse)
    }
    
    func mean(with arr:[Double])->Double{
        return(arr.reduce(0, +)/Double(arr.count))
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            
            if let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                            print("printing JSON received as string: "+strData)
            }else{
                print("json error: \(error.localizedDescription)")
            }
            return NSDictionary() // just return empty
        }
    }
    
    
}

