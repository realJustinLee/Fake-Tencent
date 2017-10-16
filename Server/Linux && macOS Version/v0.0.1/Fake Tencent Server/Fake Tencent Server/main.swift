//
//  main.swift
//  Fake Tencent Server
//
//  Created by 李欣 on 2017/10/9.
//  Copyright © 2017年 李欣. All rights reserved.
//

import Foundation

func localCmdHandler(cmd: String) {
    /// TODO: 根据指令做出回应
}

var server: TcpSocketServer?
server = TcpSocketServer()
server?.start()

while true {
    var cmd: String = ""
    /// TODO: 接受用户输入

    localCmdHandler(cmd: cmd)
}
