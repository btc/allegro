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
    func noteModified(in measure: Int, at position: Rational)
}

extension PartStoreObserver {
    func partStoreChanged() {
        // default impl
    }
    func noteAdded(in measure: Int, at position: Rational) {
        // default impl
    }
    func noteModified(in measure: Int, at position: Rational) {
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

enum CompositionPerspective {
    case measure, overview
}

class PartStore {

    var currentMeasure: Int = 0 {
        didSet {
            let valueChanged = oldValue != currentMeasure
            if valueChanged {
                // de-select notes when measure changes!
                selectedNote = nil
            }
        }
    }

    var selectedNote: Rational? {
        didSet {
            notify()
        }
    }

    var mode: CompositionMode {
        didSet {
            notify()
        }
    }

    var view: CompositionPerspective = .measure {
        didSet {
            notify()
        }
    }

    var measureCount: Int {
        return part.measures.count
    }

    var newNote: Note.Value = .whole {
        didSet {
            notify()
        }
    }

    let part: Part

    private var observers: [Weak] = [Weak]()

    init(part: Part, mode: CompositionMode = .edit) {
        self.part = part
        self.mode = mode

        if part.measures.count == 0 {
            part.extend() // ensures part always has at least one measure. that way `currentMeasure` always points to valid index
        }
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

    // general notification must always be sent to observers
    private func notify() {
        // prunes released objects as it iterates
        observers = observers.filter {
            guard let value = $0.value else { return false }
            value.partStoreChanged()
            return true
        }
    }

    private func notify(addedNoteInMeasure index: Int, at position: Rational) {
        observers.forEach { $0.value?.noteAdded(in: index, at: position) }
    }

    private func notify(modifiedNoteInMeasure index: Int, at position: Rational) {
        observers.forEach { $0.value?.noteModified(in: index, at: position) }
    }

    private func extendIfNecessaryToAccessMeasure(at index: Int) {
        var extended = false
        while part.measures.count <= index + 1 {
            part.extend()
            extended = true
        }
        if extended {
            notify()
        }
    }

    func insert(note: Note, intoMeasureIndex i: Int, at desiredPosition: Rational) -> Rational? {
        extendIfNecessaryToAccessMeasure(at: i)
        Log.info?.message("insert \(note.duration.description) into measure \(i) at \(desiredPosition.lowestTerms)")
        let actualPosition = part.insert(note: note, intoMeasureIndex: i, at: desiredPosition)

        if let ap = actualPosition {
            selectedNote = nil // our policy is to deselect notes on insert
            notify()
            notify(addedNoteInMeasure: i, at: ap)
        }
        return actualPosition
    }

    func removeNote(fromMeasureIndex i: Int, at position: Rational) {
        if part.removeNote(fromMeasureIndex: i, at: position) {
            notify()
            Log.info?.message("removed note at \(position.lowestTerms)")
        }
    }

    func removeAndReturnNote(fromMeasure index: Int, at position: Rational) -> Note? {
        let note = part.measures[index].removeAndReturnNote(at: position)
        notify()
        return note
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
            notify(modifiedNoteInMeasure: index, at: position)
        }
        return succeeded
    }

    func measure(at index: Int, extend: Bool) -> MeasureViewModel {
        if extend {
            extendIfNecessaryToAccessMeasure(at: index)
        }
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
        notify(modifiedNoteInMeasure: index, at: position)
        return true
    }

    // returns false if no note exists at the given measure and position
    func toggleRest(inMeasure index: Int, at position: Rational) -> Bool {
        Log.info?.message("toggle rest at \(position)")
        guard let n = part.measures[index].note(at: position) else { return false }
        n.rest = !n.rest
        notify()
        notify(modifiedNoteInMeasure: index, at: position)
        return true
    }
    
    func setKeySignature(keySignature: Key) {
        part.setKeySignature(keySignature: keySignature)
        notify()
    }
    
    func setTimeSignature(timeSignature: Rational) {
        if !hasNotes() {
            part.setTimeSignature(timeSignature: timeSignature)
        }
        notify()
    }
    
}
