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
    
    /* 
        Represents the number of accidentals in the key (according to the circle of fifths starting with 0 => C Major
        (-) => number of flats
        (+) => number of sharps
        e.g. fifths == 1 -> 1 sharp => key of G Major
             fifths == 2 -> 2 sharps => key of D Major
             fifths == -3 -> 3 flats => key of E flat Major
     */
    var fifths: Int
    
    /* List of letters that have accidentals in this key */
    var lettersWithAccidentals: Set<String>
    
    /* The "number" of each letter's associated accidental for all major keys 
        i.e. B is always the first flat
        F is always the first sharp
        D is flatted 4th
        C is sharped 5th, etc. etc.
     */
    let KeyNumbers = [
        -7: "F",
        -6: "C",
        -5: "G",
        -4: "D",
        -3: "A",
        -2: "E",
        -1: "B",
         0: "C",
         1: "F",
         2: "C",
         3: "G",
         4: "D",
         5: "A",
         6: "E",
         7: "B"
    ]
    
    // default key is C Major, which has no sharps or flats
    init(mode: Key.Mode = .major, fifths: Int = 0) {
        self.mode = mode
        self.fifths = fifths
        lettersWithAccidentals = []
        // add sharped letters to lettersWithAccidentals
        if fifths > 0 {
            for index in stride(from: fifths, through: 1, by: -1) {
                lettersWithAccidentals.insert(KeyNumbers[index] ?? "C")
            }
        }
        // add flatted letters to lettersWithAccidentals
        if fifths < 0 {
            for index in stride(from: fifths, through: 1, by: 1) {
                lettersWithAccidentals.insert(KeyNumbers[index] ?? "C")
            }
        }
    }
    
    // Returns true if the current note's letter matches an accidental in the key signature
    func keyHit(currentNoteLetter: Note.Letter) -> Note.Accidental? {
        if lettersWithAccidentals.contains(currentNoteLetter.description) {
            return (fifths > 0) ? .sharp : .flat
        }
        return nil
    }
}

