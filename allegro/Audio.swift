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

protocol AudioObserver: class {
    func audioPlaybackChanged(playing: Bool)
    func audioPositionChanged(measure: Int, position: Rational)
}

extension AudioObserver {
    func audioPlaybackChanged(playing: Bool) {
        // default impl
    }
    func audioPositionChanged(measure: Int, position: Rational) {
        // default impl
    }
}

private class Weak {
    private(set) weak var value: AudioObserver?
    
    init(_ value: AudioObserver?) {
        self.value = value
    }
}

fileprivate struct TrackElem {
    var measureIndex: Int
    var measurePosition: Rational // may be freepace or note
    
    var midiPitch: UInt8? // if nil don't play anything
    var waitTime: TimeInterval // seconds
}

// Takes the Part and builds a MIDI track just like a sequencer
// Each TrackElem is played according to the timing using the sampler
class Audio {

    // minimum step with 1/64 notes (leftover from double-dotted 1/16 note)
    private static let minimumDuration: Rational = 1/64

    var isPlaying: Bool = false {
        didSet {
            if !isPlaying {
                currentMeasure = nil
                currentPosition = nil
            }
            notifyPlaybackChanged()
        }
    }

    private var currentMeasure: Int? {
        didSet {
            notifyPositionChanged()
        }
    }
    private var currentPosition: Rational? {
        didSet {
            notifyPositionChanged()
        }
    }

    private let sampler: AKMIDISampler = AKMIDISampler()
    private let mixer: AKMixer
    private var observers: [Weak] = [Weak]()

    init() {
        self.sampler.name = "piano"

        self.mixer = AKMixer(sampler)
        mixer.volume = 1.0
        
        // TODO audio engineering to make it sound better
        AudioKit.output = mixer
        
        // load the sample
//        guard let _ = try? self.sampler.loadWav("FM Piano") else {
//            Log.error?.message("Unable to load FM Piano.wav from bundle")
//            return
//        }

//        guard let _ = try? self.sampler.loadWav("Bell") else {
//            Log.error?.message("Unable to load Bell.wav from bundle")
//            return
//        }

        guard let _ = try? self.sampler.loadEXS24("sawPiano1") else {
            Log.error?.message("Unable to load sawPiano1.exs from bundle")
            return
        }
    }

    func start() {
        AudioKit.start()
    }
    
    func subscribe(_ observer: AudioObserver) {
        observers.append(Weak(observer))
    }
    
    func unsubscribe(_ observer: AudioObserver) {
        observers = observers.filter { observer in
            guard let value = observer.value else { return false } // prune released objects
            return value !== observer
        }
    }
    
    // general notification must always be sent to observers
    private func notifyPlaybackChanged() {
        // prunes released objects as it iterates
        observers = observers.filter { observer in
            guard let value = observer.value else { return false }
            value.audioPlaybackChanged(playing: self.isPlaying)
            return true
        }
    }

    private func notifyPositionChanged() {
        observers = observers.filter { observer in
            guard let value = observer.value else { return false }
            guard let measure = self.currentMeasure else { return true }
            guard let position = self.currentPosition else { return true }
            value.audioPositionChanged(measure: measure, position: position)
            return true
        }
    }

    // convert duration into the amount to time we have to wait
    // eg.
    // 1/4 note in 4/4 time -> 1/4 * 4 -> 1 beat
    // 120 bpm / 60 = 2 beats per second -> 0.5 seconds per beat
    func calcWaitTime(duration: Rational, tempo: Double, beat: Int) -> TimeInterval {
        return (duration * Rational(beat)).double / (tempo / 60)
    }

    // play just this note
    private func playPitch(pitch: UInt8) {
        // TODO investigate channels
        sampler.play(noteNumber: MIDINoteNumber(pitch), velocity: 100, channel: 0)
    }

    private func stopPitch(pitch: UInt8?) {
        if let pitch = pitch {
            sampler.stop(noteNumber: MIDINoteNumber(pitch), channel: 0)
        }
    }

    // loop and play each note
    // tempo is in beats per minute
    // beat the note that gets the beat (denominator of time signature)
    private func play(track: [TrackElem], tempo: Double, beat: Int) {

        self.isPlaying = true

        var trackElemIterator = track.makeIterator()

        var currStartTime = Date.distantPast // time that curr note was played
        var currWait: TimeInterval = 0 // time to wait until next note

        var lastPitch: UInt8?

        let step = calcWaitTime(duration: Audio.minimumDuration, tempo: tempo, beat: beat)
        Timer.every(step.seconds) { (timer: Timer) -> Void in

            if !self.isPlaying {
                Log.info?.message("Audio playback interrupted, stopping timer")
                timer.invalidate()
                self.stopPitch(pitch: lastPitch)
                return
            }

            if (Date().timeIntervalSince(currStartTime) >= currWait) {

                // pop next track elem
                guard let trackElem = trackElemIterator.next() else {
                    Log.info?.message("Audio playback done, stopping timer")
                    timer.invalidate()
                    self.isPlaying = false
                    self.stopPitch(pitch: lastPitch)
                    return
                }

                // stop last note
                self.stopPitch(pitch: lastPitch)

                // update state
                self.currentMeasure = trackElem.measureIndex
                self.currentPosition = trackElem.measurePosition

                if let midiPitch = trackElem.midiPitch {
                    // play unless nil (for rests and freespace)
                    self.playPitch(pitch: midiPitch)

                    // save this pitch so we can stop it
                    lastPitch = midiPitch
                }

                currStartTime = Date()
                currWait = trackElem.waitTime
            }
        }
    }

    // load all notes and freespaces into the track
    private func build(part: Part, startMeasureIndex: Int, tempo: Double, beat: Int) -> [TrackElem] {
        var track = [TrackElem]()

        let endMeasure = findEndMeasure(part: part)
        for index in stride(from: startMeasureIndex, to: endMeasure, by: 1) {
            let m = part.measures[index]

            var currPos: Rational = 0
            while currPos < m.timeSignature {

                var duration: Rational = 0
                var midiPitch: UInt8?

                if let note = m.note(at: currPos) {
                    duration = note.duration
                    if !note.rest {
                        midiPitch = note.midiPitch
                    }

                } else if let freePos = m.freespace(at: currPos) {
                    duration = freePos.duration

                } else {
                    Log.error?.message("building audio track: current position is neither a note nor free!")
                }

                // convert duration into the amount to time we have to wait
                let waitTime = calcWaitTime(duration: duration, tempo: tempo, beat: beat)

                // add this note to the track without pitch so we don't play it
                track.append(TrackElem(measureIndex: index,
                                       measurePosition: currPos,
                                       midiPitch: midiPitch, // nil for rest or freespace
                    waitTime: waitTime))

                currPos = currPos + duration
            }
        }
        return track
    }

    // find the last non-empty measure
    private func findEndMeasure(part: Part) -> Int {
        var endMeasure = part.measures.count - 1
        for index in stride(from: part.measures.count - 1, through: 0, by: -1) {
            if part.measures[index].notes.count > 0 {
                return endMeasure
            } else {
                endMeasure = index
            }
        }
        return endMeasure
    }

    // play a single note
    func playNote(part: Part, measure: Int, position: Rational) {
        if let note = part.measures[measure].note(at: position) {
            let tempo = Double(part.tempo)
            let beat = part.timeSignature.denominator

            // use 1/16 duration for this demo note
            let waitTime = calcWaitTime(duration: Note.Value.sixteenth.nominalDuration, tempo: tempo, beat: beat)
            let trackElem = TrackElem(measureIndex: measure, measurePosition: position, midiPitch: note.midiPitch, waitTime: waitTime)
            play(track: [trackElem], tempo: tempo, beat: beat)
        }
    }

    // build the track and play from the current measure
    // the block is called on current measure and current note position
    func playFromCurrentMeasure(part: Part, measure: Int) {
        let tempo = Double(part.tempo)
        let beat = part.timeSignature.denominator
        let track = build(part: part, startMeasureIndex: measure, tempo: tempo, beat: beat)
        play(track: track, tempo: tempo, beat: beat)
    }

}

fileprivate extension Note {
    var midiPitch: UInt8 {
        var chroma: Chroma = .c
        var octave = self.octave
        switch self.accidental {
        case .sharp:
            switch self.letter {
            case .A:
                chroma = .as
            case .B:
                chroma = .c
                octave = self.octave + 1
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
            switch self.letter {
            case .A:
                chroma = .gs
            case .B:
                chroma = .as
            case .C:
                chroma = .b
                octave = self.octave - 1
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
            switch self.letter {
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
