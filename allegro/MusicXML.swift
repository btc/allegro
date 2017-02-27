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
                let _ = pitch.addChild(name: "step", value: n.letter.step)
                let _ = pitch.addChild(name: "alter", value: "\(n.accidental.alter)")
                
                let _ = pitch.addChild(name: "octave", value: "\(n.octave)" )

                let duration = (n.duration * divisionsPerQuarterNote).numerator
                let _ = note.addChild(name: "duration", value: "\(duration)")

                let _ = note.addChild(name: "type", value: "\(n.value.type)")

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
        if let pitchElem = noteElement.firstChildMatch(name: "pitch") {

            // step is the letter A-G
            if let stepElem = pitchElem.firstChildMatch(name: "step") {
                letter = stepElem.safeValue(parse: Note.Letter.init, fallback: .C)
            }

            // alter is the accidental eg. natural, flat, sharp
            if let alterElem = pitchElem.firstChildMatch(name: "alter") {
                let alterInt = alterElem.safeValueInt(fallback: 0)
                accidental = Note.Accidental(alter: alterInt)
            }

            // octave is an int
            if let octaveElem = pitchElem.firstChildMatch(name: "octave") {
                octave = octaveElem.safeValueInt(fallback: 4)
            }
        }

        // check for note type, also called value. eg. quarter, eighth, etc
        if let typeElem = noteElement.firstChildMatch(name: "type") {
            value = typeElem.safeValue(parse: Note.Value.init, fallback: .quarter)
        }

        // check for rest
        if let _ = noteElement.firstChildMatch(name: "rest") {
            rest = true
        }

        // create note
        let note = Note(value: value, letter: letter, octave: octave, accidental: accidental, rest: rest)

        // TODO dots

        // set the rational position
        var position: Rational = 0
        if let positionElem = noteElement.firstChildMatch(name: "rational-position") {
            var numerator = 0
            var denominator = 1

            if let numeratorElem = positionElem.firstChildMatch(name: "numerator") {
                numerator = numeratorElem.safeValueInt(fallback: 0)
            }

            if let denominatorElem = positionElem.firstChildMatch(name: "denominator") {
                denominator = denominatorElem.safeValueInt(fallback: 1)
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
        if let keyElem = measureElement.firstChildMatch(name: "key") {
            measure.keySignature.fifths = keyElem.safeValueInt(fallback: 0)
        }

        // check for the time signature and convert to rational
        if let timeElem = measureElement.firstChildMatch(name: "time") {
            var numerator = 4
            var denominator = 4
            if let beatsElem = timeElem.firstChildMatch(name: "beats") {
                numerator = beatsElem.safeValueInt(fallback: 4)
            }
            if let beatTypeElem = timeElem.firstChildMatch(name: "beat-type") {
                denominator = beatTypeElem.safeValueInt(fallback: 4)
            }
            measure.timeSignature = Rational(numerator, denominator) ?? 4/4
        }

        // find all note elements and parse them
        let noteElements = measureElement.childrenMatch(name: "note")
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
        guard let part_list = partDoc.root.firstChildMatch(name: "part-list") else { return nil }
        guard let score_part = part_list.firstChildMatch(name: "score-part") else { return nil }
        guard let part_name = score_part.firstChildMatch(name: "part-name") else { return nil }
        part.title = part_name.value ?? ""

        // find the part
        guard let partElem = partDoc.root.firstChildMatch(name: "part") else { return nil }

        // loop over all measures and parse them
        let measureElements = partElem.childrenMatch(name: "measure")
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

    // attempts to load a file as XML and then parse it as a Part
    func load(filename: String) -> Part? {
        Log.info?.message("reading MusicXML from \(filename)")

        // TODO do we have to do something for the path for when we save parts on the phone?
        guard
            let xmlPath = Bundle.main.path(forResource: filename, ofType: "xml"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath))
            else {
                Log.error?.message("Unable to open file")
                return nil
        }

        guard let newPartDoc = try? AEXMLDocument(xml: data) else {
            Log.error?.message("Unable to create AEXMLDocument from file")
            return nil
        }

        guard let newPart = parse(partDoc: newPartDoc) else {
            Log.error?.message("Unable to parse AEXMLDocument into Part")
            return nil
        }

        partDoc = newPartDoc
        return newPart
    }
    
    init(store: PartStore) {
        self.store = store
        store.subscribe(self)
    }

    func partStoreChanged() {
        Log.info?.message("MusicXMLParser re-parsing")
        generate()
    }
}

// extend Note.Accidental to translate b/t MusicXML definition as an Int
extension Note.Accidental {
    init(alter input: Int) {
        switch input {
        case -2: self = .doubleFlat
        case -1: self = .flat
        case 0: self = .natural
        case 1: self = .sharp
        case 2: self = .doubleSharp
        default: self = .natural
        }
    }
    var alter: Int {
        switch self {
        case .doubleFlat: return -2
        case .flat: return -1
        case .natural: return 0
        case .sharp: return 1
        case .doubleSharp: return 2
        }
    }
}

// parse from a String
extension Note.Letter {
    init(step input: String) {
        switch input {
        case "A": self = .A
        case "B": self = .B
        case "C": self = .C
        case "D": self = .D
        case "E": self = .E
        case "F": self = .F
        case "G": self = .G
        default: self = .C
        }
    }
    var step: String {
        switch self {
        case .A: return "A"
        case .B: return "B"
        case .C: return "C"
        case .D: return "D"
        case .E: return "E"
        case .F: return "F"
        case .G: return "G"
        }
    }
}

// parse from a String
extension Note.Value {
    init (type input: String) {
        switch input {
        case "whole": self = .whole
        case "half": self = .half
        case "quarter": self = .quarter
        case "eighth": self = .eighth
        default: self = .quarter
        }
    }
    var type: String {
        switch self {
        case .whole: return "whole"
        case .half: return "half"
        case .quarter: return "quarter"
        case .eighth: return "eighth"
        case .sixteenth: return "sixteenth"
        }
    }
}

