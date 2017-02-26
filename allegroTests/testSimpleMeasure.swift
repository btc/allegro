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
    
    // basic tests
    func testSimpleMeasure() {
        var basicMeasure = SimpleMeasure()
        var wholeNoteMeasure = SimpleMeasure()
        
        let A4quarter = Note(value: .quarter, letter: .A, octave: 4)
        let B4quarter = Note(value: .quarter, letter: .B, octave: 4)
        let C5eighth = Note(value: .eighth, letter: .C, octave: 5)
        let Awhole = Note(value: .whole, letter: .A, octave: 4)
        
        // ############################### WHOLE NOTE MEASURE TESTS
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
        
        // ############################### BASIC MEASURE TESTS
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
        
        // Test basic insertion without nudging in middle of freespace
        XCTAssert(basicMeasure.insert(note: C5eighth, at: 6/8) == true, "Error inserting note in middle of free space")
        
        // test for correct freespace
        freeSpace = basicMeasure.frees
        XCTAssert(freeSpace.count == 2, "Expected 2 freespace, received " + freeSpace.count.description)
        XCTAssert(freeSpace[0].pos == 1/2 && freeSpace[0].duration == 1/4, "Expected (pos, dur): (1/2, 1/4). Received: (" + freeSpace[0].pos.description
            + ", " + freeSpace[0].duration.description + ")")
        XCTAssert(freeSpace[1].pos == 7/8 && freeSpace[1].duration == 1/8, "Expected (pos, dur): (7/8, 1/8). Received: (" + freeSpace[1].pos.description
            + ", " + freeSpace[1].duration.description + ")")
        
        // test directly accessing notes
        if let n0 = basicMeasure.note(at: 0) {
            XCTAssert(n0 == A4quarter, "Error accessing note")
        } else {
            XCTFail("Error accessing note")
        }
        if let n1 = basicMeasure.note(at: 1/4) {
            XCTAssert(n1 == B4quarter, "Error accessing note")
        } else {
            XCTFail("Error accessing note")
        }
        if let n2 = basicMeasure.note(at: 6/8) {
            XCTAssert(n2 == C5eighth, "Error accessing note")
        } else {
          XCTFail("Error accessing note")
        }
        
        // test getting all notes
        let notes = basicMeasure.notes
        XCTAssert(notes.count == 3, "There are exactly 3 notes")
        XCTAssert(notes[0].pos == 0 && notes[0].note == A4quarter, "Expected A4quarter, received: " + notes[0].note.letter.step)
        XCTAssert(notes[1].pos == 1/4 && notes[1].note == B4quarter, "Expected B4quarter, received: " + notes[1].note.letter.step)
        XCTAssert(notes[2].pos == 6/8 && notes[2].note == C5eighth, "Expected C5eighth, received: " + notes[2].note.letter.step)
        
        // test removing note
        XCTAssert(basicMeasure.removeNote(at: 0) == true, "Error removing note")
        XCTAssert(basicMeasure.notes.count == 2, "There are exactly 2 notes after removing one")
        freeSpace = basicMeasure.frees
        XCTAssert(freeSpace.count == 3, "Expected 3 freespaces, received: " + freeSpace.count.description)
        XCTAssert(freeSpace[0].pos == 0 && freeSpace[0].duration == 1/4, "Expected free duration 1/4, received: " + freeSpace[0].duration.description)
        XCTAssert(freeSpace[1].pos == 1/2 && freeSpace[1].duration == 1/4, "Expected free duration 1/4, received: " + freeSpace[1].duration.description)
        XCTAssert(freeSpace[2].pos == 7/8 && freeSpace[2].duration == 1/8, "Expected free duration 1/8, received: " + freeSpace[2].duration.description)
        
        // test removing same note twice
        XCTAssert(basicMeasure.removeNote(at: 0) == false, "Note cannot be removed twice")
        XCTAssert(basicMeasure.notes.count == 2, "Note cannot be removed twice")
        freeSpace = basicMeasure.frees
        XCTAssert(freeSpace.count == 3, "Expected 3 freespaces, received: " + freeSpace.count.description)
        XCTAssert(freeSpace[0].pos == 0 && freeSpace[0].duration == 1/4, "Expected free duration 1/4, received: " + freeSpace[0].duration.description)
        XCTAssert(freeSpace[1].pos == 1/2 && freeSpace[1].duration == 1/4, "Expected free duration 1/4, received: " + freeSpace[1].duration.description)
        XCTAssert(freeSpace[2].pos == 7/8 && freeSpace[2].duration == 1/8, "Expected free duration 1/8, received: " + freeSpace[2].duration.description)
        
        // test removing next note
        XCTAssert(basicMeasure.removeNote(at: 1/4) == true, "Error removing note")
        XCTAssert(basicMeasure.notes.count == 1, "Expected note count 1, received: " + basicMeasure.notes.count.description)
        freeSpace = basicMeasure.frees
        XCTAssert(freeSpace.count == 2, "Expected 2 freespaces, received: " + freeSpace.count.description)
        XCTAssert(freeSpace[0].pos == 0 && freeSpace[0].duration == 6/8, "Expected free duration 6/8, received: " + freeSpace[0].duration.description)
        XCTAssert(freeSpace[1].pos == 7/8 && freeSpace[1].duration == 1/8, "Expected free duration 1/8, received: " + freeSpace[1].duration.description)
        
        // test removing last note
        XCTAssert(basicMeasure.removeNote(at: 6/8) == true, "Error removing note")
        XCTAssert(basicMeasure.notes.count == 0, "Expected note count 0, received: " + basicMeasure.notes.count.description)
        freeSpace = basicMeasure.frees
        XCTAssert(freeSpace.count == 1, "Expected 1 freespace, received: " + freeSpace.count.description)
        XCTAssert(freeSpace[0].pos == 0 && freeSpace[0].duration == 1, "Expected free duration 1/1, received: " + freeSpace[0].duration.description)
    }
    
    func testBasicLeftNudge() {
        var basicNudgeLeftMeasure = SimpleMeasure() // basic left nudging
        
        let A4quarter = Note(value: .quarter, letter: .A, octave: 4)
        let B4quarter = Note(value: .quarter, letter: .B, octave: 4)

        // insert quarter
        XCTAssert(basicNudgeLeftMeasure.insert(note: A4quarter, at: 1/8) == true)
        
        // test left freespace
        var leftFreespace = basicNudgeLeftMeasure.freespaceLeft(of: 1/8)
        XCTAssert(leftFreespace == 1/8, "Incorrect freespaceLeft calculation. Expected 1/8, received: " + leftFreespace.description)
        
        // test right freespace
        var rightFreespace = basicNudgeLeftMeasure.freespaceRight(of: 1/8)
        XCTAssert(rightFreespace == 5/8, "Incorrect freespaceRight calculation. Expected 5/8, received: " + rightFreespace.description)
        
        // insert and nudge left
        XCTAssert(basicNudgeLeftMeasure.insert(note: B4quarter, at: 1/4) == true, "Could not insert and nudge left")
        
        // test for correct nudge behavior
        if let nl0 = basicNudgeLeftMeasure.note(at: 0) {
            XCTAssert(nl0 == A4quarter, "Nudge left failed. Expected A4quarter, received: " + nl0.letter.step)
        } else {
            XCTFail("Could not access note at pos 0 in basicNudgeLeftMeasure")
        }
        if let nl1 = basicNudgeLeftMeasure.note(at: 1/4) {
            XCTAssert(nl1 == B4quarter, "Insert with nudge left failed. Expected B4quarter, receiverd: " + nl1.letter.step)
        } else {
            XCTFail("Could not access note as pos 1/4 in basicNudgeLeftMeasure")
        }
        
        // test left freespace
        leftFreespace = basicNudgeLeftMeasure.freespaceLeft(of: 1/2)
        XCTAssert(leftFreespace == 0, "Incorrect freespaceLeft calculation. Expected 0, received: " + leftFreespace.description)
        // test right freespace
        rightFreespace = basicNudgeLeftMeasure.freespaceRight(of: 1/8)
        XCTAssert(rightFreespace == 1/2, "Incorrect freespaceRight calculation. Expected 1/2, received: " + rightFreespace.description)

        // test dotting with nudge right
        XCTAssert(basicNudgeLeftMeasure.dotNote(at: 0, dot: Note.Dot.single) == true, "Error dotting note")
        
        // check for correct nudge behavior
        if let nl2 = basicNudgeLeftMeasure.note(at: 3/8) {
            XCTAssert(nl2 == B4quarter)
        } else {
            XCTFail("Could not access note at pos: 3/8")
        }
    }
    
    func testAdvancedLeftNudge() {
        var singleNudgeLeftMeasure = SimpleMeasure() // this measure will require a single left nudge on insertion (1/8 at 0, 1/4 at 1/2, 1/4 -> 5/8)
        var doubleNudgeLeftMeasure = SimpleMeasure() // this measure will require a double left nudge on insertion (1/4 at 1/8, 1/4 at 3/8, 1/4 -> 1/2)
        
        let A4quarter = Note(value: .quarter, letter: .A, octave: 4)
        let B4quarter = Note(value: .quarter, letter: .B, octave: 4)
        let C4quarter = Note(value: .quarter, letter: .C, octave: 4)
        let C5eighth = Note(value: .eighth, letter: .C, octave: 5)
        
        XCTAssert(singleNudgeLeftMeasure.insert(note: C5eighth, at: 0) == true, "Error inserting note")
        XCTAssert(singleNudgeLeftMeasure.insert(note: A4quarter, at: 1/2) == true, "Error inserting note")
        XCTAssert(singleNudgeLeftMeasure.insert(note: B4quarter, at: 5/8) == true, "Error inserting note with left nudge")
        
        // Check for correct nudge behavior
        if let singleN1 = singleNudgeLeftMeasure.note(at: 0) {
            XCTAssert(singleN1 == C5eighth)
        } else {
            XCTFail("Could not access note at pos: 0")
        }
        if let singleN2 = singleNudgeLeftMeasure.note(at: 3/8) {
            XCTAssert(singleN2 == A4quarter)
        } else {
            XCTFail("Could not access note at pos: 3/8")
        }
        if let singleN3 = singleNudgeLeftMeasure.note(at: 5/8) {
            XCTAssert(singleN3 == B4quarter)
        } else {
            XCTFail("Could not access note at pos: 5/8")
        }
        
        XCTAssert(doubleNudgeLeftMeasure.insert(note: A4quarter, at: 1/8) == true, "Error inserting note")
        XCTAssert(doubleNudgeLeftMeasure.insert(note: B4quarter, at: 3/8) == true, "Error inserting note")
        XCTAssert(doubleNudgeLeftMeasure.insert(note: C4quarter, at: 4/8) == true, "Error inserting note with double left nudge")
        
        // Check for correct nudge behavior
        if let doubleN1 = doubleNudgeLeftMeasure.note(at: 0) {
            XCTAssert(doubleN1 == A4quarter)
        } else {
            XCTFail("Could not access note at pos: 0")
        }
        if let doubleN2 = doubleNudgeLeftMeasure.note(at: 1/4) {
            XCTAssert(doubleN2 == B4quarter)
        } else {
            XCTFail("Could not access note at pos: 1/4")
        }
        if let doubleN3 = doubleNudgeLeftMeasure.note(at: 1/2) {
            XCTAssert(doubleN3 == C4quarter)
        } else {
            XCTFail("Could not access note at pos: 1/2")
        }

        // Insert and nudge right
        XCTAssert(doubleNudgeLeftMeasure.insert(note: C5eighth, at: 3/8) == true, "Error inserting note with right nudge")
        
        // Check for correct nudge behavior
        if let doubleN4 = doubleNudgeLeftMeasure.note(at: 1/2) {
            XCTAssert(doubleN4 == C5eighth)
        } else {
            XCTFail("Could not access note at pos: 1/2")
        }
        if let doubleN5 = doubleNudgeLeftMeasure.note(at: 5/8) {
            XCTAssert(doubleN5 == C4quarter)
        } else {
            XCTFail("Could not access note at pos: 5/8")
        }
        
        // Check for correct freespace
        let frees = doubleNudgeLeftMeasure.frees
        XCTAssert(frees.count == 1)
        XCTAssert(frees[0].duration == 1/8)
        XCTAssert(frees[0].pos == 7/8)
        XCTAssert(doubleNudgeLeftMeasure.freespace == 1/8)
        XCTAssert(doubleNudgeLeftMeasure.freespaceLeft(of: 1) == 1/8)
        XCTAssert(doubleNudgeLeftMeasure.freespaceLeft(of: 7/8) == 0)
        XCTAssert(doubleNudgeLeftMeasure.freespaceRight(of: 3/8) == 1/8)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
