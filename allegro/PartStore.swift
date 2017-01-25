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

enum CompositionMode {
    case edit, erase
}

class PartStore {

    var mode: CompositionMode {
        didSet {
            notify()
        }
    }

    var measureCount: Int {
        return part.measures.count
    }

    var selectedNoteDuration: Note.Duration = .whole {
        didSet {
            notify()
        }
    }

    private let part: Part

    private var observers: [Weak<PartStoreObserver>] = [Weak<PartStoreObserver>]() {
        didSet {
            Log.info?.message("part store has \(observers.count) observers")
        }
    }

    init(part: Part, mode: CompositionMode = .edit) {
        self.part = part
        self.mode = mode
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

    private func extendIfNecessary(toAccessMeasureAtIndex i: Int) {
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
        if part.removeNote(fromMeasureIndex: i, at: position) {
            notify()
        }
    }

    func measure(at index: Int) -> MeasureViewModel {
        extendIfNecessary(toAccessMeasureAtIndex: index)
        return MeasureViewModel(part.measures[index])
    }
}
