//
//  PartSaver.swift
//  allegro
//
//  Created by Nikhil Lele on 3/2/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

class PartSaver : PartStoreObserver {

    var partMetadata: PartMetadata

    var partStore: PartStore {
        didSet {
            partStore.subscribe(self)
        }
    }

    private(set) var filename: String

    init(partStore: PartStore, partMetadata: PartMetadata, filename: String) {
        self.partStore = partStore
        self.partMetadata = partMetadata
        self.filename = filename
    }

    // save on every change to the part store
    // TODO to allow undo we can save with different file names for the versions
    func partStoreChanged() {
        // save to disk
        PartFileManager.save(part: partStore.part, partMetadata: partMetadata, as: filename)
    }
}
