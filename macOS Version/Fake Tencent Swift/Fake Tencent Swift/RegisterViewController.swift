//
//  RegisterViewController.swift
//  Fake Tencent Swift
//
//  Created by 李欣 on 2017/9/23.
//  Copyright © 2017年 李欣. All rights reserved.
//

import Cocoa

class RegisterViewController: NSViewController {

    @IBOutlet weak var TermsAndConditionsBox: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // TermsAndConditionsBox.Text
    }
    
    @IBAction func agreeAndDismiss(_ sender: Any) {
        self.dismissViewController(self)
    }
    @IBAction func submitAndRegister(_ sender: Any) {
        // Server Communicate Code Here
        
        self.dismissViewController(self)
        
    }
}
