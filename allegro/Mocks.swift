//
//  Mocks.swift
//  allegro
//
//  Created by Nikhil Lele on 1/23/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational


let mocks: [Part] = [parsePart(CMajor), parsePart(DMajor)]

private let CMajor = [
    "4 C 4 n",
    "4 D 4 n",
    "4 E 4 n",
    "4 F 4 n",
    "4 G 4 n",
    "4 A 4 n",
    "4 B 4 n",
    "4 C 5 n",
    "8 C 4 n",
    "8 D 4 n",
    "8 E 4 n",
    "8 F 4 n",
    "8 G 4 n",
    "8 A 4 n",
    "8 B 4 n",
    "8 C 5 n"
]

private let DMajor = [
    "4 D 4 n",
    "4 E 4 n",
    "4 F 4 s",
    "4 G 4 n",
    "4 A 4 n",
    "4 B 4 n",
    "4 C 5 s",
    "4 D 5 n",
    "8 D 4 n",
    "8 E 4 n",
    "8 F 4 s",
    "8 G 4 n",
    "8 A 4 n",
    "8 B 4 n",
    "8 C 5 s",
    "8 D 5 n"
]

// 4 C 4 n -> quarternote, C, octave 4, natural
private func parse(_ input: String) -> Note {
    let comp = input.components(separatedBy: " ")
    
    var value: Note.Value
    switch comp[0] {
    case "1": value = .whole
    case "2": value = .half
    case "4": value = .quarter
    case "8": value = .eighth
    case "16": value = .sixteenth
    case "32": value = .thirtysecond
    case "64": value = .sixtyfourth
    case "128": value = .onetwentyeighth
    default: value = .quarter
    }
    
    var letter: Note.Letter
    switch comp[1] {
    case "A": letter = .A
    case "B": letter = .B
    case "C": letter = .C
    case "D": letter = .D
    case "E": letter = .E
    case "F": letter = .F
    case "G": letter = .G
    default: letter = .C
    }
    
    var octave: Int = 5
    if let parsedOctave: Int = Int(comp[2]) {
        octave = parsedOctave
    }
    
    var accidental: Note.Accidental
    switch comp[3] {
    case "ss": accidental = .doubleSharp
    case "s": accidental = .sharp
    case "n": accidental = .natural
    case "f": accidental = .flat
    case "ff": accidental = .doubleFlat
    default: accidental = .natural
    }
    
    return Note(value: value, letter: letter, octave: octave, accidental: accidental, rest: false)
}

/*
 v2: 
 private func parsePart(_ partArray: [String], key: Key) -> Part {
 mock parts should have keys for testing
 */

private func parsePart(_ partArray: [String]) -> Part {
    let part = Part()
    for noteString in partArray {
        part.appendNote(note: parse(noteString))
    }
    return part
}

func mockPart(_ name: String) -> Part {
    
    switch name {
    case "CMajor":
        return parsePart(CMajor)
        
    case "DMajor":
        return parsePart(DMajor)
        
    default:
        let part = Part()
        _ = part.insert(note: Note(value: .whole, letter: .C, octave: 4), intoMeasureIndex: 0, at: 0)
        return part
    }
}
