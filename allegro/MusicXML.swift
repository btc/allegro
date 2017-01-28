//
//  MusicXML.swift
//  allegro
//
//  Created by Nikhil Lele on 1/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//


// Traverses the music model to generate a MusicXML document
// See: http://usermanuals.musicxml.com/MusicXML/MusicXML.htm

// TODO import the XML library

class MusicXMLParser {
    var store: PartStore? {
        willSet {
            if let store = store {
                store.unsubscribe(self)
            }
        }
        didSet {
            if let store = store {
                store.subscribe(self)
            }
        }
    }
    
    fileprivate func parse() {
        // TODO
    }
}

extension MusicXMLParser: PartStoreObserver {
    func partStoreChanged() {
        parse()
    }
}
