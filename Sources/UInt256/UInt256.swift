//
//  UInt256.swift
//  BitcoinMiner
//
//  Created by Jernej Strasner on 11/24/17.
//  Copyright © 2017 Jernej Strasner. All rights reserved.
//

import Foundation
import Accelerate

public struct UInt256 {

    private var value = vU256()

    public init() {}

    public init(_ num: UInt64) {
        value.s.LSW = UInt32(truncatingIfNeeded: num)
        value.s.d7 = UInt32(truncatingIfNeeded: num >> 32)
    }

    public init(_ num: UInt32) {
        value.s.LSW = num
    }

    public init(hex: String) {
        precondition(hex.count != 0, "Empty string")
        precondition(hex.count <= 64, "String is too large")
        precondition(hex.count % 2 == 0, "A hexadecimal string must have a power of 2 length")
        let processedHex = repeatElement("0", count: 64 - hex.count) + hex // left padding
        for c in processedHex {
            guard let number = UInt32(String(c), radix: 16) else {
                fatalError("Invalid hex character!")
            }
            // Shift left before adding
            var shifted = vU256()
            vLL256Shift(&value, 4, &shifted)
            // Add to shifted value
            var addition = vU256()
            addition.s.LSW = number
            vU256Add(&shifted, &addition, &value)
        }
    }

    private init(_ value: vU256) {
        self.value = value
    }

}

extension UInt256 : ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = UInt64

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }

}

extension UInt256 : ExpressibleByStringLiteral {

    public typealias StringLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        self.init(hex: value)
    }

}

extension UInt256 : BinaryInteger {

    public init?<T>(exactly source: T) where T : BinaryInteger {
        // TODO
    }

    public init<T>(_ source: T) where T : BinaryInteger {
        // TODO
    }

    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        // TODO: proper floating point type initialization
        if let i = UInt64(exactly: source) {
            self.init(i)
        }
        return nil
    }

    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        // TODO: proper floating point type initialization
        self.init(UInt64(source))
    }

    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        // TODO: proper integer type initialization
        self.init(UInt64(truncatingIfNeeded: source))
    }

    public init<T>(clamping source: T) where T : BinaryInteger {
        // TODO: proper integer type initialization
        self.init(UInt64(clamping: source))
    }

    public typealias Words = [UInt]

    public var words: Words {
        return self.map{ UInt($0) }
    }

    public var bitWidth: Int {
        return 256
    }

    public var trailingZeroBitCount: Int {
        var c = 0
        for b in self.reversed() {
            if b.trailingZeroBitCount == 0 {
                return c
            }
            c += b.trailingZeroBitCount
        }
        return c
    }

    public var hashValue: Int {
        return Array(self).withUnsafeBufferPointer{ Int(murmur3(buffer: $0)) }
    }

    public typealias Magnitude = UInt256

    public var magnitude: UInt256 {
        return self
    }

    public var description: String {
        return self.map{ String($0) }.joined()
    }

    public static var isSigned: Bool {
        return false
    }

    public static func /(lhs: UInt256, rhs: UInt256) -> UInt256 {
        var r = lhs
        r /= rhs
        return r
    }

    public static func /=(lhs: inout UInt256, rhs: UInt256) {
        var left = lhs.value
        var right = rhs.value
        vU256Divide(&left, &right, &lhs.value, nil)
    }

    public static func %(lhs: UInt256, rhs: UInt256) -> UInt256 {
        var r = lhs
        r %= rhs
        return r
    }

    public static func %=(lhs: inout UInt256, rhs: UInt256) {
        var left = lhs.value
        var right = rhs.value
        vU256Mod(&left, &right, &lhs.value)
    }

    public static func +(lhs: UInt256, rhs: UInt256) -> UInt256 {
        var r = lhs
        r += rhs
        return r
    }

    public static func +=(lhs: inout UInt256, rhs: UInt256) {
        var left = lhs.value
        var right = rhs.value
        vU256Add(&left, &right, &lhs.value)
    }

    public static func -(lhs: UInt256, rhs: UInt256) -> UInt256 {
        var r = lhs
        r -= rhs
        return r
    }

    public static func -=(lhs: inout UInt256, rhs: UInt256) {
        var left = lhs.value
        var right = rhs.value
        vU256Sub(&left, &right, &lhs.value)
    }

    public static func *(lhs: UInt256, rhs: UInt256) -> UInt256 {
        var r = lhs
        r *= rhs
        return r
    }

    public static func *=(lhs: inout UInt256, rhs: UInt256) {
        var left = lhs.value
        var right = rhs.value
        vU256HalfMultiply(&left, &right, &lhs.value)
    }

    public static func &=(lhs: inout UInt256, rhs: UInt256) {
        for (i, e) in lhs.enumerated() {
            lhs[i] &= e
        }
    }

    public static func |=(lhs: inout UInt256, rhs: UInt256) {
        for (i, e) in lhs.enumerated() {
            lhs[i] |= e
        }
    }

    public static func ^=(lhs: inout UInt256, rhs: UInt256) {
        for (i, e) in lhs.enumerated() {
            lhs[i] ^= e
        }
    }

    public static prefix func ~(x: UInt256) -> UInt256 {
        var result = UInt256()
        for (i, e) in x.enumerated() {
            result[i] = ~e
        }
        return result
    }

    public static func <<=<RHS>(lhs: inout UInt256, rhs: RHS) where RHS : BinaryInteger {
        guard let shift = UInt32(exactly: rhs) else {
            fatalError("The rigth hand side value has to be convertable to UInt32")
        }
        var num = lhs.value
        vLL256Shift(&num, shift, &lhs.value)
    }

    public static func >>=<RHS>(lhs: inout UInt256, rhs: RHS) where RHS : BinaryInteger {
        guard let shift = UInt32(exactly: rhs) else {
            fatalError("The rigth hand side value has to be convertable to UInt32")
        }
        var num = lhs.value
        vLR256Shift(&num, shift, &lhs.value)
    }

}

extension UInt256 : Comparable {

    public static func ==(lhs: UInt256, rhs: UInt256) -> Bool {
        for (lv, rv) in zip(lhs, rhs) {
            if lv != rv {
                return false
            }
        }
        return true
    }

    public static func <(lhs: UInt256, rhs: UInt256) -> Bool {
        for (lv, rv) in zip(lhs, rhs) {
            if lv < rv {
                return true
            }
            if lv > rv {
                return false
            }
        }
        return false
    }

}

extension UInt256 : Collection {

    public typealias Element = UInt32

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return 8
    }

    public subscript(index: Int) -> Element {
        get {
            switch index {
            case 0: return value.s.MSW
            case 1: return value.s.d2
            case 2: return value.s.d3
            case 3: return value.s.d4
            case 4: return value.s.d5
            case 5: return value.s.d6
            case 6: return value.s.d7
            case 7: return value.s.LSW
            default: fatalError("Index out of bounds")
            }
        }
        set {
            switch index {
            case 0: value.s.MSW = newValue
            case 1: value.s.d2 = newValue
            case 2: value.s.d3 = newValue
            case 3: value.s.d4 = newValue
            case 4: value.s.d5 = newValue
            case 5: value.s.d6 = newValue
            case 6: value.s.d7 = newValue
            case 7: value.s.LSW = newValue
            default: fatalError("Index out of bounds")
            }
        }
    }

    public func index(after i: Int) -> Int {
        precondition(i < endIndex, "Can't advance beyond endIndex")
        return i + 1
    }

}

extension UInt256 : CustomDebugStringConvertible {

    public var debugDescription: String {
        return self.map{ String($0) }.joined(separator: "_")
    }

    public var hexDescription: String {
        return self.map({
            let s = String($0, radix: 16)
            return repeatElement("0", count: 8 - s.count) + s
        }).joined()
    }

}

extension UInt32 {

    public init(_ i: UInt256) {
        for x in i {
            if x > 0 {
                self.init(x)
                return
            }
        }
        self.init(0)
    }

}

extension UInt64 {

    public init(_ i: UInt256) {
        for (y, x) in i.enumerated() {
            if x > 0 {
                if y+1 < i.endIndex {
                    self.init(UInt64(x) << 32 + UInt64(i[y+1]))
                } else {
                    self.init(x)
                }
                return
            }
        }
        self.init(0)
    }

}

/// Calculates a Murmur hash for a UInt32 buffer
/// Adapted from https://en.wikipedia.org/wiki/MurmurHash
private func murmur3(buffer: UnsafeBufferPointer<UInt32>) -> UInt32 {
    var hash: UInt32 = 0
    var k: UInt32 = 0

    for chunk in buffer {
        k = chunk &* 0xcc9e2d51
        k = (k << 15) | (k >> 17)
        k = k &* 0x1b873593
        hash ^= k
        hash = (hash << 13) | (hash >> 19)
        hash = ((hash &* 5) &+ 0xe6546b64)
    }

    hash ^= UInt32(buffer.count * 4)
    hash ^= hash >> 16
    hash = hash &* 0x85ebca6b
    hash ^= hash >> 13
    hash = hash &* 0xc2b2ae35
    hash ^= hash >> 16

    return hash
}
