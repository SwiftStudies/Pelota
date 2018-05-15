import XCTest
@testable import Pelota

final class PelotaTests: XCTestCase {

    func testIntegerLiteralInitialisation(){
        let literal : Literal = 10
        XCTAssertEqual(10, literal)
    }

    static var allTests = [
        ("testIntegerLiteralInitialisation", testIntegerLiteralInitialisation),
    ]
}
