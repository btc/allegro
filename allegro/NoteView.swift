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

class NoteView: MeasureActionView {
    // since everything was designed for iPhone 7, we stretch/squash the note
    // to fit other screen sizes
    // The default note size is (70, 55.16665)
    var staffHeight = CGFloat(0)
    
    fileprivate let defaultNoteWidth = CGFloat(70)
    fileprivate let defaultNoteHeight = CGFloat(55.16665)
    
    var scale: CGFloat {
        return staffHeight / defaultNoteHeight
    }
    
    // The NoteView draws the note as two separate UIBezierPaths.
    // One for the note head and one for the stem
    
    // For drawing whole/half notes, we draw it as two ovals, an outer one
    // and an inner one that cuts out the white inner region.
    // This offset describes the offset to shrink the outer rectangle
    // into the inner rectangle
    fileprivate var noteInset: CGPoint {
        return CGPoint(x: 3 * scale, y: 3 * scale)
    }
    
    // thickness in the x direction of the stem
    var stemThickness: CGFloat {
        return 3 * scale
    }
    
    // since the note head is a rotated oval that is shrunk to fit the frame,
    // the start point of the stem is inside the frame of the noe
    // is not the bounds of the frame but inside
    var stemOffset: CGPoint {
        return CGPoint(x: -5 * scale, y: 24 * scale)
    }
    
    // Note heads are rotated ovals
    // This describes the rotation of the oval.
    // Whole notes should not be rotated
    // radians only!
    fileprivate let rotationAngle = CGFloat(-10 * Double.pi / 180.0)
    
    // frame of the note head in the parent coordinate frame
    var noteOrigin = CGPoint.zero

    var noteFrame: CGRect {
        return CGRect(
            origin: noteOrigin,
            size: CGSize(width: defaultNoteWidth * scale, height: defaultNoteHeight * scale)
        )
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
    
    // Since the flag points down, we need to decrease the stem height
    // to prevent the stem from poking above the flag
    var flagOffset = CGFloat(5)
    
    // Since the note is rotated slightly, we need to add an offset
    // to the flag start to position it at the right point
    var flagStartOffset: CGFloat {
        return CGFloat(-1.5 * scale)
    }
    var _flagEndOffset = CGPoint(x: 40, y: 70)
    var flagEndOffset: CGPoint {
        return CGPoint(x: _flagEndOffset.x * scale, y: _flagEndOffset.y * scale)
    }
    
    fileprivate let flagLayer: CAShapeLayer
    var shouldDrawFlag: Bool {
        set(newShouldDraw) {
            flagLayer.isHidden = shouldDrawFlag
        }
        
        get {
            return flagLayer.isHidden
        }
    }

    fileprivate var flagThickness = CGFloat(10)
    fileprivate var flagIterOffset = CGFloat(10)
    
    var flagStart: CGPoint {
        if (flipped) {
            return CGPoint(
                x: -stemOffset.x - flagStartOffset - stemThickness,
                y: frame.size.height)
        }
        
        return CGPoint(
            x: noteFrame.size.width + stemOffset.x + flagStartOffset,
            y: 0)
    }
    
    
    var flipped: Bool {
        return stemEndY > noteFrame.origin.y + noteFrame.size.height
    }
    
    // This is the note head frame in the NoteView coordinate frame.
    // We need this to draw the note head inside the rectangle
    // that contains the note head and stem
    fileprivate var noteHeadFrame = CGRect.zero {
        didSet {
            measureActionFrame = noteHeadFrame
        }
    }

    let note: NoteViewModel

    init(note: NoteViewModel) {
        self.note = note
        flagLayer = CAShapeLayer()
        super.init(frame: .zero)
        // makes it transparent so we see the lines behind
        isOpaque = false
        layer.addSublayer(flagLayer)
        
        let tweaksToWatch = [Tweaks.flagIterOffset, Tweaks.flagOffset, Tweaks.flagThickness, Tweaks.flagEndOffsetX, Tweaks.flagEndOffsetY]
        Tweaks.bindMultiple(tweaksToWatch) {
            self.flagIterOffset = Tweaks.assign(Tweaks.flagIterOffset)
            self.flagOffset = Tweaks.assign(Tweaks.flagOffset)
            self.flagThickness = Tweaks.assign(Tweaks.flagThickness)
            self._flagEndOffset = CGPoint(
                x: Tweaks.assign(Tweaks.flagEndOffsetX),
                y: Tweaks.assign(Tweaks.flagEndOffsetY)
            )
            
            self.setNeedsLayout()
            self.updateNoteFrame()
        }
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
        if (note.value == Note.Value.whole) {
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
        
        if (note.value.nominalDuration < Note.Value.quarter.nominalDuration
            && shouldDrawFlag) {
            flagLayer.path = getFlagPath().cgPath
            flagLayer.fillColor = UIColor.black.cgColor
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
        
        if (note.value == Note.Value.whole ||
            note.value == Note.Value.half) {
            path.append(UIBezierPath(ovalIn: rect.insetBy(dx: noteInset.x, dy: noteInset.y)))
            // This makes sure the cutout is a different color based on the winding
            path.usesEvenOddFillRule = true
        }
        
        // Rotates the note head.
        // We need to translate it by the center point
        // since the rotation is around the origin 
        // yet the center point is not.
        if (note.value != Note.Value.whole) {
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
        
        var stemEndOffset = CGFloat(0)
        if (note.value.nominalDuration < Note.Value.quarter.nominalDuration) {
            stemEndOffset = flagOffset
        }
        
        // Since the note head is an oval, we need to add an offset to
        // ensure a smooth merge between the head and stem. 
        // this is the bottom left corner of the final stem rectangle
        var stemStart = CGPoint(x: upStart.x + stemOffset.x, y: upStart.y + stemOffset.y)
        var stemOrigin = CGPoint(x: stemStart.x,
                                 y: drawRect.origin.y + stemEndOffset)
        
        var stemSize = CGSize(width: stemThickness, height: stemStart.y)

        
        // flipped means we go the bottom left
        if (flipped) {
            let downStart = CGPoint(x: bounds.origin.x, y: bounds.origin.y + bounds.size.height)
            stemStart = CGPoint(x: downStart.x - stemOffset.x, y: downStart.y - stemOffset.y)
            stemOrigin = CGPoint(x: stemStart.x - stemThickness, y: stemStart.y)
            stemSize = CGSize(width: stemThickness, height: drawRect.size.height - stemOrigin.y - stemEndOffset)
        }
        
        let stemRect = CGRect(
            origin: stemOrigin,
            size: stemSize)
        return UIBezierPath(rect: stemRect)
    }
    
    func getFlagPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        var start = flagStart
        var sign = flipped ? CGFloat(-1) : CGFloat(1)
        
        func drawSingleFlag(path: UIBezierPath, start: CGPoint) {
            var point = start
            path.move(to: point)
            point = CGPoint(
                x: point.x + flagEndOffset.x,
                y: point.y + sign * flagEndOffset.y)
            path.addLine(to: point)
            point = CGPoint(
                x: point.x,
                y: point.y + sign * flagThickness)
            path.addLine(to: point)
            point = CGPoint(
                x: point.x - flagEndOffset.x,
                y: point.y - sign * flagEndOffset.y)
            path.addLine(to: point)
            path.close()
        }
        
        var iterDuration = Note.Value.eighth.nominalDuration
        while (true) {
            if note.value.nominalDuration > iterDuration {
                break
            }
            
            drawSingleFlag(path: path, start: start)
            
            start = CGPoint(x: start.x, y: start.y + sign * flagIterOffset)
            iterDuration = iterDuration / 2
        }
        
        return path
    }

    override func draw(_ rect: CGRect) {
        super.draw(_: rect)
        
        UIColor.black.set()
        
        let notePath = getNoteHeadPath(drawRect: rect)
        notePath.fill()
        
        if (note.value != Note.Value.whole) {
            let stemPath = getStemPath(notePath: notePath, drawRect: rect)
            stemPath.fill()
        }
    }
}
