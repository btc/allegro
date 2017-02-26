//
//  MusicXMLTests.swift
//  allegro
//
//  Created by Nikhil Lele on 2/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import XCTest
@testable import allegro
import Rational
import AEXML

class musicXMLTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGenerate() {
        let part = Part()
        let store = PartStore(part: part)
        let parser = MusicXMLParser(store: store)


        let n0 = Note(value: .quarter, letter: .A, octave: 4)
        let _ = store.insert(note: n0, intoMeasureIndex: 0, at: 1/4)

        parser.save(filename: "test.xml")
    }

    func testParse() {
        let store = PartStore(part: Part())
        let parser = MusicXMLParser(store: store)
        
        let n0 = Note(value: .quarter, letter: .A, octave: 4)
        let n1 = Note(value: .eighth, letter: .G, octave: 4, accidental: .sharp, rest: false)
        let _ = store.insert(note: n0, intoMeasureIndex: 0, at: 1/4)
        let _ = store.insert(note: n1, intoMeasureIndex: 0, at: 1/2)
        
        let partDoc = parser.partDoc
        
        let parser2 = MusicXMLParser(store: PartStore(part: Part()))
        guard let newPart = parser2.parse(partDoc: partDoc) else {
            XCTFail("Unable to parse")
            return
        }
        
        let cases: [(measure: Int, note: Note, at: Rational)] = [
            (0, n0, 1/4),
            (0, n1, 1/2)
            ]

        for (i, testCase) in cases.enumerated() {
            let (m, n, pos) = testCase
            if let foundNote = newPart.measures[m].note(at: pos) {
                XCTAssertTrue(foundNote == n, "test case \(i) wrong Note")
            } else {
                XCTFail("test case \(i) Note not found")
            }
        }
    }

    func testLoad() {

        let parser = MusicXMLParser(store: PartStore(part: Part()))

        guard let part = parser.load(filename: "example0") else {
            XCTFail("Unable to load")
            return
        }

        let n0 = Note(value: .whole, letter: .C, octave: 4)
        let cases: [(measure: Int, note: Note, at: Rational)] = [
            (0, n0, 0),
        ]

        for (i, testCase) in cases.enumerated() {
            let (m, n, pos) = testCase
            if let foundNote = part.measures[m].note(at: pos) {
                XCTAssertTrue(foundNote == n, "test case \(i) wrong Note")
            } else {
                XCTFail("test case \(i) Note not found")
            }
        }

    }

}
