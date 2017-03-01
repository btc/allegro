//
//  PartFileManager.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

class PartFileManager {

    var count: Int {
        return 1
    }

    func load(forIndex: Int) -> Part {

        let p = Part() // TODO
        p.title = "sample"
        return p
    }
}
