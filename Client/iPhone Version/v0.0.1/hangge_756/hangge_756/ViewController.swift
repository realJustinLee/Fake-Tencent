//
//  ViewController.swift
//  hangge_756
//
//  Created by hangge on 2016/11/21.
//  Copyright © 2016年 hangge. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func username(_ sender: Any) {
    }
    
    //消息输入框
    @IBOutlet weak var textFiled: UITextField!
    //消息输出列表
    @IBOutlet weak var textView: UITextView!

    //socket服务端封装类对象
    var socketServer: MyTcpSocketServer?
    //socket客户端类对象
    var socketClient: TCPClient?

    override func viewDidLoad() {
        super.viewDidLoad()

        //启动服务器
        socketServer = MyTcpSocketServer()
        // socketServer?.start()

        //初始化客户端，并连接服务器
        processClientSocket()
    }

    //初始化客户端，并连接服务器
    func processClientSocket() {
        socketClient = TCPClient(addr: "localhost", port: 8080)

        DispatchQueue.global(qos: .background).async {
            //用于读取并解析服务端发来的消息
            func readmsg() -> [String: Any]? {
                //read 4 byte int as type
                if let data = self.socketClient!.read(4) {
                    if data.count == 4 {
                        let ndata = NSData(bytes: data, length: data.count)
                        var len: Int32 = 0
                        ndata.getBytes(&len, length: data.count)
                        if let buff = self.socketClient!.read(Int(len)) {
                            let msgd = Data(bytes: buff, count: buff.count)
                            let msgi = (try! JSONSerialization.jsonObject(with: msgd,
                                    options: .mutableContainers)) as! [String: Any]
                            return msgi
                        }
                    }
                }
                return nil
            }

            //连接服务器
            let (success, msg) = self.socketClient!.connect(timeout: 5)
            if success {
                DispatchQueue.main.async {
                    self.alert(msg: "connect success", after: {})
                }

                //发送用户名给服务器（这里使用随机生成的）
                // let msgtosend = ["cmd": "nickname", "nickname": "游客\(Int(arc4random() % 1000))"]
                let msgtosend = ["cmd": "nickname", "nickname": "游客\(Int(arc4random() % 1000))"]
                self.sendMessage(msgtosend: msgtosend)

                //不断接收服务器发来的消息
                while true {
                    if let msg = readmsg() {
                        DispatchQueue.main.async {
                            self.processMessage(msg: msg)
                        }
                    } else {
                        DispatchQueue.main.async {
                            //self.disconnect()
                        }
                        break
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.alert(msg: msg, after: {
                    })
                }
            }
        }
    }

    //“发送消息”按钮点击
    @IBAction func sendMsg(_ sender: AnyObject) {
        let content = textFiled.text!
        let message = ["cmd": "msg", "content": content]
        self.sendMessage(msgtosend: message)
        textFiled.text = nil
    }

    //发送消息
    func sendMessage(msgtosend: [String: String]) {
        let msgdata = try? JSONSerialization.data(withJSONObject: msgtosend,
                options: .prettyPrinted)
        var len: Int32 = Int32(msgdata!.count)
        let data = Data(bytes: &len, count: 4)
        _ = self.socketClient!.send(data: data)
        _ = self.socketClient!.send(data: msgdata!)
    }

    //处理服务器返回的消息
    func processMessage(msg: [String: Any]) {
        let cmd: String = msg["cmd"] as! String
        switch (cmd) {
        case "msg":
            self.textView.text = self.textView.text +
                    (msg["from"] as! String) + ": " + (msg["content"] as! String) + "\n"
        default:
            print(msg)
        }
    }

    //弹出消息框
    func alert(msg: String, after: () -> (Void)) {
        let alertController = UIAlertController(title: "",
                message: msg,
                preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)

        //1.5秒后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            alertController.dismiss(animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
