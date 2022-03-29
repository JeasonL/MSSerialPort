//
//  ThirdPartyProtocol.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/25.
//

import Foundation

internal protocol ThirdPartyProtocol {
    /// 产品描述
    var describe: String { get }
    
    /// 指令校验
    func check(_ bytes: Bytes) -> Bytes
}
