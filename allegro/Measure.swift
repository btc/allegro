//
//  Measure.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

struct Measure {
    
    // the key signature eg. G Major or d minor
    let key: Key
    
    let time: Rational
    
    // TODO collection of notes (see #40)
    // simplest way to hold notes
    let notes: [Note] = [Note]()
    
    // default time is 4/4 which simplifies to 1
    init(time: Rational = Rational(1), key: Key = Key()) {
        self.time = time
        self.key = key
    }
    
    // TODO duration checking (see #37)
}
