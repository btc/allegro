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

        guard let note = m.note(at: position) else { return }

        // let akpos = AKDuration(beats: Double(m.timeSignature.numerator) * position.double)
        let akpos = AKDuration(beats: 0)
        let akdur = AKDuration(beats: note.duration.double)

        let pitch = midiPitch(for: note)

        sequence.tracks[0].add(noteNumber: Int(pitch), velocity: 100, position: akpos, duration: akdur)
        sequence.setTempo(Double(store.part.tempo))
        sequence.play()

        sequence.rewind()
    }
    
    func playMeasure(measure: Int) {
        sequence.tracks[0].clear()
        
        var curBeat = 0
        
        let m = store.part.measures[measure]
        let sequenceLength = AKDuration(beats: Double(m.timeSignature.numerator), tempo: Double(store.part.tempo))
        sequence.setLength(sequenceLength)
        
        for notePos in m.notes {
            guard let note = m.note(at: notePos.pos) else { return }
            let akpos = AKDuration(beats: Double(curBeat))
            let akdur = AKDuration(beats: note.duration.double)
            let pitch = midiPitch(for: note)
            if !note.rest {
                sequence.tracks[0].add(noteNumber: Int(pitch), velocity: 100, position: akpos, duration: akdur)
            }
            curBeat += 1
        }
        
        sequence.setTempo(Double(store.part.tempo))
        sequence.play()
        
        sequence.rewind()
    }

    private func midiPitch(for note: Note) -> Int {
        var chroma: Chroma = .c
        switch note.accidental {
        case .sharp:
            switch note.letter {
            case .A:
                chroma = .as
            case .B:
                chroma = .c
            case .C:
                chroma = .cs
            case .D:
                chroma = .ds
            case .E:
                chroma = .f
            case .F:
                chroma = .fs
            case .G:
                chroma = .gs
            }

        case .flat:
            switch note.letter {
            case .A:
                chroma = .gs
            case .B:
                chroma = .as
            case .C:
                chroma = .b
            case .D:
                chroma = .cs
            case .E:
                chroma = .ds
            case .F:
                chroma = .e
            case .G:
                chroma = .fs
            }

        case .natural:
            switch note.letter {
            case .A:
                chroma = .a
            case .B:
                chroma = .b
            case .C:
                chroma = .c
            case .D:
                chroma = .d
            case .E:
                chroma = .e
            case .F:
                chroma = .f
            case .G:
                chroma = .g
            }
        default: break // doubles
        }

        return Int(Pitch(chroma: chroma, octave: UInt(note.octave)).midi)
    }
}
