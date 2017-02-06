//
//  allegroViewModelTests.swift
//  allegro
//
//  Created by Nikhil Lele on 1/30/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import XCTest
@testable import allegro

class allegroViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testNoteViewModel() {
        // TODO
    }
    
    func testMeasureViewModel() {
        // TODO test checkAccidentalDisplay
        
    }
    func testBeam() {
        // TODO test beam v1
        let part = mockPart("beams")
        let cases: [(measure: Int, beamCount: Int)] = [
            (0, 1),
            (1, 4),
            (2, 2),
            (3, 0),
        ]

        for (measure, beamCount) in cases {
            XCTAssert(MeasureViewModel(part.measures[measure]).beams.count == beamCount)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
