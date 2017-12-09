//
//  BitcoinMinerTests.swift
//  BitcoinMinerTests
//
//  Created by Jernej Strasner on 11/25/17.
//  Copyright © 2017 Jernej Strasner. All rights reserved.
//

import XCTest
import UInt256

class UInt256Tests: XCTestCase {
    
    func testComparison() {
        let a = UInt256(UInt64.max)
        let b = UInt256(UInt64.max-1)
        XCTAssertTrue(a > b)
        XCTAssertTrue(a != b)
        XCTAssertTrue(b < a)
        XCTAssertTrue(a == UInt256(UInt64.max))
        XCTAssertTrue(b == UInt256(UInt64.max-1))
    }
    
    func testComparisonSwapped() {
        let a = UInt256(UInt64.max-1)
        let b = UInt256(UInt64.max)
        XCTAssertTrue(a < b)
        XCTAssertTrue(a != b)
        XCTAssertTrue(b > a)
        XCTAssertTrue(a == UInt256(UInt64.max-1))
        XCTAssertTrue(b == UInt256(UInt64.max))
    }

    func testComparisonLarge() {
        let a = UInt256(UInt32(1)) << 224
        let aT = UInt256(UInt32(1)) << 225
        XCTAssertTrue(a < aT)
        let b = UInt256(hex: "0000000000000000e067a478024addfecdc93628978aa52d91fabd4292982a50")
        let bT = UInt256(hex: "00000000000000015f5300000000000000000000000000000000000000000000")
        XCTAssertTrue(b < bT)
    }

    func testBitShiftLeft() {
        let a = UInt256(UInt32.max) << 32
        let b = UInt256(UInt64.max ^ UInt64(UInt32.max))
        XCTAssertTrue(a == b)
    }

    func testConvertToUInt32() {
        let a = UInt256(UInt32.max)
        XCTAssertTrue(UInt32(a) == UInt32.max)
        let b = UInt256(UInt32.max) << 128
        XCTAssertTrue(UInt32(b) == UInt32.max)
    }

    func testConvertToUInt64() {
        let a = UInt256(UInt64.max)
        XCTAssertTrue(UInt64(a) == UInt64.max)
        let b = UInt256(UInt32.max) << 32
        XCTAssertTrue(UInt64(b) == (UInt64.max ^ UInt64(UInt32.max)))
    }

    func testHexParsing() {
        let a = UInt256(hex: "53058b35")
        let b = UInt256(UInt64(0x53058b35))
        XCTAssertTrue(a == b)
    }

    func testIntegerLiteral() {
        let a: UInt256 = 728
        XCTAssertTrue(a == UInt256(UInt64(728)))
    }

    func testStringLiteral() {
        let a: UInt256 = "ffffffff"
        XCTAssertTrue(a == UInt256(UInt32(0xffffffff)))
    }

}
