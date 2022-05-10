//
//  Util.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/23.
//

import Foundation

public typealias Byte = UInt8
public typealias Bytes = [UInt8]

internal extension String {
    /// 多16进制字符串 转 Bytes
    /// "0A 0B 0C" -> [10, 11, 12]
    func hexsToBytes() -> Bytes {
        let s = replacingOccurrences(of: " ", with: "")
        let count = s.count / 2
        var bs = Bytes(repeating: 0, count: count)
        for i in 0 ..< count {
            let offset = i * 2
            let sub = s[offset ..< offset + 2]
            bs[i] = sub.hexToDecimal().toByte()
        }
        return bs
    }

    /// 单16进制字符 转 10进制数字
    /// "0A" -> 10
    func hexToDecimal() -> Int {
        let str = uppercased()
        var sum: Int = 0
        for i in str.utf8 {
            sum = sum &* 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 { // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }

    /// 16进制字符串 转 10进制Byte
    /// "0A" -> UInt8(10)
    func hexToByte() -> Byte {
        return hexToDecimal().toByte()
    }

    /// 2进制字符串 转 10进制
    /// "1010" -> 10
    func binaryToDecimal() -> Int {
        var sum = 0
        for c in self {
            sum = sum &* 2 + Int("\(c)")!
        }
        return sum
    }

    /// 2进制字符串 转 10进制Byte
    /// "1010" -> UInt8(10)
    func binaryToByte() -> Byte {
        return binaryToDecimal().toByte()
    }

    /// 截取字符串
    subscript(r: Range<Int>) -> String {
        let startIndex = self.startIndex
        let start = index(startIndex, offsetBy: r.startIndex)
        let end = index(startIndex, offsetBy: r.endIndex)
        return String(self[start ..< end])
    }
}

internal extension Int {
    /// Int 转成 2个字节的 低位byte[]
    /// - 存储顺序(小端模式), 低位在前 高位在后
    func to2ByteLittle() -> Bytes {
        return toBytes(from: UInt16(self), isBig: false)
    }

    /// Int 转成 2个字节的 高位byte[]
    /// - 存储顺序(大端模式), 高位在前 低位在后
    func to2ByteBig() -> Bytes {
        return toBytes(from: UInt16(self), isBig: true)
    }

    /// Int 转成 4个字节的 低位byte[]
    /// - 存储顺序(小端模式), 低位在前 高位在后
    func to4ByteLittle() -> Bytes {
        return toBytes(from: UInt32(self), isBig: false)
    }

    /// Int 转成 4个字节的 高位byte[]
    /// - 存储顺序(大端模式),高位在前 低位在后
    func to4ByteBig() -> Bytes {
        return toBytes(from: UInt32(self), isBig: true)
    }

    private func toBytes<T>(from value: T, isBig: Bool) -> Bytes where T: FixedWidthInteger {
        return withUnsafeBytes(of: isBig ? value.bigEndian : value.littleEndian, Array.init)
    }
}

internal extension Array where Element == String {
    /// 16进制字符串数组 转 十进制数组
    /// - ["0A", "0B", "0C"] -> [10, 11, 12]
    func toByte() -> Bytes {
        return map { UInt8($0.hexToDecimal()) }
    }
}

internal extension Byte {
    /// 转成Int后再进行补码
    func toIntU() -> Int {
        return Int(self) & 0xFF
    }

    /// 将 byte 转为 8位二进制字符串 "00110011"
    /// - Parameter isZero: true 前面补零  false 不操作
    /// - Returns: 8位二进制字符串
    func toBitString(isZero: Bool = true) -> String {
        var string = Int(self).toBitString()
        if isZero {
            var count = string.count
            if count < 8 {
                while count < 8 {
                    string = "0" + string
                    count = string.count
                }
            }
        }
        return string
    }
}

internal extension Bytes {
    /// 高位byte[]数组转成Int
    /// - 小端模式 无符号
    /// - byte[2] 转成 UInt16
    /// - Returns: Int16
    func toUInt16Little() -> UInt16 {
        guard count == 2 else { return 0 }
        return toInt(isBig: false)
    }

    /// 高位byte[]数组转成Int
    /// - 大端模式 无符号
    /// - byte[2] 转成 UInt16
    /// - Returns: Int16
    func toUInt16Big() -> UInt16 {
        guard count == 2 else { return 0 }
        return toInt(isBig: true)
    }

    ///   低位byte[]转Int
    /// - 小端模式 无符号
    /// - byte[4] 转成 UInt32
    /// - 低位byte[]数组转成Int
    /// - Returns: UInt32
    func toUInt32Little() -> UInt32 {
        guard count == 4 else { return 0 }
        return toInt(isBig: false)
    }

    ///  高位byte[]转Int
    ///  大端模式 无符号
    ///  byte[4] 转成 UInt32
    ///  高位byte[]数组转成Int
    /// - Returns: UInt32
    func toUInt32Big() -> UInt32 {
        guard count == 4 else { return 0 }
        return toInt(isBig: true)
    }

    private func toInt<T>(isBig: Bool) -> T where T: FixedWidthInteger {
        let value = withUnsafeBytes({ $0.load(as: T.self) })
        return isBig ? value.bigEndian : value.littleEndian
    }
}

internal extension Bool {
    var int: Int {
        return self ? 1 : 0
    }
}

public extension Int {
    /// Int -> Byte
    func toByte() -> Byte {
        let _max = Int(Byte.max)
        return UInt8(Swift.max(0, Swift.min(self & 0xff, _max)))
    }

    /// 数字补零
    func zeroPadding() -> String {
        return String(format: "%02d", self)
    }

    /// 转成16进制字符串
    func toHexString() -> String {
        return String(format: "%02x", self).uppercased()
    }

    /// 转成2进制字符串
    func toBitString() -> String {
        return String(self, radix: 2)
    }
}

public extension Bytes {
    /// Bytes 转成 Hex的字符串
    /// - [10, 11, 12] -> "0A 0B 0C"
    /// - Parameter hasSpace: 是否带空格
    /// - Returns: Hex字符串
    func toHexString(hasSpace: Bool = true) -> String {
        let strings = map { byte -> String in
            Int(byte).toHexString()
        }
        return strings.joined(separator: hasSpace ? " " : "")
    }
}
