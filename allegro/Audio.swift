//
//  Audio.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/27/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import AudioKit
import Rational
import MusicKit

class Audio {
    var store: PartStore

    let mixer = AKMixer()
    let sequence = AKSequencer()

    init(store: PartStore) {
        self.store = store
        store.subscribe(self)



        let oscillator = AKFMOscillatorBank()
        oscillator.modulatingMultiplier = 3
        oscillator.modulationIndex = 0.3
        let melody = AKMIDINode(node: oscillator)
        _ = sequence.newTrack()
        sequence.tracks[0].setMIDIOutput(melody.midiIn)
        mixer.connect(melody)
        AudioKit.output = mixer
    }

    func start() {
        AudioKit.start()
    }

    func stop() {
        sequence.stop()
        AudioKit.stop()
    }
}

extension Audio: PartStoreObserver {
    func noteAdded(in measure: Int, at position: Rational) {

        sequence.tracks[0].clear()

        let m = store.part.measures[measure]

        let sequenceLength = AKDuration(beats: Double(m.timeSignature.numerator), tempo: Double(store.part.tempo))
        sequence.setLength(sequenceLength)

        guard let note = m.getNote(at: position) else { return }

        // let akpos = AKDuration(beats: Double(m.timeSignature.numerator) * position.double)
        let akpos = AKDuration(beats: 0)
        let akdur = AKDuration(beats: note.duration.rational.double)

        let pitch = midiPitch(for: note)

        sequence.tracks[0].add(noteNumber: Int(pitch), velocity: 100, position: akpos, duration: akdur)
        sequence.setTempo(Double(store.part.tempo))
        sequence.play()

        sequence.rewind()
    }

    private func midiPitch(for note: Note) -> Int {
        var chroma: Chroma
        switch note.letter {
        case .A:
            chroma = note.accidental == .sharp ? .as : .a
        case .B:
            chroma = .b
        case .C:
            chroma = note.accidental == .sharp ? .cs : .c
        case .D:
            chroma = note.accidental == .sharp ? .ds : .d
        case .E:
            chroma = .e
        case .F:
            chroma = note.accidental == .sharp ? .fs : .f
        case .G:
            chroma = note.accidental == .sharp ? .gs : .g
        }
        return Int(Pitch(chroma: chroma, octave: UInt(note.octave)).midi)
    }
}
