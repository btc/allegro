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

    let sequence = AKSequencer()

    init() {
        let oscillator = AKFMOscillatorBank()
        oscillator.modulatingMultiplier = 3
        oscillator.modulationIndex = 0.3
        let melody = AKMIDINode(node: oscillator)
        _ = sequence.newTrack()
        sequence.tracks[0].setMIDIOutput(melody.midiIn)
        AudioKit.output = melody
    }

    func start() {
        AudioKit.start()
    }

    func stop() {
        sequence.stop()
        AudioKit.stop()
    }

    func playMeasure(part: Part, measure: Int) {
        if !sequence.tracks[0].isEmpty {
            sequence.tracks[0].clear()
        }
        let numMeasures = part.measures.count - measure
        let sequenceLength = AKDuration(beats: Double(part.measures[0].timeSignature.numerator * numMeasures), tempo: Double(part.tempo))
        sequence.setLength(sequenceLength)
        var curBeat = 0
        
        for index in stride(from: measure, through: part.measures.count - 1, by: 1) {
            let m = part.measures[index]
            for notePos in m.notes {
                guard let note = m.note(at: notePos.pos) else { return }
                let akpos = AKDuration(beats: Double(curBeat))
                let akdur = AKDuration(beats: note.duration.double)
                let pitch = midiPitch(for: note)
                if !note.rest {
                    sequence.tracks[0].add(noteNumber: pitch, velocity: 100, position: akpos, duration: akdur)
                }
                curBeat += 1
            }
        }

        sequence.setTempo(Double(part.tempo))
        sequence.play()

        sequence.rewind()
    }

    func playNote(part: Part, measure: Int, position: Rational) {

        if !sequence.tracks[0].isEmpty {
            sequence.tracks[0].clear()
        }

        let m = part.measures[measure]

        let sequenceLength = AKDuration(beats: Double(m.timeSignature.numerator), tempo: Double(part.tempo))
        sequence.setLength(sequenceLength)

        guard let note = m.note(at: position) else { return }

        if note.rest { return } // don't play rests

        // let akpos = AKDuration(beats: Double(m.timeSignature.numerator) * position.double)
        let akpos = AKDuration(beats: 0)
        let akdur = AKDuration(beats: note.duration.double)

        let pitch = midiPitch(for: note)

        sequence.tracks[0].add(noteNumber: pitch, velocity: 100, position: akpos, duration: akdur)
        sequence.setTempo(Double(part.tempo))
        sequence.play()
        
        sequence.rewind()
    }
    
    fileprivate func midiPitch(for note: Note) -> UInt8 {
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

        return UInt8(Pitch(chroma: chroma, octave: UInt(note.octave)).midi)
    }
}
