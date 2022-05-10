//
//  ForickCRC.swift
//  MSSwiftNIO
//
//  Created by Jeason Lee on 2022/3/23.
//

import Foundation

/**
 *************************
 ***      弗雷克        ***
 *************************
 */
public struct Forick {
    /**
     *************************
     ***     三合一面板      ***
     *************************
     */
    public struct TriadPanel: ForickProtocol {
        public init() { }

        /// 模式
        public enum Mode: Int {
            /// 空调
            case aircon = 1
            /// 地暖
            case heating = 2
            /// 新风
            case freshAir = 3
        }

        /// 空调模式
        public enum AirconMode: Int {
            /// 制冷
            case cool = 0
            /// 制热
            case warm = 1
            /// 除湿
            case wet = 2
            /// 送风
            case wind = 3
        }

        /// 风速
        public enum WindSpeed: Int {
            /// 自动
            case auto = 0
            /// 低速
            case low = 1
            /// 中速
            case middle = 2
            /// 高速
            case high = 3
        }

        /// 获取三选一面板当前的状态
        public var currentStatus: Bytes {
            return [TCType.STATUS_GET.rawValue]
        }

        /// 接收通知的时间限制
        public var notifyTime: Bytes {
            return [TCType.GET_NOTIFY.rawValue]
        }

        /**
         * 设置多少秒内空调状态变化会主动往外发消息
         * @param time [INT_MAX_POWER_OF_TWO]
         */
        public func setNotify(time: Int) -> Bytes {
            var command = Bytes(repeating: 0, count: 5)
            command[0] = TCType.SET_NOTIFY.rawValue
            let timeArray = time.to4ByteLittle()
            command.replaceSubrange(1 ..< command.count, with: timeArray)
            return command
        }

        /// 设置面板模式
        /// - Parameter mode:  01 空调  02 地暖 03 新风
        public func setPanelMode(mode: Mode) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.WORK_MODE.rawValue
            Forick.shortToByteBE(input: mode.rawValue, output: &command, offset: 2)
            return command
        }

        /// 设置空调开关机
        /// - Parameter isSwitch: false是关机  true是开机
        public func setAircon(isSwitch: Bool) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.AC_ONOFF.rawValue
            Forick.shortToByteBE(input: isSwitch.int, output: &command, offset: 2)
            return command
        }

        /// 设置空调模式
        /// - Parameter mode: 00：制冷  01：制热 02：除湿 03：送风
        public func setAircon(mode: AirconMode) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.AC_MODE.rawValue
            Forick.shortToByteBE(input: mode.rawValue, output: &command, offset: 2)
            return command
        }

        /// 设置空调风速
        /// - Parameter speed: 0:自动 1:低速 2:中速 3:高速
        public func setAircon(speed: WindSpeed) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.AC_SPEED.rawValue
            if speed == .auto {
                Forick.shortToByteBE(input: 256, output: &command, offset: 2)
            } else {
                Forick.shortToByteBE(input: speed.rawValue, output: &command, offset: 2)
            }
            return command
        }

        /// 设置空调的制冷/制热的温度
        /// - Parameter temperature: 10℃~32℃之间
        public func setAircon(temperature: Int) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.AC_TEMPERATURE.rawValue
            Forick.shortToByteBE(input: temperature * 10, output: &command, offset: 2)
            return command
        }

        /// 设置空调继电器的控制模式
        /// (空调的优先级高) 自控是面板内部逻辑控制开关，被控是通过指令控制开关，不过这个被控你们应该是没做处理的，都是采用我们面板内部逻辑控制
        /// - Parameter relay:  继电器
        ///  1: 一路双线阀或一路三线阀（一控）默认
        ///  2: 一路三线阀（二控）
        ///  3: 两路双线阀或一路三线阀（一控）
        public func setAircon(relay: Int) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.AC_RELAY.rawValue
            command[2] = 0x01
            command[3] = relay.to2ByteLittle()[0]
            return command
        }

        /// 设置地暖开关机
        /// - Parameter isSwitch: false是关机  true是开机
        public func setHeating(isSwitch: Bool) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.FH_ONOFF.rawValue
            Forick.shortToByteBE(input: isSwitch.int, output: &command, offset: 2)
            return command
        }

        /// 设置地暖温度
        /// - Parameter temperature: 10℃~32℃之间
        public func setHeating(temperature: Int) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.FH_TEMPERATURE.rawValue
            Forick.shortToByteBE(input: temperature * 10, output: &command, offset: 2)
            return command
        }

        /// 设置地暖保护温度
        /// - Parameter temperature: 1℃~5℃之间
        public func setHeatingProtection(temperature: Int) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.FH_PROTECT_TEMP.rawValue
            Forick.shortToByteBE(input: temperature * 10, output: &command, offset: 2)
            return command
        }

        /// 设置新风开关机
        /// - Parameter isSwitch: false是关机  true是开机
        public func setFreshAir(isSwitch: Bool) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.FA_ONOFF.rawValue
            Forick.shortToByteBE(input: isSwitch.int, output: &command, offset: 2)
            return command
        }

        /// 设置新风风速
        /// - Parameter speed: 1:低速 2:中速 3:高速
        public func setFreshAir(speed: WindSpeed) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.FA_SPEED.rawValue
            Forick.shortToByteBE(input: speed.rawValue, output: &command, offset: 2)
            return command
        }

        /// 环境参数 温度补偿（实时温度修正）
        /// -9℃ ~ 9℃ 整数位有效
        /// 00H ~ 09H 代表  0℃ ~ 9℃
        /// F7H ~ FFH 代表  -9℃ ~ -1℃
        /// - Parameter: temperature 修正温度的值 范围: -9 ~ 9
        /// [temp]:(小 ---->> 大) [-9 , 9]
        /// -9 ==> F7  -8 ==> F8    -7 ==> F9    -6 ==> FA    -5 ==> FB    -4 ==> FC    -3 ==> FD    -2 ==> FE    -1 ==> FF
        ///  0 ==> 00  1 ==> 01  2 ==> 02     3 ==> 03     4 ==> 04     5 ==> 05     6 ==> 06     7 ==> 07     8 ==> 08    9 ==> 09
        public func setComp(temperature: Int) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.COMP_TEMP.rawValue
            Forick.shortToByteBE(input: temperature * 10, output: &command, offset: 2)
            return command
        }

        /// 背光休眠时间
        /// - Parameter duration: 有7个等级
        ///     0: 30秒,
        ///     1-5: 1-5分钟,
        ///     6:不休眠
        public func setBackground(duration: Int) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.BG_DURATION.rawValue
            if duration == 0 {
                Forick.shortToByteBE(input: 30, output: &command, offset: 2)
            } else if (1 ... 5).contains(duration) {
                Forick.shortToByteBE(input: duration * 60, output: &command, offset: 2)
            } else {
                Forick.shortToByteBE(input: 65535, output: &command, offset: 2)
            }
            return command
        }

        /// 背光亮度
        /// - Parameters:
        ///   - lightness: 屏幕的亮度，值：35 45 55 65 75 85
        ///   - keyLightness: 唤醒时，按键灯的亮度，值：35 45 55 65 75 85
        public func setBackground(lightness: Int, keyLightness: Int) -> Bytes {
            var command = Bytes(repeating: 0, count: 4)
            command[0] = TCType.SET.rawValue
            command[1] = Types.BG_LIGHTNESS.rawValue
            command[2] = (keyLightness & 0xFF).toByte()
            command[3] = (lightness & 0xFF).toByte()
            return command
        }
    }
}

extension Forick {
    /// 指令类型
    public enum Types: Byte {
        case WORK_MODE = 0x00

        case AC_ONOFF = 0x01
        case AC_MODE = 0x02
        case AC_SPEED = 0x03
        case AC_TEMPERATURE = 0x04
        case AC_VALVE = 0x05
        case AC_RELAY = 0x06

        case FH_ONOFF = 0x07
        case FH_TEMPERATURE = 0x08
        case FH_VALVE = 0x09
        case FH_RELAY = 0x0A
        case FH_PROTECT_TEMP = 0x0B

        case FA_ONOFF = 0x0C
        case FA_SPEED = 0x0D
        case FA_RELAY = 0x0E

        case COMP_TEMP = 0x0F
        case ENV_TEMP = 0x10
        case ENV_HUMIDITY = 0x11

        case LOW_TEMP = 0x12

        case BG_DURATION = 0x13
        case BG_LIGHTNESS = 0x14
    }

    static let VENDOROP_TC: UInt16 = 0x7FB0 // tc = temperature control

    public enum TCType: Byte {
        case STATUS_GET = 0x00
        case STATUS_RET = 0x01
        case SET = 0x02
        case SET_RESULT = 0x03

        case GET_NOTIFY = 0x04
        case SET_NOTIFY = 0x05
        case RET_NOTIFY = 0x06
    }

    public static func byteToShortBE(input: Bytes, offset: Int) -> Int8 {
        return Int8((input[0 + offset] & 0xff) << 8 | input[1 + offset] & 0xff)
    }

    public static func shortToByteBE(input: Int, output: inout Bytes, offset: Int) {
        output[0 + offset] = (input >> 8).toByte()
        output[1 + offset] = input.toByte()
    }

    public func tcStatus(_ type: Types, data: UInt16) {
        switch type {
        case .WORK_MODE:
            print("WORK MODE " + String(data))
            break
        case .AC_ONOFF:
            print("AC ONOFF " + String(data & 0x0F))
            break
        case .AC_MODE:
            print("AC MODE " + String(data & 0x0F))
            break
        case .AC_SPEED:
            print("AC SPEED " + String(data & 0x0F) + ", AUTO " + String(isBitSet(Int(data), bit: 8)))
            break
        case .AC_TEMPERATURE:
            print("AC TEMPERATURE " + String(Float(data) / 10.0))
            break
        case .AC_VALVE:
            print("AC VALVE " + String(data))
            break
        case .AC_RELAY:
            print("AC RELAY " + String(data))
            break
        case .FH_ONOFF:
            print("FH ONOFF " + String(data & 0x0F))
            break
        case .FH_TEMPERATURE:
            print("FH TEMPERATURE " + String(Float(data) / 10.0))
            break
        case .FH_VALVE:
            print("FH VALVE " + String(data))
            break
        case .FH_RELAY:
            print("FH RELAY " + String(data))
            break
        case .FH_PROTECT_TEMP:
            print("FH PROTECT TEMP " + String(Float(data) / 10.0))
            break
        case .FA_ONOFF:
            print("acStatus FA ONOFF " + String(data))
            break
        case .FA_SPEED:
            print("FA SPEED " + String(data))
            break
        case .FA_RELAY:
            print("FA RELAY " + String(data))
            break
        case .COMP_TEMP:
            print("COMP TEMPERATURE " + String(Float(data) / 10.0))
            break
        case .ENV_TEMP:
            print("ENV TEMPERATURE " + String(Float(data) / 10.0))
            break
        case .ENV_HUMIDITY:
            print("ENV HUMIDITY " + String(data))
            break
        case .LOW_TEMP:
            print("LOW TEMPERATURE " + String(Float(data) / 10.0))
            break
        case .BG_DURATION:
            print("BG DURATION " + String(data))
            break
        case .BG_LIGHTNESS:
            print("BG LIGHTNESS " + String((data >> 8) & 0xFF) + ", " + String(data & 0xFF))
            break
        }
    }

    private func isBitSet(_ mask: Int, bit: Int) -> Bool {
        return 0 != (mask & 1 << bit)
    }
}

internal protocol ForickProtocol: ThirdPartyProtocol {}

extension ForickProtocol where Self == Forick.TriadPanel {
    internal var describe: String {
        return "弗雷克三选一温控面板--蓝牙版本--佩林协议"
    }

    internal func check(_ bytes: Bytes) -> Bytes {
        return []
    }
}
