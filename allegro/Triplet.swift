//
//  Triplet.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

class Triplet {
    var notes: [Note] = [Note]()
    
    init(notesArr: [Note]) {
        self.notes = notesArr
    }
    
    func isEmpty() -> Bool {
        // find any non-rests
        let results = notes.filter {$0.rest == false}
        return results.isEmpty
    }
}
