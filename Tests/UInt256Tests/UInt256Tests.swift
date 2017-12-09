import XCTest
@testable import UInt256

class UInt256Tests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(UInt256().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
