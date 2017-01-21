//
//  allegroTests.swift
//  allegroTests
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import XCTest
@testable import allegro
import Rational // TODO figure out how to import Rational here without linker error

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
        
        XCTAssert(measure.time == 4/4, "New measure has a default of 4/4 time")
    }
    
    func testNote() {
        let G4quarter = Note(value: .quarter, letter: .G, octave: 4)
        XCTAssert(G4quarter.accidental == .natural, "Notes are natural by default")
        XCTAssert(G4quarter.rest == false, "Notes are not rest by default")
        XCTAssert(G4quarter.duration == 1/4, "Quarter note == 1/4")
    }
    
    func testNoteView() {
        let C4 = NoteViewModel(note: Note(value: .quarter, letter: .C, octave: 4))
        XCTAssert(C4.pitch == -6, "C4 is 6 notes below centerline, on the first ledger line")
        
        let A4 = NoteViewModel(note: Note(value: .quarter, letter: .A, octave: 4))
        XCTAssert(A4.pitch == -1, "A4 is 1 note below centerline")
        
        let B4 = NoteViewModel(note: Note(value: .quarter, letter: .B, octave: 4))
        XCTAssert(B4.pitch == 0, "B4 is at the centerline")
        
        let C5 = NoteViewModel(note: Note(value: .quarter, letter: .C, octave: 5))
        XCTAssert(C5.pitch == 1, "C5 is 1 note above centerline")
        
        let G5 = NoteViewModel(note: Note(value: .quarter, letter: .G, octave: 5))
        XCTAssert(G5.pitch == 5, "G5 is 5 notes above centerline")
        
        let B5 = NoteViewModel(note: Note(value: .quarter, letter: .B, octave: 5))
        XCTAssert(B5.pitch == 7, "B5 is 7 notes above centerline, right above first ledger line")
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
