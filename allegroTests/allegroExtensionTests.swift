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

    func testCGPointAngle() {
        let testCases: [(point: CGPoint, other: CGPoint, expectedAngleInDegrees: CGFloat)] = [
            (.zero, CGPoint(x: -1, y: 1), 135),
            (.zero, CGPoint(x: 0, y: 1), 90),
            (.zero, CGPoint(x: 1, y: 1), 45),
            (.zero, CGPoint(x: 1, y: 0), 0),
            (.zero, CGPoint(x: 1, y: -1), -45),
            (.zero, CGPoint(x: 0, y: -1), -90),
            (.zero, CGPoint(x: -1, y: -1), -135),
            (.zero, CGPoint(x: -1, y: 0), 180),
            (.zero, .zero, 0),
        ]

        for (i, c) in testCases.enumerated() {
            XCTAssertEqualWithAccuracy(c.expectedAngleInDegrees, c.point.angle(to: c.other), accuracy: 0.01, "\(i)")
        }
    }
}
