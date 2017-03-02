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

    init(partStore: PartStore, partMetadata: PartMetadata) {
        self.partStore = partStore
        self.partMetadata = partMetadata
    }

    // save on every change to the part store
    // TODO to allow undo we can save with different file names for the versions
    func partStoreChanged() {
        // save to disk
    }
}
