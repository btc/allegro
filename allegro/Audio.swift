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
import SwiftyTimer

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

    func playFromCurrentMeasure(part: Part, measure: Int, block: @escaping (Int) -> Void) {
        if !sequence.tracks[0].isEmpty {
            sequence.tracks[0].clear()
        }
        let endMeasure = findEndMeasure(part: part)
        let numMeasures = part.measures.count - measure
        let sequenceLength = AKDuration(beats: Double(part.measures[0].timeSignature.numerator * numMeasures), tempo: Double(part.tempo))
        sequence.setLength(sequenceLength)
        var curPos = 0.0
        var curMeasure = 0
        
        for index in stride(from: measure, through: part.measures.count - 1, by: 1) {
            let m = part.measures[index]
            for notePos in m.notes {
                guard let note = m.note(at: notePos.pos) else { return }
                curPos = (curMeasure + notePos.pos.double) * m.timeSignature.numerator
                let akpos = AKDuration(beats: curPos)
                let akdur = AKDuration(beats: note.duration.double)
                let pitch = midiPitch(for: note)
                if !note.rest {
                    sequence.tracks[0].add(noteNumber: MIDINoteNumber(pitch), velocity: 100, position: akpos, duration: akdur)
                }
            }
            curMeasure += 1

        }

        sequence.setTempo(Double(part.tempo))
        sequence.play()

        sequence.rewind()
        
        /* 0.05 is an educated guess
            The Timer is called every 0.05 seconds and it checks to see where in the measure we are and changes the current measure accordingly. If we reach the end measure, we stop playing the sequence. 
         */
        Timer.every(0.05.seconds) { (timer: Timer) -> Void in
            let beatsPerMeasure = part.measures[0].timeSignature.numerator
            let currentMeasure = floor(self.sequence.currentRelativePosition.beats/beatsPerMeasure) + measure
            if currentMeasure >= Double(endMeasure) {
                self.sequence.stop()
            }
            guard self.sequence.isPlaying else {
                timer.invalidate()
                return
            }
            block(Int(currentMeasure))
        }
    }
    
    func findEndMeasure(part: Part) -> Int {
        var endMeasure = part.measures.count - 1
        for index in stride(from: part.measures.count - 1, through: 0, by: -1) {
            let noteCount = part.measures[index].notes.count
            if noteCount > 0 {
                return endMeasure
            }
            if noteCount == 0 {
                endMeasure = index
            }
        }
        return endMeasure
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

        sequence.tracks[0].add(noteNumber: MIDINoteNumber(pitch), velocity: 100, position: akpos, duration: akdur)
        sequence.setTempo(Double(part.tempo))
        sequence.play()
        
        sequence.rewind()
    }
    
    fileprivate func midiPitch(for note: Note) -> UInt8 {
        var chroma: Chroma = .c
        var octave = note.octave
        switch note.accidental {
        case .sharp:
            switch note.letter {
            case .A:
                chroma = .as
            case .B:
                chroma = .c
                octave = note.octave + 1
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

        return UInt8(Pitch(chroma: chroma, octave: UInt(octave)).midi)
    }
    
}
