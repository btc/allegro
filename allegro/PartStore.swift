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
        return part.measures.count
    }

    init(part: Part) {
        self.part = part
    }

    func subscribe(_ observer: PartStoreObserver) {
        observers.append(Weak(observer))
        // TODO(btc): should we notify the new observer immediately?
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

    func extendIfNecessary(toAccessMeasureAtIndex i: Int) {
        var extended = false
        while part.measures.count <= i + 1 {
            part.extend()
            extended = true
        }
        if extended {
            notify()
        }
    }

    func insert(note: Note, intoMeasureIndex i: Int, at position: Rational) -> Bool {
        extendIfNecessary(toAccessMeasureAtIndex: i)
        Log.info?.message("insert \(note.duration.description) into measure \(i) at \(position)")
        let succeeded = part.insert(note: note, intoMeasureIndex: i, at: position)

        if succeeded {
            notify()
        }
        return succeeded
    }

    func removeNote(fromMeasureIndex i: Int, at position: Rational) {
        part.removeNote(fromMeasureIndex: i, at: position)
    }

    func notes(atMeasureIndex i: Int) -> [(pos: Rational, note: Note)] {
        extendIfNecessary(toAccessMeasureAtIndex: i)
        return part.measures[i].getAllNotes()
    }

    func measure(at index: Int) -> Measure {
        extendIfNecessary(toAccessMeasureAtIndex: index)
        return part.measures[index]
    }
}
