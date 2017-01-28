//
//  NoteView.swift
//  allegro
//
//  Created by Qingping He on 1/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Foundation
import UIKit
import Rational

class NoteView: UIView {
    // The NoteView draws the note as two separate UIBezierPaths.
    // One for the note head and one for the stem
    
    // For drawing whole/half notes, we draw it as two ovals, an outer one
    // and an inner one that cuts out the white inner region.
    // This offset describes the offset to shrink the outer rectangle
    // into the inner rectangle
    fileprivate let noteInset = CGPoint(x: 3, y: 3)
    
    // thickness in the x direction of the stem
    fileprivate let stemThickness: CGFloat = 3
    
    // since the note head is a rotated oval that is shrunk to fit the frame,
    // the start point of the stem is inside the frame of the noe
    // is not the bounds of the frame but inside
    fileprivate let stemOffset = CGPoint(x: -5, y: 24)
    
    // Note heads are rotated ovals
    // This describes the rotation of the oval.
    // Whole notes should not be rotated
    // radians only!
    fileprivate let rotationAngle = CGFloat(-10 * Double.pi / 180.0)
    
    // frame of the note head in the parent coordinate frame
    var noteFrame = CGRect.zero {
        didSet {
            updateNoteFrame()
        }
    }
    
    // The NoteView extends its own frame to accommodate the extra height of
    // the stem, which can be changed by the parent.
    // This constant describes the y position the NoteView extends itself to.
    // It should be in the coordinate frame of the parent.
    var stemEndY = CGFloat(0) {
        didSet {
            updateNoteFrame()
        }
    }
    
    // Since the flag points down, we
    let flagOffset = CGFloat(5)
    
    fileprivate var flagStartPoint: CGPoint {
        return CGPoint(
            x: noteFrame.origin.x + noteFrame.size.width + stemOffset.x,
            y: stemEndY
        )
    }
    
    fileprivate var flipped: Bool {
        return stemEndY > noteFrame.origin.y + noteFrame.size.height
    }
    
    // This is the note head frame in the NoteView coordinate frame.
    // We need this to draw the note head inside the rectangle
    // that contains the note head and stem
    fileprivate var noteHeadFrame = CGRect.zero
    
    let note: NoteViewModel

    init(note: NoteViewModel) {
        self.note = note
        super.init(frame: .zero)
        // makes it transparent so we see the lines behind
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Since both noteframe and stemEndY are needed to
    // compute the final frame size yet are set independently
    // this method makes sure the two generate a coherent frame
    func updateNoteFrame() {
        // don't extend the frame at all for whole notes since
        // they never have a stem
        if (note.duration == Note.Duration.whole) {
            frame = noteFrame
            noteHeadFrame = CGRect(origin: CGPoint.zero, size: noteFrame.size)
            return
        }
        
        var offset = noteFrame.origin.y - stemEndY
        if (flipped) {
            offset = stemEndY - noteFrame.origin.y - noteFrame.size.height
        }
        
        let frameSize = CGSize(width: noteFrame.size.width,
                               height: noteFrame.size.height + offset)
        
        if (!flipped) {
            frame = CGRect(
                origin: CGPoint(x: noteFrame.origin.x, y: stemEndY),
                size: frameSize)
            noteHeadFrame = CGRect(origin: CGPoint(x: 0, y: offset), size: noteFrame.size)
        } else {
            frame = CGRect (
                origin: noteFrame.origin,
                size: frameSize
            )
            noteHeadFrame = CGRect(origin: CGPoint.zero, size: noteFrame.size)
        }
    }
    
    // drawRect is the rectangle we are drawing inside.
    // It should be correctly sized.
    func getNoteHeadPath(drawRect: CGRect) -> UIBezierPath {
        let rect = noteHeadFrame.offsetBy(dx: drawRect.origin.x, dy: drawRect.origin.y)
        
        let center = CGPoint(
            x: rect.origin.x + rect.size.width / 2,
            y: rect.origin.y + rect.size.height / 2
        )
        
        // First we draw an oval and then cut out the oval inside.
        let path = UIBezierPath(ovalIn: rect)
        
        if (note.duration == Note.Duration.whole ||
            note.duration == Note.Duration.half) {
            path.append(UIBezierPath(ovalIn: rect.insetBy(dx: noteInset.x, dy: noteInset.y)))
            // This makes sure the cutout is a different color based on the winding
            path.usesEvenOddFillRule = true
        }
        
        // Rotates the note head.
        // We need to translate it by the center point
        // since the rotation is around the origin 
        // yet the center point is not.
        if (note.duration != Note.Duration.whole) {
            let rotation = CGAffineTransform.identity
                .translatedBy(x: center.x, y: center.y)
                .rotated(by: rotationAngle)
                .translatedBy(x: -center.x, y: -center.y)
            path.apply(rotation)
        }
        
        // After rotating the note head the note head can be outside the bounds of the
        // note frame. We shrink it to make sure the note head is always inside the
        // bounds of the original frame for the note head.
        let pathBounds = path.cgPath.boundingBox
        
        let sw     = rect.size.width / pathBounds.width
        let sh     = rect.size.height / pathBounds.height
        let factor = min(sw, sh)
        
        let scale = CGAffineTransform.identity
            .translatedBy(x: center.x, y: center.y)
            .scaledBy(x: factor, y: factor)
            .translatedBy(x: -center.x, y: -center.y)
        path.apply(scale)
        
        return path
    }
    
    func getStemPath(notePath: UIBezierPath, drawRect: CGRect) -> UIBezierPath {
        // The stem path is a just a rectangle, but we need to make sure it 
        // connects smoothly with the note head
        let bounds = notePath.cgPath.boundingBox
        
        // We start with the top right corner of the bounding box for the note
        // head path
        let upStart = CGPoint(x: bounds.origin.x + bounds.size.width,
                                  y: bounds.origin.y)
        
        // Since the note head is an oval, we need to add an offset to
        // ensure a smooth merge between the head and stem. 
        // this is the bottom left corner of the final stem rectangle
        var stemStart = CGPoint(x: upStart.x + stemOffset.x, y: upStart.y + stemOffset.y)
        var stemOrigin = CGPoint(x: stemStart.x,
                                 y: drawRect.origin.y)
        
        var stemSize = CGSize(width: stemThickness, height: stemStart.y)

        
        // flipped means we go the bottom left
        if (flipped) {
            let downStart = CGPoint(x: bounds.origin.x, y: bounds.origin.y + bounds.size.height)
            stemStart = CGPoint(x: downStart.x - stemOffset.x, y: downStart.y - stemOffset.y)
            stemOrigin = CGPoint(x: stemStart.x - stemThickness, y: stemStart.y)
            stemSize = CGSize(width: stemThickness, height: stemEndY - stemOrigin.y)
        }
        
        let stemRect = CGRect(
            origin: stemOrigin,
            size: stemSize)
        return UIBezierPath(rect: stemRect)
    }

    override func draw(_ rect: CGRect) {
        super.draw(_: rect)
        
        UIColor.black.set()
        
        let notePath = getNoteHeadPath(drawRect: rect)
        notePath.fill()
        
        if (note.duration != Note.Duration.whole) {
            let stemPath = getStemPath(notePath: notePath, drawRect: rect)
            stemPath.fill()
        }
    }
}
