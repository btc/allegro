//
//  PartStore.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/21/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational


protocol PartStoreObserver: class {
    func partStoreChanged()
    func noteAdded(in measure: Int, at position: Rational)
}

extension PartStoreObserver {
    func partStoreChanged() {
        // default impl
    }
    func noteAdded(in measure: Int, at position: Rational) {
        // default impl
    }
}

private class Weak {
    private(set) weak var value: PartStoreObserver?

    init(_ value: PartStoreObserver?) {
        self.value = value
    }
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

    var selectedNoteValue: Note.Value = .whole {
        didSet {
            notify()
        }
    }

    let part: Part

    private var observers: [Weak] = [Weak]() {
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
        observer.partStoreChanged()
    }

    func unsubscribe(_ observer: PartStoreObserver) {
        observers = observers.filter {
            guard let value = $0.value else { return false } // prune released objects
            return value !== observer
        }
    }

    private func notify() {
        // prunes released objects as it iterates
        observers = observers.filter {
            guard let value = $0.value else { return false }
            value.partStoreChanged()
            return true
        }
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

    func insert(note: Note, intoMeasureIndex i: Int, at position: Rational) -> Rational? {
        extendIfNecessary(toAccessMeasureAtIndex: i)
        Log.info?.message("insert \(note.duration.description) into measure \(i) at \(position.lowestTerms)")
        let actualPosition = part.insert(note: note, intoMeasureIndex: i, at: position)

        if actualPosition != nil {
            notify()
            observers.forEach { $0.value?.noteAdded(in: i, at: position) }
        }
        return actualPosition
    }

    func removeNote(fromMeasureIndex i: Int, at position: Rational) {
        if part.removeNote(fromMeasureIndex: i, at: position) {
            notify()
            Log.info?.message("removed note at \(position.lowestTerms)")
        }
    }

    func toggleDot(inMeasure index: Int, at position: Rational, action: NoteAction) -> Bool {
        guard let note = part.measures[index].note(at: position) else { return false }
        let currentDot = note.dot
        var newDot: Note.Dot = .none // is always assigned a new value!
        switch action {
        case .toggleDoubleDot:
            newDot = currentDot == Note.Dot.double ? Note.Dot.none : Note.Dot.double
        case .toggleDot:
            newDot = currentDot == Note.Dot.single ? Note.Dot.none : Note.Dot.single
        default:
            return false
        }
        Log.info?.message("Change note at \(position) to \(newDot) dot at measure \(index)")
        let succeeded = part.dotNote(at: position, dot: newDot, atMeasureIndex: index)
        if succeeded {
            notify()
        }
        return succeeded
    }

    func measure(at index: Int) -> MeasureViewModel {
        extendIfNecessary(toAccessMeasureAtIndex: index)
        return MeasureViewModel(part.measures[index])
    }
    
    func hasNotes() -> Bool {
        for m in part.measures {
            if m.notes.count > 0 {
                return true
            }
        }
        return false
    }

    // returns false if no note exists at the given measure and position
    func setAccidental(_ accidental: Note.Accidental, inMeasure index: Int, at position: Rational) -> Bool {
        Log.info?.message("set accidental \(accidental) at \(position)")
        guard let n = part.measures[index].note(at: position) else { return false }
        n.accidental = accidental
        notify()
        return true
    }

    // returns false if no note exists at the given measure and position
    func changeNoteToRest(inMeasure index: Int, at position: Rational) -> Bool {
        Log.info?.message("change note to rest at \(position)")
        guard let n = part.measures[index].note(at: position) else { return false }
        n.rest = true
        notify()
        return true
    }
}
