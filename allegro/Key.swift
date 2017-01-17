//
//  Key.swift
//  allegro
//
//  Created by Nikhil Lele on 1/17/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

class Key {
    // Represents a musical key eg. G Major or d minor
    
    // Useful unicode: ♯ sharp, ♭ flat, ♮ natural
    
    let MAJOR = 0
    let MINOR = 1
    var mode: Int
    
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
    init() {
        mode = MAJOR
        fifths = 0
    }
    
    // lookup the name of the key in the circle of fifths
    func getName() -> String {
        var prefix = ""
        var suffix = ""
        if mode == MAJOR {
            prefix = MajorCoF[fifths]! // nlele: why is the ! necessary?
            suffix = "M"
            
        } else {
            prefix = MinorCoF[fifths]!
            suffix = "m"
        }
        
        return "\(prefix)\(suffix)"
    }
}

