//
//  welcomeView.swift
//  hangge_756
//
//  Created by 李欣 on 2017/10/17.
//  Copyright © 2017年 hangge. All rights reserved.
//

import Foundation
import UIKit

class welcomeView: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    var userName:String? = ""
    var passWord:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName = self.username.text
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
