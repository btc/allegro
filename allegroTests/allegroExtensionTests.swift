//
//  allegroExtensionTests.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/7/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Foundation

import XCTest
@testable import allegro

class allegroExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBinarySearch() {
        let testCases: [(input: [Int], condition: (Int) -> Bool, expectation: Array.Index)] = [
            ([0, 1, 2, 3, 4, 5], { $0 >= 3 }, 3),
        ]

        for (i, c) in testCases.enumerated() {
            XCTAssert(c.input.indexOfFirstMatch(condition: c.condition) == c.expectation, "\(i)")
        }
    }
}
