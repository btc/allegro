//
//  Key.swift
//  allegro
//
//  Created by Nikhil Lele on 1/17/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

struct Key {
    // Represents a musical key eg. G Major or d minor
    static let cSharpMajor = Key(mode: .major, fifths: 7)
    static let fSharpMajor = Key(mode: .major, fifths: 6)
    static let bMajor = Key(mode: .major, fifths: 5)
    static let eMAjor = Key(mode: .major, fifths: 4)
    static let aMajor = Key(mode: .major, fifths: 3)
    static let dMajor = Key(mode: .major, fifths: 2)
    static let gMajor = Key(mode: .major, fifths: 1)
    static let cMajor = Key(mode: .major, fifths: 0)
    static let fMajor = Key(mode: .major, fifths: -1)
    static let bFlatMajor = Key(mode: .major, fifths: -2)
    static let eFlatMajor = Key(mode: .major, fifths: -3)
    static let aFlatMajor = Key(mode: .major, fifths: -4)
    static let dFlatMajor = Key(mode: .major, fifths: -5)
    static let gFlatMajor = Key(mode: .major, fifths: -6)
    static let cFlatMajor = Key(mode: .major, fifths: -7)
    
    // Useful unicode: ♯ sharp, ♭ flat, ♮ natural
    
    // Major or minor key determines how accidentals are used in the circle of fifths
    enum Mode {
        case major
        case minor
    }
    let mode: Key.Mode
    
    /* Highest and lowest acceptable values for key signature fifths */
    let maxFifth = 7
    let minFifth = -7
    
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
    var lettersWithAccidentals: Set<Note.Letter>
    
    /* The "number" of each letter's associated accidental for all major keys 
        i.e. B is always the first flat
        F is always the first sharp
        D is flatted 4th
        C is sharped 5th, etc. etc.
     */
    static let KeyNumbers: [Int: Note.Letter] = [
        -7: .F,
        -6: .C,
        -5: .G,
        -4: .D,
        -3: .A,
        -2: .E,
        -1: .B,
        0: .C,
        1: .F,
        2: .C,
        3: .G,
        4: .D,
        5: .A,
        6: .E,
        7: .B
    ]
    
    
    // default key is C Major, which has no sharps or flats
    init(mode: Key.Mode = .major, fifths: Int = 0) {
        self.mode = mode
        self.fifths = fifths
        lettersWithAccidentals = []
        // add sharped letters to lettersWithAccidentals
        if fifths > 0 {
            for index in stride(from: fifths, through: 1, by: -1) {
                lettersWithAccidentals.insert(Key.KeyNumbers[index] ?? .C)
            }
        }
        // add flatted letters to lettersWithAccidentals
        if fifths < 0 {
            for index in stride(from: fifths, through: -1, by: 1) {
                lettersWithAccidentals.insert(Key.KeyNumbers[index] ?? .C)
            }
        }
    }
    
    // Returns true if the current note's letter matches an accidental in the key signature
    func keyHit(currentNoteLetter: Note.Letter) -> Note.Accidental? {
        if lettersWithAccidentals.contains(currentNoteLetter) {
            return (fifths > 0) ? .sharp : .flat
        }
        return nil
    }
    
    var successor:Int {
        if fifths == maxFifth {
            return fifths
        } else {
            return fifths + 1
        }
    }
    
    var predecessor:Int {
        if fifths == minFifth {
            return fifths
        } else {
            return fifths - 1
        }
    }
}

