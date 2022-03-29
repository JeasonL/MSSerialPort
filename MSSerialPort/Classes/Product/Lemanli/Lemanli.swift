//
//  Lemanli.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/26.
//

import Foundation

/**
 *************************
 ***      乐满利        ***
 *************************
 */
public struct Lemanli {
    /**
     *************************
     ***      风琴帘        ***
     *************************
     */
    public struct AccordionCurtain: LemanliProtocol {
        public init() { }

        /// 控制组
        /// - Parameters:
        ///   - id: 组ID
        ///   - action: 操作
        private func groupControl(_ id: Int, action: Action) -> Bytes {
            var command = Bytes(repeating: 0, count: 6)
            command[0] = 0x9A.toByte()
            command[1] = id.toByte()
            command[2] = 0x01.toByte()
            command[3] = 0x00.toByte()
            command[4] = Types.controlCommand.rawValue
            command[5] = action.rawValue
            return command
        }

        /// 所有风琴帘合上 --- 到达上限位(帘是关闭的，但窗是打开的)
        public func groupToUp(id: Int) -> Bytes {
            let command = groupControl(id, action: .up)
            return check(command)
        }

        /// 所有风琴帘停止
        public func groupToStop(id: Int) -> Bytes {
            let command = groupControl(id, action: .stop)
            return check(command)
        }

        /// 所有风琴帘展开 --- 到达下限位(帘是展开的，但窗是关闭的)
        public func groupToDown(id: Int) -> Bytes {
            let command = groupControl(id, action: .down)
            return check(command)
        }

        /// 窗帘控制
        /// - Parameters:
        ///   - id: 设备id
        ///   - action: 操作
        private func control(_ id: Byte, action: Action) -> Bytes {
            var command = Bytes(repeating: 0, count: 6)
            command[0] = 0x9A.toByte()
            command[1] = id
            command[2] = 0x80.toByte()
            command[3] = 0
            command[4] = Types.controlCommand.rawValue
            command[5] = action.rawValue
            return check(command)
        }

        /// 上行指令
        public func toUp(id: Byte) -> Bytes {
            return control(id, action: .up)
        }

        /// 停止指令
        public func toStop(id: Byte) -> Bytes {
            return control(id, action: .stop)
        }

        /// 下行指令
        public func toDown(id: Byte) -> Bytes {
            return control(id, action: .down)
        }

        /// 查询状态 (ID对应才返回数据)
        public func queryStateFromId(id: Byte) -> Bytes {
            var command = Bytes(repeating: 0, count: 6)
            command[0] = 0x9A.toByte()
            command[1] = id
            command[2] = 0x80.toByte()
            command[3] = 0
            command[4] = Types.QueryState.rawValue
            command[5] = 0
            return check(command)
        }

        /// 查询状态(不管ID，直接返回数据)
        public func queryState() -> Bytes {
            var command = Bytes(repeating: 0, count: 6)
            command[0] = 0x9A.toByte()
            command[1] = 0
            command[2] = 0
            command[3] = 0
            command[4] = Types.QueryState.rawValue
            command[5] = Action.stop.rawValue
            return check(command)
        }

        /// 设置设备ID
        /// 设置成功后，电机会正反转动一下
        public func setDeviceID(id: Byte) -> Bytes {
            var command = Bytes(repeating: 0, count: 6)
            command[0] = 0x9A.toByte()
            command[1] = id
            command[2] = 0x80.toByte()
            command[3] = 0
            command[4] = Types.settingID.rawValue
            command[5] = Action.study.rawValue
            return check(command)
        }

        /// 指定设备运行到指定位置
        public func runToValue(id: Byte, percent: Int) -> Bytes {
            var command = Bytes(repeating: 0, count: 6)
            command[0] = 0x9A.toByte()
            command[1] = id
            command[2] = 0x80.toByte()
            command[3] = 0
            command[4] = Types.runLocation.rawValue
            command[5] = percent.toByte()
            return check(command)
        }

        /// 设置/保存位置
        /// /* 暂时不支持指令设置 */
        private func settingPoint(_ id: Byte, action: Action) -> Bytes {
            var command = Bytes(repeating: 0, count: 6)
            command[0] = 0x9A.toByte()
            command[1] = id
            command[2] = 0
            command[3] = 0
            command[4] = Types.settingPoint.rawValue
            command[5] = action.rawValue
            return check(command)
        }

        /// 设置上限位
        /// /* 暂时不支持指令设置 */
        public func setUpLimit(id: Byte) -> Bytes {
            return settingPoint(id, action: .up)
        }

        /// 设置中间限位
        /// /* 暂时不支持指令设置 */
        public func setCenterLimit(id: Byte) -> Bytes {
            return settingPoint(id, action: .stop)
        }

        /// 设置下限位
        /// /* 暂时不支持指令设置 */
        public func setDownLimit(id: Byte) -> Bytes {
            return settingPoint(id, action: .down)
        }

        /// 保存限位点
        /// /* 暂时不支持指令设置 */
        public func saveLimit(id: Byte) -> Bytes {
            return settingPoint(id, action: .study)
        }
    }
}

extension Lemanli {
    /// 指令类型
    public enum Types: Byte {
        /// 控制指令
        case controlCommand = 0x0A
        /// 指定运行位置
        case runLocation = 0xDD
        /// 参数/功能设定
        case SettingParams = 0xD5
        /// 状态查询
        case QueryState = 0xCC
        /// 设置ID/频道
        case settingID = 0xAA
        /// 删所有ID/频道
        case deleteID = 0xA6
        /// 设定最高转速
        case settingRPM = 0xD9
        /// 设定限位点
        case settingPoint = 0xDA
    }

    /// 操作类型
    public enum Action: Byte {
        // 上行
        case up = 0xDD
        // 停止
        case stop = 0xCC
        // 下行
        case down = 0xEE
        // 学码
        case study = 0xAA
        // 删码
        case delete = 0xA6
    }

    /// 指令校验
    public struct CRC {
        /// 指令校验码
        /// D6 = D1.xor(D2).xor(D3).xor(D4).xor(D5)
        static func xor(_ bytes: Bytes) -> Byte {
            var result: Byte = 0
            for index in 1 ..< bytes.count {
                result = result ^ bytes[index]
            }
            return result
        }
    }
}

internal protocol LemanliProtocol: ThirdPartyProtocol {}

extension LemanliProtocol {
    internal func check(_ bytes: Bytes) -> Bytes {
        let code = Lemanli.CRC.xor(bytes)
        var command = Bytes(repeating: 0, count: bytes.count + 1)
        command.replaceSubrange(0 ..< bytes.count, with: bytes)
        command[bytes.count] = code
        return command
    }
}

extension LemanliProtocol where Self == Lemanli.AccordionCurtain {
    internal var describe: String {
        return "乐满利 - 风琴帘(蜂巢帘)"
    }
}
