//
//  allegroTests.swift
//  allegroTests
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import XCTest
@testable import allegro

class allegroTests: XCTestCase {
    
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
    
    func testPart() {
        let part = Part()
        XCTAssert(part.tempo == 120, "New Part tempo default is 120 bpm")
    }
    
    func testMeasure() {
        let measure = Measure()
        let defaultKey = Key()
        XCTAssert(measure.key.mode == defaultKey.mode &&
            measure.key.fifths == defaultKey.fifths, "New Measure has a default Key")
    }
    
    func testNote() {
        let G4 = Note(letter: .G, octave: 4)
        XCTAssert(G4.accidental == .natural, "Notes are natural by default")
        XCTAssert(G4.rest == false, "Notes are not rest by default")
        
    }
    
    func testKey() {
        let cMajor = Key()
        XCTAssert(cMajor.fifths == 0 && cMajor.mode == Key.Mode.major, "Key default initialization to C Major")
        
        let fsharpMajor = Key(mode: Key.Mode.major, fifths: 5)
        XCTAssert(fsharpMajor.getName() == "F♯M", "Major Key naming in circle of fifths")
        
        let bflatMinor = Key(mode: Key.Mode.minor, fifths: -5)
        XCTAssert(bflatMinor.getName() == "b♭m", "minor key naming in circle of fifths")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
