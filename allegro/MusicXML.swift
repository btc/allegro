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
    var store: PartStore {
        willSet {
            store.unsubscribe(self)
        }
        didSet {
            store.subscribe(self)
        }
    }
    var partDoc: AEXMLDocument = AEXMLDocument()
    
    fileprivate func parse() {

        //TODO add doctype, but not as a child because we don't want /> at the end
//        let doctypeString = "!DOCTYPE score-partwise PUBLIC \"-//Recordare//DTD MusicXML 3.0 Partwise//EN\" \"http://www.musicxml.org/dtds/partwise.dtd\""
//        let _ = partDoc.addChild(name: doctypeString)

        let score_partwise = partDoc.addChild(name: "score-partwise", attributes: ["version": "3.0"])
        let part_list = score_partwise.addChild(name: "part-list")
        
        let score_part = part_list.addChild(name: "score-part", attributes: ["id": "P1"])
        let _ = score_part.addChild(name: "part-name", value: "\(store.part.title)")
        
        let part = score_partwise.addChild(name: "part", attributes: ["id:": "P1"])
        
        // TODO iterate through measures
    }

    func save(filename: String) {
        // TODO write to disk

        let msg: String = "\n" + partDoc.xml + "\n"
        print(msg)
    }
    
    init(store: PartStore) {
        self.store = store
        parse()
    }
}

extension MusicXMLParser: PartStoreObserver {
    func partStoreChanged() {
        Log.info?.message("MusicXMLParser re-parsing")
        parse()
    }
}
