//
//  BitcoinMinerTests.swift
//  BitcoinMinerTests
//
//  Created by Jernej Strasner on 11/25/17.
//  Copyright © 2017 Jernej Strasner. All rights reserved.
//

import XCTest
@testable
import UInt256

class UInt256Tests: XCTestCase {
    
    func testComparison() {
        let a = UInt256(UInt64.max)
        let b = UInt256(UInt64.max-1)
        XCTAssertGreaterThan(a, b)
        XCTAssertNotEqual(a, b)
        XCTAssertLessThan(b, a)
        XCTAssertEqual(a, UInt256(UInt64.max))
        XCTAssertEqual(b, UInt256(UInt64.max-1))
    }
    
    func testComparisonSwapped() {
        let a = UInt256(UInt64.max-1)
        let b = UInt256(UInt64.max)
        XCTAssertLessThan(a, b)
        XCTAssertNotEqual(a, b)
        XCTAssertGreaterThan(b, a)
        XCTAssertEqual(a, UInt256(UInt64.max-1))
        XCTAssertEqual(b, UInt256(UInt64.max))
    }

    func testComparisonLarge() {
        let a = UInt256(UInt32(1)) << 224
        let aT = UInt256(UInt32(1)) << 225
        XCTAssertLessThan(a, aT)
        let b = UInt256(hex: "0000000000000000e067a478024addfecdc93628978aa52d91fabd4292982a50")
        let bT = UInt256(hex: "00000000000000015f5300000000000000000000000000000000000000000000")
        XCTAssertLessThan(b, bT)
    }

    func testBitShiftLeft() {
        let a = UInt256(UInt32.max) << 32
        let b = UInt256(UInt64.max ^ UInt64(UInt32.max))
        XCTAssertEqual(a, b)
    }

    func testConvertToUInt32() {
        let a = UInt256(UInt32.max)
        XCTAssertEqual(UInt32(exactly: a), UInt32.max)
        let b = UInt256(UInt32.max) << 128
        XCTAssertEqual(UInt32(clamping: b), UInt32.max)
    }

    func testConvertToUInt64() {
        let a = UInt256(UInt64.max)
        dump(Array(a))
        XCTAssertEqual(UInt64(exactly: a), UInt64.max)
        let b = UInt256(UInt32.max) << 32
        XCTAssertEqual(UInt64(clamping: b), (UInt64.max ^ UInt64(UInt32.max)))
    }

    func testHexParsing() {
        let a = UInt256(hex: "53058b35")
        let b = UInt256(UInt64(0x53058b35))
        XCTAssertEqual(a, b)
    }

    func testIntegerLiteral() {
        let a: UInt256 = 728
        XCTAssertEqual(a, UInt256(UInt64(728)))
    }

    func testStringLiteral() {
        let a: UInt256 = "ffffffff"
        XCTAssertEqual(a, UInt256(UInt32(0xffffffff)))
    }

    func testTrailingZeros() {
        XCTAssertEqual(UInt256(0).trailingZeroBitCount, 256)
        XCTAssertEqual(UInt256(UInt32(1)).trailingZeroBitCount, 0)
        XCTAssertEqual(UInt256(UInt32(2)).trailingZeroBitCount, 1)
        XCTAssertEqual(UInt256(UInt32(3)).trailingZeroBitCount, 0)
        XCTAssertEqual(UInt256(UInt64.max).trailingZeroBitCount, 0)
        XCTAssertEqual(UInt256(UInt32.max).trailingZeroBitCount, 0)
        XCTAssertEqual(UInt256(UInt32(UInt16.max)).trailingZeroBitCount, 0)
    }

}
