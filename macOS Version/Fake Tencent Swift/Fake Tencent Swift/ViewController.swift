//
//  ViewController.swift
//  Fake Tencent Swift
//
//  Created by 李欣 on 2017/9/23.
//  Copyright © 2017年 李欣. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var usernameLogin: NSTextField!
    @IBOutlet weak var passwordLogin: NSSecureTextField!
    @IBOutlet weak var rememberUser: NSImageView!
    @IBOutlet weak var autoLogin: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func loginToServer(_ sender: Any) {
        // Server Login Codes Here
        
    }

}

