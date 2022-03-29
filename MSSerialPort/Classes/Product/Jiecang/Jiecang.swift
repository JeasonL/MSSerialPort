//
//  Jiecang.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/25.
//

import Foundation
import SwifterSwift

/**
 *************************
 ***        捷昌        ***
 *************************
 */
public struct Jiecang {
    /**
     *************************
     ***      升降吊柜       ***
     *************************
     */
    public struct LiftCabinet: JiecangProtocol {
        private let defaultType = 0x88.toByte()

        /// 控制类型
        public enum Ctrl: Byte {
            /// 0x01 - 续动上运行
            case autoUp = 0x01
            /// 0x02：续动下运行
            case autoDown = 0x02
            /// 0x03：点动上运行
            case clickUp = 0x03
            /// 0x04：点动下运行
            case clickDown = 0x04
            /// 0x05：正常停止
            case stop = 0x05
            /// 0x06：急停
            case fetchUp = 0x06
            /// 0x07：运行至记忆1
            case memory1 = 0x07
            /// 0x08：运行至记忆2
            case memory2 = 0x08
            /// 0x09：运行至记忆3
            case memory3 = 0x09
            /// 0x0A：运行至记忆4
            case memory4 = 0x0A
        }

        /// 记忆位置设置类型
        public enum MemorySetting: Byte {
            /// 0x01 - 设置上限
            case upperLimit = 0x01
            /// 0x02 - 设置下限
            case lowerLimit = 0x02
            /// 0x03 - 设置记忆1
            case setMemory1 = 0x03
            /// 0x04 - 设置记忆2
            case setMemory2 = 0x04
            /// 0x05 - 设置记忆3
            case setMemory3 = 0x05
            /// 0x06 - 设置记忆4
            case setMemory4 = 0x06
            /// 0x07 - 取消上限
            case cancelUpper = 0x07
            /// 0x08 - 取消下限
            case cancelLower = 0x08
            /// 0x09 - 取消记忆1
            case cancelMemory1 = 0x09
            /// 0x0A - 取消记忆2
            case cancelMemory2 = 0x0A
            /// 0x0B - 取消记忆3
            case cancelMemory3 = 0x0B
            /// 0x0C - 取消记忆4
            case cancelMemory4 = 0x0C
            /// 0x0D - 取消记忆所有记忆位置
            case cancelAll = 0x0D
        }

        /// 功能指令的基础模板
        /// - Parameters:
        ///   - code: 功能码
        ///   - bytes: 功能数据
        private func combineCommand(code: Byte, bytes: Bytes) -> Bytes {
            let count = bytes.count
            var command = Bytes(repeating: 0, count: count + 2)
            command[0] = defaultType
            command[1] = code
            command.replaceSubrange(2 ..< count, with: bytes)
            return check(command)
        }

        /**
         * 查询协议版本
         *
         * 回复指令：1B
         * 10：即1.0
         */
        public func queryProtocolVersion() -> Bytes {
            return combineCommand(code: 0x01, bytes: [0])
        }

        /**
         * 查询软件版本
         *
         * 回复指令：3B
         * B1 程序框架版本
         * B2 新增功能升级
         * B3 bug修复
         */
        public func querySoftwareVersion() -> Bytes {
            return combineCommand(code: 0x02, bytes: [0])
        }

        /**
         * 控制设备
         *
         *
         * 回复数据
         * 00：执行失败（比如已经最高了又收到上升指令依此类推…）
         * 01：正常执行
         */
        public func control(_ type: Ctrl) -> Bytes {
            let byte = type.rawValue
            return combineCommand(code: 0x03, bytes: [byte])
        }

        /**
         * 运行到指定高度 单位mm
         * @param height 单位mm
         * 回复数据
         * 00：执行失败（目标位置距离当前位置太近…）
         * 01：正常执行
         */
        public func run(_ height: Int) -> Bytes {
            return combineCommand(code: 0x04, bytes: height.to2ByteBig())
        }

        /**
         * 记忆位置设置
         *
         * 回复数据
         * 00：设置失败
         * 01：设置成功
          */
        public func setFunction(_ fun: MemorySetting) -> Bytes {
            let byte = fun.rawValue
            return combineCommand(code: 0x05, bytes: [byte])
        }

        /**
         * 进入复位状态
         */
        public func resetState() -> Bytes {
            return combineCommand(code: 0x06, bytes: [0x01])
        }

        /**
         * 一键复位
         * 00：立即停止复位
         * 01：自动执行复位
         *
         * 回复数据
         * 00：操作失败
         * 01：操作成功
         */
        public func reset(_ type: Bool) -> Bytes {
            let byte: Byte = type ? 0x01 : 0x00
            return combineCommand(code: 0x07, bytes: [byte])
        }

        /**
         * 控制器锁定
         * 00：解锁控制器
         * 01：锁定控制器
         *
         * 回复数据
         * 00：操作失败
         * 01：操作成功
         */
        public func lock(_ state: Bool) -> Bytes {
            let byte: Byte = state ? 0x01 : 0x00
            return combineCommand(code: 0x08, bytes: [byte])
        }

        /**
         * 查询设备状态
         *
         * 回复设备状态
         * 01：上升中
         * 02：下降中
         * 03：暂停中（正常待机模式）
         * 04：设备处于复位状态
         * 05：设备处于锁定状态
         * 06：设备处于异常状态
         */
        public func queryState() -> Bytes {
            return combineCommand(code: 0x09, bytes: [0])
        }

        /**
         * 查询设备高度
         *
         * 回复查询
         * 00 64：100mm
         * 01 F4：500mm
         * …
         * FF FF:无效数据
         */
        public func queryHeight() -> Bytes {
            return combineCommand(code: 0x0A, bytes: [0])
        }
    }

    /**
     *************************
     ***      平移导台       ***
     *************************
     */
    public struct TranslationDesk: JiecangProtocol {
        /**
         * 上升
         */
        public func up() -> Bytes {
            let command: Bytes = [0x01, 0]
            return check(command)
        }

        /**
         * 下降
         */
        public func down() -> Bytes {
            let command: Bytes = [0x02, 0]
            return check(command)
        }

        /**
         * 停止
         */
        public func stop() -> Bytes {
            let command: Bytes = [0x0A, 0]
            return check(command)
        }

        /**
         * 行程范围
         */
        public func routeScope() -> Bytes {
            let command: Bytes = [0x0C, 0]
            return check(command)
        }

        /**
         * 运行至指定高度
         * - Parameter height: 单位mm
         */
        public func runHeight(height: Int) -> Bytes {
            let data = height.to2ByteBig()
            let command: Bytes = [0x1B, 0x02, data[0], data[1]]
            return check(command)
        }

        /**
         * 设置当前为位置为上限位
         */
        public func setUpLimit() -> Bytes {
            let command: Bytes = [0x21, 0]
            return check(command)
        }

        /**
         * 设置当前为位置为下限位
         */
        public func setDownLimit() -> Bytes {
            let command: Bytes = [0x22, 0]
            return check(command)
        }

        /**
         * 同时删除上、下限位
         */
        public func deleteLimit() -> Bytes {
            let command: Bytes = [0x23, 0]
            return check(command)
        }

        /**
         * 删除上限位
         */
        public func deleteUpLimit() -> Bytes {
            let command: Bytes = [0x23, 0x01, 0x01]
            return check(command)
        }

        /**
         * 删除下限位
         */
        public func deleteDownLimit() -> Bytes {
            let command: Bytes = [0x23, 0x01, 0x02]
            return check(command)
        }

        /**
         查询上下限位设置标志位信息
         * 回复:F2 F2 20 01 data sum 7E
         * data值：
            * 0：表示未设置上下限位
            * 0x01：表示设置了上限位
            * 0x10：表示设置了下限位
            * 0x11：表示设置了上限位、下限位
         */
        public func queryLimitState() -> Bytes {
            let command: Bytes = [0x20, 0x00]
            return check(command)
        }

        /**
         * 查询上限位高度
         */
        public func queryUpLimit() -> Bytes {
            let command: Bytes = [0x21, 0x00]
            return check(command)
        }

        /**
         * 查询下限位高度
         */
        public func queryDownLimit() -> Bytes {
            let command: Bytes = [0x22, 0x00]
            return check(command)
        }

        /**
         * 设置当前为位置为记忆位置
         *
         * 设置第三第四个记忆位置，仅在V5及以上版本控制器上使用有效
         * - Parameter position: 1 ~ 4 最多只有记忆4个位置
         * 1：记忆位置1
         * 2：记忆位置2
         * 3：记忆位置3
         * 4：记忆位置4
             */
        public func setLocalityPosition(position: Int) -> Bytes {
            // position = 1 或 默认 为 0x03
            var result: Byte = 0x03.toByte()
            if position == 2 {
                result = 0x04.toByte()
            } else if position == 3 {
                result = 0x25.toByte()
            } else if position == 4 {
                result = 0x26.toByte()
            }
            let command: Bytes = [result, 0x00]
            return check(command)
        }

        /**
         * 运行到记忆位置
         *
         * 设置第三第四个记忆位置，仅在V5及以上版本控制器上使用有效
         * - Parameter position: 1 ~ 4 最多只有记忆4个位置
         * 1：记忆位置1
         * 2：记忆位置2
         * 3：记忆位置3
         * 4：记忆位置4
         */
        public func runLocalityPosition(position: Int) -> Bytes {
            // position = 1 或 默认 为 0x05
            var result: Byte = 0x05.toByte()
            if position == 2 {
                result = 0x06.toByte()
            } else if position == 3 {
                result = 0x27.toByte()
            } else if position == 4 {
                result = 0x28.toByte()
            }
            let command: Bytes = [result, 0x00]
            return check(command)
        }
    }
}

extension Jiecang {
    /**
     * CRC校验
     * 波特率——9600
     * 数据位——8位
     * 停止位——1位
     * 奇偶校验——无
     *
     * 3.1外部设备至控制器
     * 起始贞    功能码    数据长度      数据           校验和       结束贞
     * 2字节     1字节      XX       XXXXXXXX        1字节        1字节
     * 起始贞：F1F1
     * 功能码：根据实际情况定义
     * 数据长度：数据中的字节数
     * 数据：实际的操作内容
     * 校验和：除了起始贞和结束贞外，其余数据相加，取低8位；
     * 结束贞：7E
     *
     * 3.2控制器至外部设备
     * 起始贞    功能码    数据长度      数据           校验和       结束贞
     * 2字节     1字节      XX       XXXXXXXX        1字节        1字节
     * 起始贞：F2F2
     * 功能码：根据实际情况定义
     * 数据长度：数据中的字节数
     * 数据：实际的操作内容
     * 校验和：除了起始贞和结束贞外，其余数据相加，取低8位；
     * 结束贞：7E
     */
    struct CRC {
        /// 校验发送的指令
        static func check(_ bytes: Bytes) -> Bytes {
            let count = bytes.count + 4
            var result = Bytes(repeating: 0, count: count)
            let sum = bytes.map { $0.toIntU() }.sum()
            result[0] = 0xF1.toByte()
            result[1] = 0xF1.toByte()
            result.replaceSubrange(2 ..< bytes.count, with: bytes)
            result[count - 2] = sum.to2ByteLittle()[0] // 校验和 取低8位
            result[count - 1] = 0x7E // 结束帧
            return result
        }

        /**
         厨电设备协议 - 协议版本JC_1.0
         * 起始码开始到功能数据结束的所有数据求和取低字节

          起始码    数据长度        设备类型        功能码        功能数据        校验和        结束码
           2B        1B             1B           1B            nB            1B           1B

         * 2.1 起始码：固定为55 AA
         * 2.2 数据长度：从设备类型开始到功能数据的结束字节数（不包括校验）
         * 2.3 设备类型：即数据源，比如该字节为01，说明数据来源于手控器，具体定义见表2.1,表中外设即各种接到控制器的设备，比如六轴传感器，各种智能模组转接盒等；主机收到什么类型就回复什么类型即可。
         * 2.4 功能码及功能数据，具体定义见表2.2
         * 2.5 校验码：从起始码开始到功能数据结束的所有数据求和取低字节
         * 2.6 结束符AA
         *
         Parameter bytes: 只有设备类型 功能码  功能数据 的 byteArray
         */
        static func checkKitchen(_ bytes: Bytes) -> Bytes {
            let count = 2 + 1 + bytes.count + 1 + 1
            var result = Bytes(repeating: 0, count: count)
            result[0] = 0x55
            result[1] = 0xAA.toByte()
            result[2] = bytes.count.toByte()
            result.replaceSubrange(3 ..< bytes.count, with: bytes)
            let sum = result.map { $0.toIntU() }.sum()
            result[count - 2] = sum.to2ByteLittle()[0]
            result[count - 1] = 0xAA.toByte()
            return result
        }
    }
}

internal protocol JiecangProtocol: ThirdPartyProtocol {}

extension JiecangProtocol where Self == Jiecang.TranslationDesk {
    internal var describe: String {
        return "捷昌-升降桌系统-平移导台"
    }

    internal func check(_ bytes: Bytes) -> Bytes {
        Jiecang.CRC.check(bytes)
    }
}

extension JiecangProtocol where Self == Jiecang.LiftCabinet {
    internal var describe: String {
        return "捷昌-厨电产品-智能升降吊柜"
    }

    internal func check(_ bytes: Bytes) -> Bytes {
        return Jiecang.CRC.checkKitchen(bytes)
    }
}
