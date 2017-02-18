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
import Rational

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

    // also called ticks per quarter note. 4 because the minimum note is 1/16
    private let divisionsPerQuarterNote: Rational = 4
    
    fileprivate func parse() {

        //TODO add doctype, but not as a child because we don't want /> at the end
//        let doctypeString = "!DOCTYPE score-partwise PUBLIC \"-//Recordare//DTD MusicXML 3.0 Partwise//EN\" \"http://www.musicxml.org/dtds/partwise.dtd\""
//        let _ = partDoc.addChild(name: doctypeString)

        let score_partwise = partDoc.addChild(name: "score-partwise", attributes: ["version": "3.0"])
        let part_list = score_partwise.addChild(name: "part-list")
        
        let score_part = part_list.addChild(name: "score-part", attributes: ["id": "P1"])
        let _ = score_part.addChild(name: "part-name", value: "\(store.part.title)")
        
        let part = score_partwise.addChild(name: "part", attributes: ["id:": "P1"])

        for (i,m) in store.part.measures.enumerated() {
            // make a new measure
            let measure = part.addChild(name: "measure", attributes: ["number": "\(i+1)"])
            let attributes = measure.addChild(name: "attributes")

            // NB. divisions per quarter note. 4 because the minimum note is 1/16
            let _ = attributes.addChild(name: "divisions", value: "\(divisionsPerQuarterNote.numerator)")

            let key = attributes.addChild(name: "key")
            let _ = key.addChild(name: "fifths", value: "\(m.key.fifths)")

            let time = attributes.addChild(name: "time")
            let _ = time.addChild(name: "beats", value: "\(m.timeSignature.numerator)")
            let _ = time.addChild(name: "beat-type", value: "\(m.timeSignature.denominator)")

            let clef = attributes.addChild(name: "clef")
            let _ = clef.addChild(name: "sign", value: "G")
            let _ = clef.addChild(name: "line", value: "2")

            for (_,n) in m.notes {
                // make a new note

                let note = measure.addChild(name: "note")

                let pitch = note.addChild(name: "pitch")
                let _ = pitch.addChild(name: "step", value: n.letter.description)
                let _ = pitch.addChild(name: "alter", value: "\(n.accidental.rawValue)")
                let _ = pitch.addChild(name: "octave", value: "\(n.octave)" )

                let duration = (n.duration * divisionsPerQuarterNote).numerator
                let _ = note.addChild(name: "duration", value: "\(duration)")

                let _ = note.addChild(name: "type", value: "\(n.value.description)")
                
            }
        }
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
        // TODO this doesn't get called!
        Log.info?.message("MusicXMLParser re-parsing")
        parse()
    }
}
