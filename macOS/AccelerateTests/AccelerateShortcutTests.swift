//
//  AccelerateShortcutTests.swift
//  AccelerateTests
//
//  Created by Ritam Sarmah on 8/22/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

import XCTest

@testable import Accelerate

class AccelerateShortcutTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: Formatters

    func testRateFormatter() throws {
        // Trailing zero removed
        XCTAssert(Shortcut.Action.rateFormatter.string(from: 1.0) == "1")
        XCTAssert(Shortcut.Action.rateFormatter.string(from: 1.00) == "1")
        XCTAssert(Shortcut.Action.rateFormatter.string(from: 0.10) == "0.1")

        // Maximum two decimal digits
        XCTAssert(Shortcut.Action.rateFormatter.string(from: 0.1) == "0.1")
        XCTAssert(Shortcut.Action.rateFormatter.string(from: 0.12) == "0.12")
        XCTAssert(Shortcut.Action.rateFormatter.string(from: 0.123) == "0.12")
    }

    func testTimeFormatter() throws {
    }
}
