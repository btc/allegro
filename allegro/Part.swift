//
//  Part.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

struct Part {
    
    // beats per minute (bpm) eg. 120
    let tempo: Int
    
    let composer: String
    let title: String
    let comment: String
    
    // ordered list of measures in the piece
    var measures: [Measure]
    
    // initialize with standard 120 bpm and 1 empty measure
    init(tempo: Int = 120, composer: String = "", title: String = "",
         comment: String = "", measures: [Measure] = [Measure]()) {
        self.tempo = tempo
        self.composer = composer
        self.title = title
        self.comment = comment
        
        self.measures = measures
        self.measures.append(Measure())
        
    }
    
}
