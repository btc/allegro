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

    let notes = [
        Note(value: .whole, letter: .C, octave: 4),
        Note(value: .quarter, letter: .A, octave: 4),
        Note(value: .eighth, letter: .G, octave: 4, accidental: .sharp, rest: false),
    ]

    let cases: [(measureIndex: Int, noteIndex: Int, pos: Rational)] = [
        (0, 0, 0),
        (1, 1, 1/4),
        (1, 2, 1/2)
    ]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGenerate() {
        let store = PartStore(part: Part())
        let parser = MusicXMLParser(store: store)

        // insert notes into store
        for c in cases {
            let _ = store.insert(note: notes[c.noteIndex], intoMeasureIndex: c.measureIndex, at: c.pos)
        }

        // TODO test the XML generated matches example0
//        Log.info?.message(parser.partDoc.xml)
//        print(parser.partDoc.xml)

        let parser2 = MusicXMLParser(store: PartStore(part: Part()))

        guard let part = parser2.bundleLoad(filename: "example0") else {
            XCTFail("Unable to load")
            return
        }

        print("parser xml:\n")
        print(parser.partDoc.xml)
        print("\nparser2 xml:\n")
        print(parser2.partDoc.xml)

        XCTAssertTrue(parser.partDoc.xmlCompact == parser2.partDoc.xmlCompact, "XML matches")
    }

    func testSaveLoad() {
        let store = PartStore(part: Part())
        let parser = MusicXMLParser(store: store)

        for c in cases {
            let _ = store.insert(note: notes[c.noteIndex], intoMeasureIndex: c.measureIndex, at: c.pos)
        }

        parser.save(filename: "test")

        let parser2 = MusicXMLParser(store: PartStore(part: Part()))
        guard let part2 = parser2.load(filename: "test") else {
            XCTFail("Unable to open file")
            return
        }

        for (i,c) in cases.enumerated() {
            if let note = part2.measures[c.measureIndex].note(at: c.pos) {
                XCTAssertTrue(note == notes[c.noteIndex], "found note \(i)")
            } else {
                XCTFail("Unable to find note \(i)")
            }
        }
    }

    func testBundleLoad() {

        let parser = MusicXMLParser(store: PartStore(part: Part()))

        guard let part = parser.bundleLoad(filename: "example0") else {
            XCTFail("Unable to load")
            return
        }

        for (i,c) in cases.enumerated() {
            if let note = part.measures[c.measureIndex].note(at: c.pos) {
                XCTAssertTrue(note == notes[c.noteIndex], "found note \(i)")
            } else {
                XCTFail("Unable to find note \(i)")
            }
        }
    }

}
