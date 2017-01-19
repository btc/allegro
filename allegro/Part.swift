//
//  Part.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

struct Part {
    
    // beats per minute (bpm) eg. 120
    var tempo: Int = 120
    
    var composer: String = ""
    var title: String = ""
    var comment: String = ""
    
    // ordered list of measures in the piece
    fileprivate var measures: [Measure] = [Measure()]
    
    // initialize with 1 empty measure
    init() {
        self.measures.append(Measure())
        
    }
    
}
