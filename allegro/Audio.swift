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

// TODO make this into audioPlaybackChanged
protocol AudioObserver: class {
    func audioChanged()
}

extension AudioObserver {
    func audioChanged() {
        //default impl
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

// 1. Generates MIDI from notes
// 2. Calls the sampler to play those notes at the right time
fileprivate class Sequencer {
    
    var sampler: AKSampler
    var stop: Bool
    
    var track: [TrackElem]

    var tempo: Double // beats per minute
    var beat: Int // the note that gets the beat (denominator of time signature)

    // play just this note
    func playPitch(pitch: UInt8) {
        // TODO investigate channels
        sampler.play(noteNumber: MIDINoteNumber(pitch), velocity: 100, channel: 0)
    }
    
    // loop and play each note
    func play(block: @escaping (Int, Rational) -> Void) {
        
        self.stop = false
        
        var trackElemIterator = track.makeIterator()
        
        var currStartTime = Date.distantPast // time that curr note was played
        var currWait: TimeInterval = 0 // time to wait until next note

        // minimum step with 1/64 notes (leftover from double-dotted 1/16 note)
        let step = calcWaitTime(duration: 1/64, tempo: self.tempo, beat: self.beat)
        Timer.every(step.seconds) { (timer: Timer) -> Void in
            
            if self.stop {
                Log.info?.message("Audio playback timer stopped")
                timer.invalidate()
                return
            }

            if (Date().timeIntervalSince(currStartTime) >= currWait) {

                // pop next track elem
                guard let trackElem = trackElemIterator.next() else {
                    Log.info?.message("Audio playback done, stopping timer")
                    timer.invalidate()
                    self.stop = true
                    return
                }
                
                // pass info back to calling function
                block(trackElem.measureIndex, trackElem.measurePosition)
                
                if let midiPitch = trackElem.midiPitch {
                    // play unless nil (for rests and freespace)
                    self.playPitch(pitch: midiPitch)
                }
                
                currStartTime = Date()
                currWait = trackElem.waitTime
            }
        }
    }
    
    init(sampler: AKSampler) {
        self.sampler = sampler
        stop = true
        track = []
        tempo = 120
        beat = 4
    }
    
    // convert duration into the amount to time we have to wait
    // eg.
    // 1/4 note in 4/4 time -> 1/4 * 4 -> 1 beat
    // 120 bpm / 60 = 2 beats per second -> 0.5 seconds per beat
    func calcWaitTime(duration: Rational, tempo: Double, beat: Int) -> TimeInterval {
        return (duration * Rational(beat)).double / (tempo / 60)
    }
    
    // load all notes and freespaces into the track
    func build(part: Part, startMeasureIndex: Int) {
        
        if !track.isEmpty {
            track = [] // replace it with a new one
        }
        
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
}

// Takes the Part and uses the sequencer to make MIDI
// Sampler is called by sequencer, which is mixed to make the output
class Audio {
    
    private let sampler: AKMIDISampler
    private let mixer: AKMixer
    private let sequencer: Sequencer
    private var observers: [Weak]

    init() {
        self.observers = [Weak]()
        
        self.sampler = AKMIDISampler()
        self.sampler.name = "piano"
        
        self.sequencer = Sequencer(sampler: self.sampler)
        
        self.mixer = AKMixer(sampler)
        mixer.volume = 1.0
        
        // TODO audio engineering to make it sound better
        AudioKit.output = mixer
        
        // load the sample
        guard let _ = try? self.sampler.loadWav("FM Piano") else {
            Log.error?.message("Unable to load wav")
            return
        }
    }

    func start() {
        AudioKit.start()
    }

    func stop() {
        sequencer.stop = true
        notify()
    }
    
    func isPlaying() -> Bool {
        return !sequencer.stop
    }
    
    func subscribe(_ observer: AudioObserver) {
        observers.append(Weak(observer))
        observer.audioChanged()
    }
    
    func unsubscribe(_ observer: AudioObserver) {
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
            value.audioChanged()
            return true
        }
    }
    
    func playFromCurrentMeasure(part: Part, measure: Int, block: @escaping (Int, Rational) -> Void) {
        sequencer.tempo = Double(part.tempo)
        sequencer.beat = part.timeSignature.denominator
        sequencer.build(part: part, startMeasureIndex: measure)
        sequencer.play(block: block)
    }
    

    func playNote(part: Part, measure: Int, position: Rational) {
        if let note = part.measures[measure].note(at: position) {
            sequencer.playPitch(pitch: note.midiPitch)
        }
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
