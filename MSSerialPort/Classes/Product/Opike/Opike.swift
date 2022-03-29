//
//  Opike.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/23.
//
/*
      数据格式：采用二进制数据传送，一次传送一帧,每帧长度固定为12Bytes。
      数据帧定义：
 ---------------------------------------------------------------------------------------------
         Byte        字段      长度（byte）        说明
   -------------------------------------------------------------------------------------------
         1,2         帧头          2            0XA55A（低字节在前）
   -------------------------------------------------------------------------------------------
         3          设备地址        1            0x00代表广播地址
   -------------------------------------------------------------------------------------------
         4,5          DP          2            2字节,低字节在前
   -------------------------------------------------------------------------------------------
         6            Cmd         1            0x01：读出
                                               0x02：应答
                                               0x03：写入
   -------------------------------------------------------------------------------------------
         7-10        数据          4            4字节，表示数据或命令的具体内容，低字节在前
   -------------------------------------------------------------------------------------------
         11,12      校验和         2            2字节，从帧头开始按字节求和得出的结果, 低字节在前
 ---------------------------------------------------------------------------------------------
     采用二进制数据传送，一次传送一帧,每帧长度固定为12Bytes。
  */

import Foundation

/**
 *************************
 ***      欧派克        ***
 *************************
 */
public struct Opike {
    /**
     *************************
     ***     电动巴士门      ***
     *************************
     */
    public struct BusDoor: OpikeProtocol {
        /// CMD
        public enum Cmd: Byte {
            /// 0x01 - 读出
            case read = 0x01
            /// 0x02 - 应答
            case reply = 0x02
            /// 0x03 - 写入
            case write = 0x03
        }

        /// 设备类型
        public enum Types: Byte {
            /// 0x00 - 未定义
            case unknown = 0x00
            /// 0x01 - 磁悬浮单开门
            case maglevSingle = 0x01
            /// 0x02 - 磁悬浮对开门
            case maglevDouble = 0x02
            /// 0x03 - 单平躺门
            case slidingSingle = 0x03
            /// 0x04 - 双平躺门
            case slidingDouble = 0x04
            /// 0x05 - 单自由折叠门
            case foldingSingle = 0x05
            /// 0x06 - 双自由折叠门
            case foldingDouble = 0x06
        }

        /**
         控制
         * none - 0x00 - 无动作
         * open - 0x01 - 开门
         * close - 0x02 - 关门
         * stop - 0x03 - 暂停
         * lock - 0x04 - 上锁
         * unlock - 0x05 - 解锁
         */
        public enum Ctrl: Byte {
            /// 0x00 - 无动作
            case none = 0x00
            /// 0x01 - 开门
            case open = 0x01
            /// 0x02 - 关门
            case close = 0x02
            /// 0x03 - 暂停
            case stop = 0x03
            /// 0x04 - 上锁
            case lock = 0x04
            /// 0x05 - 解锁
            case unlock = 0x05
        }

        public var describe: String {
            return "欧派克智能产品--电动巴士门"
        }

        // 广播地址Byte
        private let broadcastByte: Byte = 0x00

        /// 初始化设备
        public func device(id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x05 // 0x01, 0x01-0xFF, 0x00为广播地址, 用于查询设备地址
            // command[4] = 0x00
            command[5] = Cmd.write.rawValue
            command[6] = 0x01
            return check(command)
        }

        /// 初始化广播设备
        public func broadcastDevice() -> Bytes {
            return device(id: broadcastByte)
        }

        /// 发送广播获取地址
        public func broadcastAddress() -> Bytes {
            var command = emptyCommand
            command[2] = broadcastByte
            command[3] = 0x01
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /**
          发送广播获取设备类型
          - 返回结果:
             - 0x00：未定义
             - 0x01：单磁悬浮门
             - 0x02：磁悬浮对开门
             - 0x03：单平躺门
             - 0x04：双平躺门
             - 0x05：单自由折叠门
             - 0x06：双自由折叠门
         */
        public func broadcastGetType() -> Bytes {
            var command = emptyCommand
            command[2] = broadcastByte
            command[3] = 0x02
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /// 获取设备类型
        public func getType(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x02
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /// 广播设置设备ID
        /// - Parameter id: 设备ID
        public func broadcastSetID(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = broadcastByte
            command[3] = 0x01
            // command[4] = 0x00
            command[5] = Cmd.write.rawValue
            command[6] = id
            return check(command)
        }

        /// 设置设备新ID
        /// - Parameters:
        ///   - oldID: 旧ID
        ///   - newID: 新ID
        public func setID(oldID: Byte, newID: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = oldID
            command[3] = 0x01
            // command[4] = 0x00
            command[5] = Cmd.write.rawValue
            command[6] = newID
            return check(command)
        }

        /**
          获取设备状态
         * 一共4个Byte，每个Byte对应一扇门，共4扇，最低位Byte对应门1
         * 获取的数据格式：[帧头][帧头][设备地址][DP][DP][Cmd][门1][门2][门3][门4][校验][校验]
         * 其中[门1][门2][门3][门4]，每帧转换8位二进制Bit：[7][6][5][4][3][2][1][0]
         * Bit0...Bit5（取值后转换成十六进制）：
            * 0x00：门初始化中
            * 0x01：门已关闭
            * 0x02：门开启中
            * 0x03：门已打开
            * 0x04：门关闭中
            * 0x05：门暂停
         * Bit6：上锁状态
            * 0：未上锁
            * 1：已上锁
         * Bit7：报警状态
            * 0：无报警
            * 1：有报警
         * 例：[门1][门2][门3][门4] 对应值 [0x41][0x02][0x02][0x41] -> [关闭][开启][开启][关闭]
            * 0x41 -> 0100 0001
                * 第0-5位 "000001" -> 0x01 表示门已关闭,
                * 第6位 "1" 表示已上锁
                * 第7位 "0" 表示无报警
            * 0x02 -> 0000 0010
                * 第0-5位 "000010" -> 0x02 表示门开启中,
                * 第6位 "1" 表示已上锁
                * 第7位 "0" 表示无报警
          */
        public func getState(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x03
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /// 控制门
        /// - Parameters:
        ///   - id: 设备id
        ///   - d: 门动作
        public func control(_ id: Byte, d1: Ctrl, d2: Ctrl, d3: Ctrl, d4: Ctrl) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x04
            // command[4] = 0x00
            command[5] = Cmd.write.rawValue
            command[6] = d1.rawValue
            command[7] = d2.rawValue
            command[8] = d3.rawValue
            command[9] = d4.rawValue
            return check(command)
        }

        /// 获取运行速度
        public func getSpeed(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x10
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /// 设置运行速度
        /// - Parameters:
        ///   - id: 设备id
        ///   - speed: 速度 1 - 100
        public func setSpeed(_ id: Byte, speed: Int) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x10
            // command[4] = 0x00
            command[5] = Cmd.write.rawValue
            command[6] = speed.toByte()
            return check(command)
        }

        /**
         * 开门时间
         */
        public func getOpenTime(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x11
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /**
         * 是否自动关门
         */
        public func getIsAutoClose(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x12
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /**
         * 设置是否自动关门
         */
        public func setAutoClose(_ id: Byte, auto: Bool) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x12
            // command[4] = 0x00
            command[5] = Cmd.write.rawValue
            if auto {
                command[6] = 0x01
            } else {
                command[6] = 0x00
            }

            return check(command)
        }

        /**
         * 是否开门换向
         */
        public func getIsReversal(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x13
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /**
         * 是否开门换向
         */
        public func setReversal(_ id: Byte, isReversal: Bool) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x13
            // command[4] = 0x00
            command[5] = Cmd.write.rawValue
            command[6] = UInt8(isReversal.int)
            return check(command)
        }

        /**
         * 是否自动上锁
         */
        public func getIsAutoLock(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x14
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /**
         * 是否门头感应
         */
        public func getIsSense(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x15
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /**
         * 是否保持力
         */
        public func getIsForce(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x16
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /**
         * 是否中门同步
         */
        public func getIsSyncCenter(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x17
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /**
         * 设置中门同步
         */
        public func setSyncCenter(_ id: Byte, sync: Bool) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x17
            // command[4] = 0x00
            command[5] = Cmd.write.rawValue
            command[6] = UInt8(sync.int)
            return check(command)
        }

        /**
         * 是否边门同步
         */
        public func getDeviceIsSyncSide(_ id: Byte) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x18
            // command[4] = 0x00
            command[5] = Cmd.read.rawValue
            return check(command)
        }

        /**
         * 设置边门同步
         */
        public func setSyncSide(_ id: Byte, sync: Bool) -> Bytes {
            var command = emptyCommand
            command[2] = id
            command[3] = 0x18
            // command[4] = 0x00
            command[5] = Cmd.write.rawValue
            command[6] = UInt8(sync.int)
            return check(command)
        }
    }
}

extension Opike {
    /// 指令校验
    struct CRC {
        /// 校验发送的指令
        /// - 从帧头开始按字节求和得出的结果, 低字节在前
        static func check(bytes: Bytes) -> Bytes {
            let sum = bytes.map { $0.toIntU() }.sum()
            let check = sum.to2ByteLittle()
            var result = Bytes(repeating: 0, count: bytes.count + check.count)
            result.replaceSubrange(0 ..< bytes.count, with: bytes)
            result.replaceSubrange(bytes.count ..< check.count, with: check)
            return result
        }
    }
}

protocol OpikeProtocol: ThirdPartyProtocol {
    /// 帧头
    var frameHead: Bytes { get }

    /// 获取空指令，只有头部格式的数据, 长度:10
    var emptyCommand: Bytes { get }
}

extension OpikeProtocol {
    var frameHead: Bytes {
        ["5A", "A5"].toByte()
    }

    var emptyCommand: Bytes {
        var bytes = Bytes(repeating: 0, count: 10)
        bytes.replaceSubrange(0 ..< frameHead.count, with: frameHead)
        return bytes
    }

    public func check(_ bytes: Bytes) -> Bytes {
        return Opike.CRC.check(bytes: bytes)
    }
}
