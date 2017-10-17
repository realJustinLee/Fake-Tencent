//
//  ViewController.swift
//  Fake Tencent Server macOS
//
//  Created by 李欣 on 2017/10/17.
//  Copyright © 2017年 李欣. All rights reserved.
//

import Cocoa
import SwiftSocket

class ViewController: NSViewController {
    
    @IBOutlet weak var logView: NSScrollView!
    
    //socket服务端封装类对象
    var socketServer: MyTcpSocketServer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func startServer(_ sender: Any){
        //启动服务器
        self.logOnScreen(msg: "Hello")
        socketServer = MyTcpSocketServer()
        socketServer?.start()
    }
    
    @IBAction func stopServer(_ sender: Any) {
        socketServer?.stop()
    }
    
    func logOnScreen(msg:String){
        /// TODO: Add text to NSScrollView
        // let logString = NSMutableAttributedString(string: msg)
        logView.insertText(msg)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

