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
        let C4 = NoteViewModel(note: Note(value: .quarter, letter: .C, octave: 4), position: 0)
        XCTAssert(C4.pitch == -6, "C4 is 6 notes below centerline, on the first ledger line")
        var (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: -6)
        XCTAssert(letter == Note.Letter.C && octave == 4, "C4 is 6 notes below centerline, on the first ledger line")

        let A4 = NoteViewModel(note: Note(value: .quarter, letter: .A, octave: 4), position: 0)
        XCTAssert(A4.pitch == -1, "A4 is 1 note below centerline")
        (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: -1)
        XCTAssert(letter == Note.Letter.A && octave == 4, "A4 is 1 note below centerline")

        let B4 = NoteViewModel(note: Note(value: .quarter, letter: .B, octave: 4), position: 0)
        XCTAssert(B4.pitch == 0, "B4 is at the centerline")
        (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: 0)
        XCTAssert(letter == Note.Letter.B && octave == 4, "B4 is at the centerline")

        let C5 = NoteViewModel(note: Note(value: .quarter, letter: .C, octave: 5), position: 0)
        XCTAssert(C5.pitch == 1, "C5 is 1 note above centerline")
        (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: 1)
        XCTAssert(letter == Note.Letter.C && octave == 5, "C5 is 1 note above centerline")

        let G5 = NoteViewModel(note: Note(value: .quarter, letter: .G, octave: 5), position: 0)
        XCTAssert(G5.pitch == 5, "G5 is 5 notes above centerline")
        (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: 5)
        XCTAssert(letter == Note.Letter.G && octave == 5, "G5 is 5 notes above centerline")

        let B5 = NoteViewModel(note: Note(value: .quarter, letter: .B, octave: 5), position: 0)
        XCTAssert(B5.pitch == 7, "B5 is 7 notes above centerline, right above first ledger line")
        (letter,octave) = NoteViewModel.pitchToLetterAndOffset(pitch: 7)
        XCTAssert(letter == Note.Letter.B && octave == 5, "B5 is 7 notes above centerline, right above first ledger line")
    }

    func testMeasureViewModel() {
        // TODO test checkAccidentalDisplay
        
    }
    func testBeam() {
        // TODO test beam v1
        let part = mockPart("BeamTest")
        let cases: [(measure: Int, beamCount: Int)] = [
            (0, 4),
            (1, 6),
            (2, 2),
        ]

        for (i, testCase) in cases.enumerated() {
            let (measure, beamCount) = testCase
            XCTAssertEqual(MeasureViewModel(part.measures[measure]).beams.count, beamCount, "beam failed \(i)")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
