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

    func testParse() {
        let part = Part()
        let store = PartStore(part: part)


        let n0 = Note(value: .quarter, letter: .A, octave: 4)
        let _ = part.insert(note: n0, intoMeasureIndex: 0, at: 1/4)

        let parser = MusicXMLParser(store: store)


        parser.save(filename: "test.xml")
    }

}
