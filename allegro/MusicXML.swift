//
//  MusicXML.swift
//  allegro
//
//  Created by Nikhil Lele on 1/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//


// Traverses the music model to generate a MusicXML document
// See: http://usermanuals.musicxml.com/MusicXML/MusicXML.htm

import AEXML

class MusicXMLParser {
    var store: PartStore? {
        willSet {
            if let store = store {
                store.unsubscribe(self)
            }
        }
        didSet {
            if let store = store {
                store.subscribe(self)
            }
        }
    }
    
    let part: Part
    
    fileprivate func parse() {
        let partDoc = AEXMLDocument()
        // TODO doctype
        let score_partwise = partDoc.addChild(name: "score-partwise", attributes: ["version": "3.0"])
        let part_list = score_partwise.addChild(name: "part-list")
        
        // TODO part name properly
        let score_part = part_list.addChild(name: "score-part", attributes: ["id": "P1"])
        let part_name = score_part.addChild(name: "part-name", value: "\(store)")
        
        let part = score_partwise.addChild(name: "part", attributes: ["id:": "P1"])
        
        // TODO iterate through measures
    }
    
    init(part: Part) {
        self.part = part
    }
}

extension MusicXMLParser: PartStoreObserver {
    func partStoreChanged() {
        parse()
    }
}
