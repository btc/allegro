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

class MusicXMLParser : PartStoreObserver {
    var store: PartStore
    var partDoc: AEXMLDocument = AEXMLDocument()

    // also called ticks per quarter note. 4 because the minimum note is 1/16
    private let divisionsPerQuarterNote: Rational = 4

    // generate partDoc from the music model in the Store
    // traverses each Note in each Measure in the Part
    fileprivate func generate() {

        partDoc = AEXMLDocument()

        //TODO add doctype, but not as a child because we don't want /> at the end
//        let doctypeString = "!DOCTYPE score-partwise PUBLIC \"-//Recordare//DTD MusicXML 3.0 Partwise//EN\" \"http://www.musicxml.org/dtds/partwise.dtd\""
//        let _ = partDoc.addChild(name: doctypeString)

        let score_partwise = partDoc.addChild(name: "score-partwise", attributes: ["version": "3.0"])
        let part_list = score_partwise.addChild(name: "part-list")
        
        let score_part = part_list.addChild(name: "score-part", attributes: ["id": "P1"])
        let _ = score_part.addChild(name: "part-name", value: "\(store.part.title)")
        
        let part = score_partwise.addChild(name: "part", attributes: ["id:": "P1"])

        // TODO: beams, flipped, triplets, ties
        // TODO: don't include last measure if it is empty

        for (i,m) in store.part.measures.enumerated() {

            // make a new measure
            let measure = part.addChild(name: "measure", attributes: ["number": "\(i+1)"])
            let attributes = measure.addChild(name: "attributes")

            // NB. divisions per quarter note. 4 because the minimum note is 1/16
            let _ = attributes.addChild(name: "divisions", value: "\(divisionsPerQuarterNote.numerator)")

            let key = attributes.addChild(name: "key")
            let _ = key.addChild(name: "fifths", value: "\(m.keySignature.fifths)")

            let time = attributes.addChild(name: "time")
            let _ = time.addChild(name: "beats", value: "\(m.timeSignature.numerator)")
            let _ = time.addChild(name: "beat-type", value: "\(m.timeSignature.denominator)")

            let clef = attributes.addChild(name: "clef")
            let _ = clef.addChild(name: "sign", value: "G")
            let _ = clef.addChild(name: "line", value: "2")

            for notePos in m.notes {
                // make a new note

                let n = notePos.note

                let note = measure.addChild(name: "note")

                let pitch = note.addChild(name: "pitch")
                let _ = pitch.addChild(name: "step", value: n.letter.description)
                let _ = pitch.addChild(name: "alter", value: "\(n.accidental.rawValue)")
                let _ = pitch.addChild(name: "octave", value: "\(n.octave)" )

                let duration = (n.duration * divisionsPerQuarterNote).numerator
                let _ = note.addChild(name: "duration", value: "\(duration)")

                let _ = note.addChild(name: "type", value: "\(n.value.rawValue)")

                if n.rest {
                    note.addChild(name: "rest")
                }

                // custom rational position element
                let position = note.addChild(name: "rational-position")
                let _ = position.addChild(name: "numerator", value: "\(notePos.pos.numerator)")
                let _ = position.addChild(name: "denominator", value: "\(notePos.pos.denominator)")

                // TODO dots

            }
        }
    }

    // parse an AEXMLElement that represents a Note and return it
    private func parseNote(noteElement: AEXMLElement) -> (note: Note, position: Rational) {

        // is there some way to make this cleaner using optionals?
        // right now there are defualt values here and in the if statements
        var value = Note.Value.quarter
        var letter = Note.Letter.C
        var octave = 4
        var accidental = Note.Accidental.natural
        var rest = false

        // check for all parts of pitch
        if let pitchElem = getFirstChildMatch(elem: noteElement, name: "pitch") {

            // step is the letter A-G
            if let stepElem = getFirstChildMatch(elem: pitchElem, name: "step") {
                let stepString = stepElem.value ?? "C"
                letter = Note.Letter(rawValue: stepString) ?? Note.Letter.C
            }

            // alter is the accidental eg. natural, flat, sharp
            if let alterElem = getFirstChildMatch(elem: pitchElem, name: "alter") {
                let alterString = alterElem.value ?? "0"
                let alterInt = Int(alterString) ?? 0
                accidental = Note.Accidental(rawValue: alterInt) ?? Note.Accidental.natural
            }

            // octave is an int
            if let octaveElem = getFirstChildMatch(elem: pitchElem, name: "octave") {
                let octaveString = octaveElem.value ?? "4"
                octave = Int(octaveString) ?? 4
            }
        }

        // check for note type, also called value. eg. quarter, eighth, etc
        if let typeElem = getFirstChildMatch(elem: noteElement, name: "type") {
            let typeString = typeElem.value ?? "quarter"
            value = Note.Value(rawValue: typeString) ?? Note.Value.quarter
        }

        // check for rest
        if let _ = getFirstChildMatch(elem: noteElement, name: "rest") {
            rest = true
        }

        // create note
        let note = Note(value: value, letter: letter, octave: octave, accidental: accidental, rest: rest)

        // TODO dots

        // set the rational position
        var position: Rational = 0
        if let positionElem = getFirstChildMatch(elem: noteElement, name: "rational-position") {
            var numerator = 0
            var denominator = 1

            if let numeratorElem = getFirstChildMatch(elem: positionElem, name: "numerator") {
                let numeratorString = numeratorElem.value ?? "0"
                numerator = Int(numeratorString) ?? 0
            }

            if let denominatorElem = getFirstChildMatch(elem: positionElem, name: "denominator") {
                let denominatorString = denominatorElem.value ?? "1"
                denominator = Int(denominatorString) ?? 1
            }
            position = Rational(numerator, denominator) ?? 0
        }


        return (note, position)
    }

    // Parse an AEXMLElement that represents a Measure and return it
    private func parseMeasure(measureElement: AEXMLElement) -> (measureIndex: Int, measure: SimpleMeasure) {
        var measure = SimpleMeasure()

        // number is the index of the measure
        // should this default to something else?
        let numberString = measureElement.attributes["number"] ?? "0"
        let number = (Int(numberString) ?? 1) - 1

        // check for key, as an int in the circle of fifths cf. Key.swift
        if let keyElem = getFirstChildMatch(elem: measureElement, name: "key") {
            let keySigString = keyElem.value ?? "0"
            let keySigInt = Int(keySigString) ?? 0
            measure.keySignature.fifths = keySigInt
        }

        // check for the time signature and convert to rational
        if let timeElem = getFirstChildMatch(elem: measureElement, name: "time") {
            var numerator = 4
            var denominator = 4
            if let beatsElem = getFirstChildMatch(elem: timeElem, name: "beats") {
                let beatsString = beatsElem.value ?? "4"
                numerator = Int(beatsString) ?? 4
            }
            if let beatTypeElem = getFirstChildMatch(elem: timeElem, name: "beat-type") {
                let beatTypeString = beatTypeElem.value ?? "4"
                denominator = Int(beatTypeString) ?? 4
            }
            measure.timeSignature = Rational(numerator, denominator) ?? 4/4
        }

        // find all note elements and parse them
        let noteElements = getChildMatches(elem: measureElement, name: "note")
        for noteElem in noteElements {
            let (note, position) = parseNote(noteElement: noteElem)
            guard measure.insert(note: note, at: position) else {
                Log.error?.message("parseMeasure: unable to insert note: \(note) at \(position)")
                continue
            }
        }

        return (number, measure)
    }

    // parses an XML document and creates a Part with Measures and Notes
    func parse(partDoc: AEXMLDocument) -> Part? {

        // TODO check the doctype

        let part = Part()

        // Set part title. We need to do:
        // partDoc -> score-partwise -> part-list -> score-part -> part-name
        guard let part_list = getFirstChildMatch(elem: partDoc.root, name: "part-list") else { return nil }
        guard let score_part = getFirstChildMatch(elem: part_list, name: "score-part") else { return nil }
        guard let part_name = getFirstChildMatch(elem: score_part, name: "part-name") else { return nil }
        part.title = part_name.value ?? ""

        // find the part
        guard let partElem = getFirstChildMatch(elem: partDoc.root, name: "part") else { return nil }

        // loop over all measures and parse them
        let measureElements = getChildMatches(elem: partElem, name: "measure")
        for measureElem in measureElements {
            let (i, measure) = parseMeasure(measureElement: measureElem)

            // extend so that we have enough measures
            while !part.measures.indices.contains(i) {
                part.extend()
            }
            part.setMeasure(measureIndex: i, measure: measure)
        }

        return part
    }

    func save(filename: String) {
        // TODO write to disk

        Log.info?.message("saving MusicXML to \(filename)")

        let msg: String = "\n" + partDoc.xml + "\n"
        Log.info?.message(msg)
    }

    func load(filename: String) {
        Log.info?.message("reading MusicXML from \(filename)")

//        let xmlDoc = try AEXMLDocument(xml: data, options: options)

        // TODO
        // open file from disk
        // create AEXMLDocument
        // call parse to create Part
        // create PartStore with Part <-- this could be higher up
    }
    
    init(store: PartStore) {
        self.store = store
        store.subscribe(self)
    }


    // TODO make extensions
    func getFirstChildMatch(elem: AEXMLElement, name: String) -> AEXMLElement? {
        return getChildMatches(elem: elem, name: name).first
    }
    func getChildMatches(elem: AEXMLElement, name: String) -> [AEXMLElement] {
        return elem.children.filter({$0.name == name})
    }

    func partStoreChanged() {
        Log.info?.message("MusicXMLParser re-parsing")
        generate()
    }
    
}

