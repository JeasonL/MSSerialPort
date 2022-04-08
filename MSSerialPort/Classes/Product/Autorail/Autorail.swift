//
//  Autorail.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/26.
//

import Foundation

/**
 *************************
 ***      奥特威        ***
 *************************
 */
public struct Autorail {
    /**
     *************************
     ***      梦幻帘        ***
     *************************
     */
    public struct DreamCurtain: AutorailProtocol {
        public init() { }
        
        /**
          * 设置id
          *
          * 设备ID为大端模式，低位在前，高位在后
          * 执行写设备地址前，先按住电机设置键 5 秒，等蜂鸣两次后之后松开按键，成功后电机会转动提示。
          * 默认地址为 0xFEFE（恢复出厂设置）
          * 0x0000 == >> 0
          * 0x00FF == >> 255
          * 0xFF00 == >> 65280
          * 0xFFFF == >> 0
          * - Parameter id: 大端模式,低位在前,高位在后; 高低位均不能为 0x00 和 0xFF
         */
        public func setID(id: Int) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                0,
                0,
                Mode.write.rawValue,
                0,
                0x02,
                _id[0],
                _id[1],
            ]
            return check(command)
        }

        /// 设置角度系数
        /// - Parameters:
        ///   - coefficient: 角度系数 0~255
        public func setAngleCoefficient(id: Int, coefficient: Byte) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.write.rawValue,
                0x08,
                0x01,
                coefficient,
            ]
            return check(command)
        }

        /// 设置角度
        /// - Parameters:
        ///   - angle: 角度 0 ~ 180
        public func setAngle(id: Int, angle: Byte) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.control.rawValue,
                0x04,
                0xFF.toByte(),
                angle,
            ]
            return check(command)
        }

        /// 设置运行位置以及角度
        public func setPercentAndAngle(id: Int, percent: Int, angle: Byte) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.control.rawValue,
                0x04,
                percent.to2ByteLittle()[0],
                angle,
            ]
            return check(command)
        }

        /// 设置设备的方向
        /// - Parameters:
        ///   - isDefault true:默认方向  false:反方向
        public func setDeviceDirection(id: Int, isDefault: Bool) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.write.rawValue,
                0x03,
                0x01,
                isDefault ? 0 : 1,
            ]
            return check(command)
        }

        /// 控制命令-打开
        public func on(id: Int) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.control.rawValue,
                0x01,
            ]
            return check(command)
        }

        /// 控制命令-关闭
        public func off(id: Int) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.control.rawValue,
                0x02,
            ]
            return check(command)
        }

        /// 控制命令-关闭
        public func stop(id: Int) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.control.rawValue,
                0x03,
            ]
            return check(command)
        }

        /// 运行至百分比
        public func runPercent(id: Int, percent: Int) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.control.rawValue,
                0x04,
                percent.to2ByteLittle()[0],
            ]
            return check(command)
        }

        /// 读取百分比
        public func readPercent(id: Int) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.read.rawValue,
                0x02,
                0x01,
            ]
            return check(command)
        }

        /// 读取方向状态
        public func readDirection(id: Int) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.read.rawValue,
                0x03,
                0x01,
            ]
            return check(command)
        }

        /// 读取设备类型
        public func readDeviceType(id: Int) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.read.rawValue,
                0xF0.toByte(),
                0x01,
            ]
            return check(command)
        }

        /// 读取角度
        public func readAngle(id: Int) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.read.rawValue,
                0x06,
                0x01,
            ]
            return check(command)
        }

        /// 读取当前角度系数
        public func readAngleCoefficient(id: Int) -> Bytes {
            let _id = id.to2ByteBig()
            let command: Bytes = [
                0x55,
                _id[0],
                _id[1],
                Mode.read.rawValue,
                0x08,
                0x01,
            ]
            return check(command)
        }
    }
}

extension Autorail {
    /// 功能模式
    enum Mode: Byte {
        /// 读指令
        case read = 0x01
        /// 写指令
        case write = 0x02
        /// 控制指令
        case control = 0x03
        /// 从机请求指令，主机返回
        case back = 0x04
    }

    /// 指令校验
    struct CRC {
        /// Crc校验
        /// 生成Int,之后转Bytes
        private static func rtu(bytes: Bytes) -> Int {
            var crc = 0xFFFF
            let crcpoly = 0xA001
            var crcBit: Int = 0
            bytes.forEach { src in
                crc = crc ^ (Int(src) & 0xFF)
                for _ in 0 ..< 8 {
                    crcBit = crc & 0x01
                    crc = crc >> 1
                    if crcBit == 1 {
                        crc = crc ^ crcpoly
                    }
                }
            }
            return crc
        }

        /// Crc校验
        /// - Returns: 低位前,高位后
        static func rtu2Little(bytes: Bytes) -> Bytes {
            return rtu(bytes: bytes).to2ByteLittle()
        }

        ///  Crc校验
        /// - Returns: 高位前，低位后
        static func rtu2Big(bytes: Bytes) -> Bytes {
            return rtu(bytes: bytes).to2ByteBig()
        }
    }
}

internal protocol AutorailProtocol: ThirdPartyProtocol {}

extension AutorailProtocol where Self == Autorail.DreamCurtain {
    internal var describe: String {
        return "奥特威 - 梦幻帘(彩虹帘) - 广州市奥特威电机有限公司 - 广州市白云区竹料大道西3号 - www.autorail.cn"
    }

    internal func check(_ bytes: Bytes) -> Bytes {
        let code = Autorail.CRC.rtu2Little(bytes: bytes)
        let command = bytes + code
        return command
    }
}
