//
//  TCPChatBundle.swift
//  Fake Tencent Server
//
//  Created by 李欣 on 2017/10/9.
//  Copyright © 2017年 李欣. All rights reserved.
//

import Foundation
import Dispatch

/// 服务器地址设定
// let serverAddress = "127.0.0.1" // "139.129.46.224"

/// 定义服务器端口
let serverPort: Int32 = 5005

/// TCP 服务端类
class TcpSocketServer: NSObject {
    var clients: [ChatUser] = []
    var server: TCPServer = TCPServer(address: "127.0.0.1", port: serverPort)
    var serverRunning: Bool = false

    /// 启动服务
    func start() {
        _ = server.listen()
        self.serverRunning = true

        DispatchQueue.global(qos: .background).async {
            while self.serverRunning {
                let client = self.server.accept()
                if let clientCopy = client {
                    DispatchQueue.global(qos: .background).async {
                        self.handleClient(client: clientCopy)
                    }
                }
            }
        }
        self.log(msg: "[+] Server Established")
    }


    /// 停止服务
    func stop() {
        self.serverRunning = false
        _ = self.server.close()
        /// 强制关闭所有客户端 socket
        for client: ChatUser in self.clients {
            client.kill()
        }
        self.log(msg: "[-] Server Eliminated")
    }

    /// 处理连接的客户端
    func handleClient(client: TCPClient) {
        /// TODO: 按照IP地址分类LOG，并写成单独文件。
        self.log(msg: "[+] New Client from: " + client.address)
        let user = ChatUser()
        user.tcpClient = client
        clients.append(user)
        user.socketServer = self
        user.messageLoop()
    }

    /// 处理客户端发来的指令
    func processUserMsg(user: ChatUser, msg: [String: Any]) {
        self.log(msg: "\(user.username)[\(user.tcpClient!.address)] cmd: " + (msg["cmd"] as! String))
        /// 广播收到的信息
        var msgToSend = [String: String]()
        let cmd = msg["cmd"] as! String
        /// TODO: 按照标准化命令交互改造此部分,添加:注册,登陆,等功能
        if cmd == "username" {
            if cmd == "username" {
                msgToSend["cmd"] = "join"
                msgToSend["username"] = user.username
                msgToSend["address"] = user.tcpClient!.address
            } else if (cmd == "msg") {
                msgToSend["cmd"] = "msg"
                msgToSend["from"] = user.username
                msgToSend["content"] = (msg["content"] as! String)
            } else if (cmd == "leave") {
                msgToSend["cmd"] = "leave"
                msgToSend["username"] = user.username
                msgToSend["address"] = user.tcpClient!.address
            }
            for user: ChatUser in self.clients {
                user.sendMsg(msg: msgToSend)
            }
        }

    }

    func removeUser(user: ChatUser) {
        self.log(msg: "remove user\(user.tcpClient!.address)")
        if let suspectIndex = self.clients.index(of: user) {
            self.clients.remove(at: suspectIndex)
            self.processUserMsg(user: user, msg: ["cmd": "leave"])
        }
    }

    /// 日志打印
    func log(msg: String) {
        /// TODO: 聊天记录功能开发。
        print(msg)
    }
}

/// 客户端管理类 (便于服务端管理所有连接的客户端)
class ChatUser: NSObject {
    var tcpClient: TCPClient?
    var username: String = ""
    var socketServer: TcpSocketServer?

    ///  解析收到的消息
    func readMsg() -> [String: Any]? {
        /// 读取 Int32(4 Byte int) 类型
        if let data = self.tcpClient!.read(4) {
            if data.count == 4 {
                let ndata = NSData(bytes: data, length: data.count)
                var len: Int32 = 0
                ndata.getBytes(&len, length: data.count)
                if let buff = self.tcpClient!.read(Int(len)) {
                    let msgData = Data(bytes: buff, count: buff.count)
                    let msgCmd = (try! JSONSerialization.jsonObject(with: msgData, options: .mutableContainers)) as! [String: Any]
                    return msgCmd
                }
            }
        }
        return nil
    }

    /// 循环接收消息
    func messageLoop() {
        while true {
            if let msg = self.readMsg() {
                self.processMsg(msg: msg)
            } else {
                self.removeMe()
                break
            }
        }
    }

    /// 处理收到的消息
    func processMsg(msg: [String: Any]) {
        if msg["cmd"] as! String == "username" {
            self.username = msg["username"] as! String
        }
        self.socketServer!.processUserMsg(user: self, msg: msg)
    }

    /// 发送消息
    func sendMsg(msg: [String: Any]) {
        let jsonData = try? JSONSerialization.data(withJSONObject: msg, options: JSONSerialization.WritingOptions.prettyPrinted)
        var len: Int32 = Int32(jsonData!.count)
        let data = Data(bytes: &len, count: 4)
        _ = self.tcpClient!.send(data: data)
        _ = self.tcpClient!.send(data: jsonData!)
    }

    /// 移除该客户端
    func removeMe() {
        self.socketServer!.removeUser(user: self)
    }

    /// 关闭连接
    func kill() {
        _ = self.tcpClient!.close()
    }
}
