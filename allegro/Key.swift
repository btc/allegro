//
//  Key.swift
//  allegro
//
//  Created by Nikhil Lele on 1/17/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

struct Key {
    // Represents a musical key eg. G Major or d minor
    
    // Useful unicode: ♯ sharp, ♭ flat, ♮ natural
    
    // Major or minor key determines how accidentals are used in the circle of fifths
    enum Mode {
        case major
        case minor
    }
    let mode: Key.Mode
    
    // represents the number of accidentals in the key following the circle of fifths
    // negative numbers represent number of flats
    // positive numbers represent number of sharps
    var fifths: Int
    
    let MajorCoF = [-6: "G♭",
                    -5: "D♭",
                    -4: "A♭",
                    -3: "E♭",
                    -2: "B♭",
                    -1: "F",
                    0: "C",
                    1: "G",
                    2: "D",
                    3: "A",
                    4: "E",
                    5: "F♯",
                    6: "C♯"]
    
    let MinorCoF = [-6: "e♭",
                    -5: "b♭",
                    -4: "f",
                    -3: "c",
                    -2: "g",
                    -1: "d",
                    0: "a",
                    1: "e",
                    2: "b",
                    3: "f♯",
                    4: "c♯",
                    5: "g♯",
                    6: "d♯"]
    
    // default key is C Major, which has no sharps or flats
    init(mode: Key.Mode = .major, fifths: Int = 0) {
        self.mode = mode
        self.fifths = fifths
    }
    
    // lookup the name of the key in the circle of fifths
    func getName() -> String {
        switch mode {
        case .major:
            guard let root = MajorCoF[fifths] else { return "" }
            return "\(root)M"
        case .minor:
            guard let root = MinorCoF[fifths] else { return "" }
            return "\(root)m"
        }
    }
    
    // Returns true if the current note's letter matches an accidental in the key signature
    func keyHit(currentNoteLetter: Note.Letter) -> Bool {
        return false
    }
}

