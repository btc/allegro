//
//  PartSaver.swift
//  allegro
//
//  Created by Nikhil Lele on 3/2/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

class PartSaver : PartStoreObserver {

    private let partStore: PartStore

    private(set) var filename: String

    init(partStore: PartStore, filename: String) {
        self.partStore = partStore
        self.filename = filename

        self.partStore.subscribe(self)
    }

    // save on every change to the part store
    // TODO to allow undo we can save with different file names for the versions
    func partStoreChanged() {
        // save to disk
        PartFileManager.save(part: partStore.part, as: filename)
    }
}
