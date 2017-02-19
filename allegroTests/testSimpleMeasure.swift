//
//  testSimpleMeasure.swift
//  allegro
//
//  Created by Kevin Coelho on 2/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import XCTest
@testable import allegro
import Rational // TODO figure out how to import Rational here without linker error

class testSimpleMeasure: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleMeasure() {
        var basicMeasure = SimpleMeasure()
        var wholeNoteMeasure = SimpleMeasure()
        var basicNudgeLeftMeasure = SimpleMeasure()
        
        let A4quarter = Note(value: .quarter, letter: .A, octave: 4)
        let B4quarter = Note(value: .quarter, letter: .B, octave: 4)
        let C5eighth = Note(value: .eighth, letter: .C, octave: 5)
        let D5quarter = Note(value: .quarter, letter: .D, octave: 5)
        let Awhole = Note(value: .whole, letter: .A, octave: 4)
        
        // Test insert whole note at pos 1/2. Should nudge left to 0
        XCTAssert(wholeNoteMeasure.insert(note: Awhole, at: 1/2) == true, "Could not insert whole note at position 1/2")
        if let wholeNote = wholeNoteMeasure.note(at: 0) {
            XCTAssert(wholeNote == Awhole, "Wrong note nudged left")
        }
        else {
            XCTFail("Whole note inserted at 1/2 not properly nudged left")
        }
        // Test insert note past capacity
        XCTAssert(wholeNoteMeasure.insert(note: A4quarter, at: 1/2) == false, "Note cannot fill a measure past free capacity")
        
        // Test insert before 0
        XCTAssert(basicMeasure.insert(note: A4quarter, at: -1/2) == false, "Note cannot be placed before 0.")
        
        // Test basic insertions without nudging
        XCTAssert(basicMeasure.insert(note: A4quarter, at: 0) == true, "Note can be placed at start of free space")
        XCTAssert(basicMeasure.insert(note: B4quarter, at: 1/4) == true, "Note can be placed at end of free space")
        
        // test for correct basic freespace
        var freeSpace = basicMeasure.frees
        XCTAssert(freeSpace.count == 1, "Expected 1 freespace, received " + freeSpace.count.description)
        XCTAssert(freeSpace[0].pos == 1/2 && freeSpace[0].duration == 1/2, "Expected (pos, dur): (1/2, 1/2). Received: (" + freeSpace[0].pos.description
           + ", " + freeSpace[0].duration.description + ")")
        
        // test directly accessing notes
        if let n0 = basicMeasure.note(at: 0) {
            XCTAssert(n0 == A4quarter, "Note can be accessed directly")
        } else {
            XCTFail("Note can be accessed directly")
        }
        if let n1 = basicMeasure.note(at: 3/8) {
            XCTAssert(n1 == C5eighth, "Note can be accessed directly")
        } else {
            XCTFail("Note can be accessed directly")
        }
        if let n2 = basicMeasure.note(at: 3/4) {
            XCTAssert(n2 == B4quarter, "Note can be accessed directly")
        } else {
            XCTFail("Note can be accessed directly")
        }
        
        // test getting all notes
        let notes = basicMeasure.notes
        XCTAssert(notes.count == 3, "There are exactly 3 notes")
        XCTAssert(notes[0].pos == 0 && notes[0].note == A4quarter, "Note can be accessed")
        XCTAssert(notes[1].pos == 3/8 && notes[1].note == C5eighth, "Note can be accessed")
        XCTAssert(notes[2].pos == 3/4 && notes[2].note == B4quarter, "Note can be accessed")
        
        // test removing notes
        XCTAssert(basicMeasure.removeNote(at: 0) == true, "Remove note at 0")
        XCTAssert(basicMeasure.notes.count == 2, "There are exactly 2 notes after removing one")
        freeSpace = basicMeasure.frees
        XCTAssert(freeSpace.count == 2, "Two freespaces")
        XCTAssert(freeSpace[0].pos == 0 && freeSpace[0].duration == 3/8, "First freespace is bigger")
        XCTAssert(freeSpace[1].pos == 1/2 && freeSpace[1].duration == 1/4, "Check second freespace")
        
        XCTAssert(basicMeasure.removeNote(at: 0) == false, "Not allowed to remove note twice")
        XCTAssert(basicMeasure.notes.count == 2, "Note cannot be removed twice")
        freeSpace = basicMeasure.frees
        XCTAssert(freeSpace.count == 2, "Two freespaces")
        XCTAssert(freeSpace[0].pos == 0 && freeSpace[0].duration == 3/8, "First freespace is same")
        XCTAssert(freeSpace[1].pos == 1/2 && freeSpace[1].duration == 1/4, "Second freespace is same")
        
        XCTAssert(basicMeasure.removeNote(at: 3/4) == true, "Remove at 3/4")
        XCTAssert(basicMeasure.notes.count == 1, "There is only 1 note left")
        freeSpace = basicMeasure.frees
        XCTAssert(freeSpace.count == 2, "Two freespaces")
        XCTAssert(freeSpace[0].pos == 0 && freeSpace[0].duration == 3/8, "First freespace is same")
        XCTAssert(freeSpace[1].pos == 1/2 && freeSpace[1].duration == 1/2, "Second freespace is bigger")
        
        XCTAssert(basicMeasure.removeNote(at: 3/8) == true, "Remove at 3/8")
        XCTAssert(basicMeasure.notes.count == 0, "There are no notes left")
        freeSpace = basicMeasure.frees
        XCTAssert(freeSpace.count == 1, "One freespace")
        XCTAssert(freeSpace[0].pos == 0 && freeSpace[0].duration == 1, "First freespace takes the whole measure")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
