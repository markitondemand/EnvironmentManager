//
//  ViewController.swift
//  Example
//
//  Created by Michael Leber on 2/24/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import UIKit
import MDEnvironmentManager

class ViewController: UIViewController {
    let environmentManager = EnvironmentManager()
    @IBOutlet var serviceOneEnvLabel: UILabel!
    @IBOutlet var serviceTwoEnvLabel: UILabel!
    
    @IBOutlet var serviceOneBaseAPILabel: UILabel!
    @IBOutlet var serviceTwoBaseAPILabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.environmentManager.add(apiName: "Service1", environmentUrls: [("acc", URL(string: "acc.api.serv1.com")!), ("preprod", URL(string: "preprod.api.serv2.com")!), ("prod", URL(string: "prod.api.serv1.com")!)])
        self.environmentManager.add(apiName: "Service2", environmentUrls: [("acc", URL(string: "acc.api.serv2.com")!), ("preprod", URL(string: "preprod.api.serv2.com")!), ("prod", URL(string: "prod.api.serv2.com")!)])
        
        self.serviceOneEnvLabel.text = self.environmentManager.currentEnvironmentFor(apiName: "Service1")
        self.serviceTwoEnvLabel.text = self.environmentManager.currentEnvironmentFor(apiName: "Service2")
        self.serviceOneBaseAPILabel.text = self.environmentManager.baseUrl(apiName: "Service1")?.absoluteString
        self.serviceTwoBaseAPILabel.text = self.environmentManager.baseUrl(apiName: "Service2")?.absoluteString
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.EnvironmentDidChange, object: nil, queue: nil) { (notif: Notification) in
            let api = notif.userInfo?[EnvironmentChangedKeys.APIName] as! String
            let newEnv = notif.userInfo?[EnvironmentChangedKeys.NewEnvironment] as! String
            
            switch api {
            case "Service1":
                self.serviceOneEnvLabel.text = newEnv
                self.serviceOneBaseAPILabel.text = self.environmentManager.baseUrl(apiName: "Service1")?.absoluteString
            case "Service2":
                self.serviceTwoEnvLabel.text = newEnv
                self.serviceTwoBaseAPILabel.text = self.environmentManager.baseUrl(apiName: "Service2")?.absoluteString
            default:
                print("unexpected")
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // stuff
        print("prepare for storyboard segue")
        if let segue = segue as? EnvironmentManagerSegue {
            segue.pass(environmentManager: self.environmentManager)
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

