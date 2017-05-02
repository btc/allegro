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

        // TODO better step size
        Timer.every(0.05.seconds) { (timer: Timer) -> Void in
            
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
    }
    
    // convert duration into the amount to time we have to wait
    // eg.
    // 1/4 note in 4/4 time -> 1/4 * 4 -> 1 beat
    // 120 bpm / 60 = 2 beats per second -> 0.5 seconds per beat
    func calcWaitTime(duration: Rational, tempo: Double, beat: Int) -> TimeInterval {
        return (duration * Rational(beat)).double / (tempo / 60)
    }
    
    // load all notes into the track
    func build(part: Part, beat: Int, startMeasureIndex: Int) {
        
        let tempo = Double(part.tempo)
        
        if !track.isEmpty {
            track = [] // replace it with a new one
        }
        
        let endMeasure = findEndMeasure(part: part)
        for index in stride(from: startMeasureIndex, to: endMeasure, by: 1) {
            let m = part.measures[index]
            
            var currPos: Rational = 0
            var currTime: TimeInterval = 0
            while currPos < m.timeSignature {
                
                if let note = m.note(at: currPos) {
                    
                    // convert duration into the amount to time we have to wait
                    let waitTime = calcWaitTime(duration: note.duration, tempo: tempo, beat: beat)
                    
                    if note.rest {
                        // add this note without a pitch
                        track.append(TrackElem(measureIndex: index,
                                               measurePosition: currPos,
                                               midiPitch: nil,
                                               waitTime: waitTime))
                    } else {
                        // add this note to the track
                        track.append(TrackElem(measureIndex: index,
                                               measurePosition: currPos,
                                               midiPitch: note.midiPitch,
                                               waitTime: waitTime))
                    }
                    
                    currTime += waitTime
                    currPos = currPos + note.duration
                    
                } else if let freePos = m.freespace(at: currPos) {
                    
                    // convert duration into the amount to time we have to wait
                    let waitTime = calcWaitTime(duration: freePos.duration, tempo: tempo, beat: beat)
                    
                    // add this note to the track without pitch so we don't play it
                    track.append(TrackElem(measureIndex: index,
                                           measurePosition: currPos,
                                           midiPitch: nil,
                                           waitTime: waitTime))
                    
                    currTime += waitTime
                    currPos = currPos + freePos.duration
                    
                } else {
                    Log.error?.message("building track: current position is neither a note nor free!")
                }
            }
        }
    }
    
    // find the last non-empty measure
    private func findEndMeasure(part: Part) -> Int {
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
    
    func playFromCurrentMeasure(part: Part, beat: Int, measure: Int, block: @escaping (Int, Rational) -> Void) {
        sequencer.build(part: part, beat: beat, startMeasureIndex: measure)
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
