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
        let part = Part()
        let store = PartStore(part: part)
        let parser = MusicXMLParser(store: store)
        
        let n0 = Note(value: .quarter, letter: .A, octave: 4)
        let _ = store.insert(note: n0, intoMeasureIndex: 0, at: 1/4)
        
        let partDoc = parser.partDoc
        
        let parser2 = MusicXMLParser(store: PartStore(part: Part()))
        let newPart = parser2.parse(partDoc)
        
        for m in newPart.measures {
            // todo
        }
    }

}
