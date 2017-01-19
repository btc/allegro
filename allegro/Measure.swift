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
    
    // TODO time signature and duration checking (see #37)
    // TODO collection of notes (see #40)
    
    // initialize with a Key
    init(key: Key = Key()) {
        self.key = key
    }
    
}
