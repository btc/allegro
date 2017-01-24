//
//  PartStore.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/21/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational

@objc protocol PartStoreObserver: AnyObject {
    func partStoreChanged()
}

class PartStore {

    private let part: Part

    var selectedNoteDuration: Note.Duration = .whole {
        didSet {
            notify()
        }
    }

    private var observers: [Weak<PartStoreObserver>] = [Weak<PartStoreObserver>]() {
        didSet {
            Log.info?.message("part store has \(observers.count) observers")
        }
    }

    var measureCount: Int {
        return part.measureCount + virtualMeasureCount
    }

    // the new, blank measures that haven't been created yet, but exists in UI. initialize with 1
    private var virtualMeasureCount = 1 {
        didSet {
            notify()
        }
    }

    init(part: Part) {
        self.part = part
    }

    func subscribe(_ observer: PartStoreObserver) {
        observers.append(Weak(observer))
    }

    func unsubscribe(_ observer: PartStoreObserver) {
        observers = observers.filter {
            guard let value = $0.value else { return false } // prune released objects
            return value !== observer
        }
    }

    private func notify() {
        observers.forEach { $0.value?.partStoreChanged() }
    }

    func insert(note: Note, intoMeasureIndex i: Int, at position: Rational) -> Bool {
        while part.measureCount <= i {
            part.extend() // allows caller to insert into a measure that doesn't exist until _now_.
        }
        Log.info?.message("insert \(note.duration.description) into measure \(i) at \(position)")
        let succeeded = part.insert(note: note, intoMeasureIndex: i, at: position)

        if succeeded {
            notify()
        }
        return succeeded
    }

    func getNotes(measureIndex i: Int) -> [(pos: Rational, note: Note)] {
        guard part.measures.indices.contains(i) else { return [] } // allows caller to create measures lazily
        return part.measures[i].getAllNotes()
    }

    func measure(at index: Int) -> Measure {

        if part.measures.indices.contains(index) {
            return part.measures[index]
        }

        // access is out of bounds. generate a new virtual measure

        // TODO(btc): recompute virtual measure count

        // else return a new measure with same time signature as previous
        if let last = part.measures.last {
            return Measure(time: last.timeSignature)
        }

        // else return a new measure
        return Measure()
    }
}
