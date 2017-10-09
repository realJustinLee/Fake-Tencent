//
//  ysocket.swift
//  Fake Tencent iOS alpha
//
//  Created by 李欣 on 2017/9/20.
//  Copyright © 2017年 李欣. All rights reserved.
//

import Foundation
open class YSocket{
    var addr:String
    var port:Int
    var fd:Int32?
    init(){
        self.addr=""
        self.port=0
    }
    public init(addr a:String,port p:Int){
        self.addr=a
        self.port=p
    }
}
