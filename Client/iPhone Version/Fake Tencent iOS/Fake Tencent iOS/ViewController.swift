//
//  ViewController.swift
//  Fake Tencent iOS
//
//  Created by 李欣 on 2017/9/26.
//  Copyright © 2017年 李欣. All rights reserved.
//

import UIKit
import Dispatch

class ViewController: UIViewController {

    /// TODO: 静态 UI
    //// 登陆界面
    ///// 用户名
    @IBOutlet weak var loginUsername: UITextField!
    ///// 密码
    @IBOutlet weak var loginPassword: UITextField!
    //// 聊天界面
    @IBOutlet weak var chatMsg: UITextField!
    @IBOutlet weak var chatView: UITextView!

    /// socket 服务端封装类对象
    var socketServer: TcpSocketServer?

    /// socket 客户端类对象
    var socketClient: TCPClient?

    /// 服务器地址设定
    let remoteAddress = "127.0.0.1" // "139.129.46.224"

    /// 定义服务器端口
    let remotePort: Int32 = serverPort

    override func viewDidLoad() {
        super.viewDidLoad()

        socketServer = TcpSocketServer()
        socketServer?.start()
        /// 初始化客户端，并连接服务器
        processClientSocket()
    }

    /// 初始化客户端，并连接服务器
    func processClientSocket() {
        socketClient = TCPClient(address: self.remoteAddress, port: self.remotePort)

        DispatchQueue.global(qos: .background).async {
            /// 用于读取并解析服务端发来的消息
            func readMsg() -> [String: Any]? {
                /// 读取 Int32(4 Byte int) 类型
                if let data = self.socketClient!.read(4) {
                    let ndata = NSData(bytes: data, length: data.count)
                    var len: Int32 = 0
                    ndata.getBytes(&len, length: data.count)
                    if let buff = self.socketClient!.read(Int(len)) {
                        let msgData = Data(bytes: buff, count: buff.count)
                        let msgCmd = (try! JSONSerialization.jsonObject(with: msgData, options: .mutableContainers)) as! [String: Any]
                        return msgCmd
                    }
                }
                return nil
            }

            /// 连接服务器
            let connectionStatus: Result = self.socketClient!.connect(timeout: 5)
            if connectionStatus.isSuccess {
                DispatchQueue.main.async {
                    self.alert(msg: "与服务器连接成功", after: {})
                }

                /// 发送用户名给服务器
                /// TODO: 登陆功能代替现在的随机生成
                // let msgToSend = ["cmd": "nickname", "nickname": "游客\(Int(arc4random() % 1000))"]
                let msgToSend = ["cmd": "nickname", "nickname": self.loginUsername.text!]
                self.sendMessage(msgToSend: msgToSend)

                /// 不断接受服务器发来的消息
                while true {
                    if let msg = readMsg() {
                        DispatchQueue.main.async {
                            self.processMessage(msg: msg)
                        }
                    } else {
                        DispatchQueue.main.async {
                            // self.disconnect
                        }
                        break
                    }
                }
            } else {
                DispatchQueue.main.async {
                    var error: String = ""
                    switch connectionStatus.error as! SocketError {
                    case .queryFailed:
                        error = "队列服务器错误"
                    case .connectionClosed:
                        error = "连接关闭"
                    case .connectionTimeout:
                        error = "连接超时"
                    case .unknownError:
                        error = "unknownError"
                    default:
                        error = "未知错误"
                    }
                    self.alert(msg: error, after: {})
                }
            }
        }
    }

    /// TODO: UI 函数
    /// 聊天界面 “发送” 按钮点击
    @IBAction func chatSend(_ sender: Any) {
        let content = chatMsg.text!
        let message = ["cmd": "msg", "content": content]
        self.sendMessage(msgToSend: message)
        chatMsg.text = nil
    }

    /// 发送消息
    func sendMessage(msgToSend: [String: String]) {
        let msgData = try? JSONSerialization.data(withJSONObject: msgToSend, options: .prettyPrinted)
        var len: Int32 = Int32(msgData!.count)
        let data = Data(bytes: &len, count: 4)
        _ = self.socketClient!.send(data: data)
        _ = self.socketClient!.send(data: msgData!)
    }

    /// 处理服务器返回的消息
    func processMessage(msg: [String: Any]) {
        let cmd: String = msg["cmd"] as! String
        switch (cmd) {
        case "msg":
            self.chatView.text = self.chatView.text + (msg["from"] as! String) + ": " + (msg["content"] as! String) + "\n"
        default:
            /// TODO: 开发本地聊天记录功能
            print(msg)
        }
    }

    /// 弹出消息框
    func alert(msg: String, after: () -> (Void)) {
        let alertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)

        /// 1.5 秒后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            alertController.dismiss(animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

