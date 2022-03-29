//
//  MSNIOClient.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/23.
//

import CryptoSwift
import Foundation
import NIO
import MSSerialPort

extension Notification.Name {
    static let IsActive = Notification.Name(rawValue: "IsActive")
}

class MSNIOClient {
    var activeClosure: ((Bool) -> Void)?
    
    private var bootstrap: ClientBootstrap
    private var channel: Channel?

    var host: String = "localhost"
    var port: Int = 8080

    init(host: String, port: Int) {
        self.host = host
        self.port = port
        let workGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
//        defer {
//            try! workGroup.syncShutdownGracefully()
//        }
        bootstrap = ClientBootstrap(group: workGroup)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_KEEPALIVE), value: 1)
            .channelInitializer { ch in
                ch.pipeline.addHandlers([ByteToMessageHandler(MSNIOClientDecoder()), MSNIOClientHandler()])
            }
    }

    func connect() {
        do {
            channel = try bootstrap.connect(host: host, port: port).wait()
//            try channel?.closeFuture.wait()
            print("已连接")
        } catch {
            print(error)
        }
    }

    func shutdown() {
        _ = channel?.close()
        channel = nil
        print("连接已断开")
    }

    func send(_ bytes: Bytes) {
        let datas = ByteBuffer(bytes: bytes)
        _ = channel?.writeAndFlush(NIOAny(datas))
    }
}

class MSNIOClientHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    func channelActive(context: ChannelHandlerContext) {
        print("活跃")
        NotificationCenter.default.post(name: .IsActive, object: true)
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        print("不活跃")
        NotificationCenter.default.post(name: .IsActive, object: false)
    }
    
//    func channelRegistered(context: ChannelHandlerContext) {
//        print("已注册")
//    }
//
//    func channelUnregistered(context: ChannelHandlerContext) {
//        print("未注册")
//    }
    
    func channelReadComplete(context: ChannelHandlerContext) {
        print("读取成功")
    }
    
    func channelWritabilityChanged(context: ChannelHandlerContext) {
        print("写入变更")
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer: ByteBuffer = unwrapInboundIn(data)
        if let bytes = buffer.readBytes(length: buffer.readableBytes) {
            let results = bytes.map { i -> String in
                var value = String(Int(i), radix: 16)
                if value.count < 2 {
                    value = "0" + value
                }
                return value.uppercased()
            }
            print("回调:\(results)")
        } else {
            print("转换失败")
        }
//                _ = context.close()
    }
}

class MSNIOClientDecoder: ByteToMessageDecoder {
    typealias InboundOut = ByteBuffer

    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        // Swift 的 Int 默认是 Int64
        if buffer.readableBytes < 8 {
            return .needMoreData
        }
        // 需要我们主动取出需要的部分，并调用 fireChannelRead 来让下一个 handler 处理
        let slice = buffer.readSlice(length: 8)!
        context.fireChannelRead(wrapInboundOut(slice))
        return .continue
    }
}
