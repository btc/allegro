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

class NoteView: NoteActionView {
    
    // ALL THE STUFF THAT GETS TOUCHED BY THE OUTSIDE WORLD
    // origin of the note head in the parent coordinate frame
    var noteOrigin = CGPoint.zero {
        didSet {
            frame = CGRect(
                origin: noteOrigin,
                size: CGSize(width: defaultNoteWidth * scale, height: defaultNoteHeight * scale)
            )
        }
    }
    
    // thickness in the x direction of the stem
    // this is use to get the other side of the stem in the x direction to make sure
    // beams end in on the right side of the stem
    var stemThickness: CGFloat {
        return 3 * scale
    }
    
    // It should be in the coordinate frame of the parent.
    var stemEndY: CGFloat? = nil
    
    
    var flagStart: CGPoint {
        var start = CGPoint(
            x: frame.size.width + stemOffset.x + flagStartOffset,
            y: stemEndingY - frame.origin.y)
        
        if (note.flipped) {
            start = CGPoint(
                x: -stemOffset.x - flagStartOffset - stemThickness,
                y: stemEndingY - frame.origin.y)
        }
        
        return start
    }
    // END OUTSIDE WORLD STUFF
    
    // since everything was designed for iPhone 7, we stretch/squash the note
    // to fit other screen sizes
    // The default note size is (70, 55.16665)

    fileprivate let defaultNoteWidth = CGFloat(70)
    fileprivate let defaultNoteHeight = CGFloat(55.16665)
    
    fileprivate var scale: CGFloat {
        return geometry.staffHeight / defaultNoteHeight
    }
    
    fileprivate let defaultStemHeightScale = CGFloat(2)
    fileprivate var stemEndingY: CGFloat {
        if let stemEndY = stemEndY {
            return stemEndY
        }
        
        if (note.flipped) {
            return frame.origin.y + frame.size.height + geometry.staffHeight * defaultStemHeightScale
        }
        
        return frame.origin.y - geometry.staffHeight * defaultStemHeightScale
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
    
    // since the note head is a rotated oval that is shrunk to fit the frame,
    // the start point of the stem is inside the frame of the noe
    // is not the bounds of the frame but inside
    fileprivate var stemOffset: CGPoint {
        return CGPoint(x: -5 * scale, y: 24 * scale)
    }
    
    // Note heads are rotated ovals
    // This describes the rotation of the oval.
    // Whole notes should not be rotated
    // radians only!
    fileprivate let rotationAngle = CGFloat(-10 * Double.pi / 180.0)
    
    // Since the flag points down, we need to decrease the stem height
    // to prevent the stem from poking above the flag
    fileprivate var flagOffset = CGFloat(5)
    
    // Since the note is rotated slightly, we need to add an offset
    // to the flag start to position it at the right point
    fileprivate var flagStartOffset: CGFloat {
        return CGFloat(-1.5 * scale)
    }
    fileprivate var _flagEndOffset = CGPoint(x: 40, y: 70)
    fileprivate var flagEndOffset: CGPoint {
        return CGPoint(x: _flagEndOffset.x * scale, y: _flagEndOffset.y * scale)
    }

    var shouldDrawFlag = false
    fileprivate var flagThickness = CGFloat(10)
    fileprivate var flagIterOffset = CGFloat(15)
    
    let stemLayer: CAShapeLayer = CAShapeLayer() // TODO(btc): rename to stemLayer
    
    var accidentalLabel: UILabel? {
        guard note.displayAccidental else { return nil }
        
        let label = UILabel()
        label.frame = geometry.getAccidentalFrame(note: note)
        label.text = geometry.getAccidentalSymbol(accidental: note.note.accidental)
        label.font = UIFont(name: "DejaVu Sans", size: 200)
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .right
        return label
    }
    
    // all subviews were removed in the super call
    // i feel like that is kinda bad actually but w/e
    override var note: NoteViewModel {
        didSet {
            if stemLayer.superlayer == nil {
                layer.addSublayer(stemLayer)
            }
        
            if let a = accidentalLabel {
                addSubview(a)
            }
            
            computePaths()
        }
    }

    override init(note: NoteViewModel, geometry: NoteGeometry, store: PartStore) {
        super.init(note: note, geometry: geometry, store: store)
        // makes it transparent so we see the lines behind
        isOpaque = false

        layer.addSublayer(stemLayer)
        
        if let a = accidentalLabel {
            addSubview(a)

        let tweaksToWatch = [Tweaks.flagIterOffset, Tweaks.flagOffset, Tweaks.flagThickness, Tweaks.flagEndOffsetX, Tweaks.flagEndOffsetY]
        Tweaks.bindMultiple(tweaksToWatch) { [weak self] in
            guard let `self` = self else { return }
            self.flagIterOffset = Tweaks.assign(Tweaks.flagIterOffset)
            self.flagOffset = Tweaks.assign(Tweaks.flagOffset)
            self.flagThickness = Tweaks.assign(Tweaks.flagThickness)
            self._flagEndOffset = CGPoint(
                x: Tweaks.assign(Tweaks.flagEndOffsetX),
                y: Tweaks.assign(Tweaks.flagEndOffsetY)
            )
            
            self.setNeedsLayout()
            
            // tweaks calls this on initialization
            // but the frame is sized to zero with causes all sorts of weird NaN errors
            // so we have to skip
            if self.frame.size != .zero {
                self.computePaths()
            }
>>>>>>> we can now change the noteviewmodel
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // drawRect is the rectangle we are drawing inside.
    // It should be correctly sized.
    func getNoteHeadPath(rect: CGRect) -> UIBezierPath {
        let center = CGPoint(
            x: rect.origin.x + rect.size.width / 2,
            y: rect.origin.y + rect.size.height / 2
        )
        
        // First we draw an oval and then cut out the oval inside.
        let path = UIBezierPath(ovalIn: rect)
        
        if (note.note.value == Note.Value.whole ||
            note.note.value == Note.Value.half) {
            path.append(UIBezierPath(ovalIn: rect.insetBy(dx: noteInset.x, dy: noteInset.y)))
            // This makes sure the cutout is a different color based on the winding
            path.usesEvenOddFillRule = true
        }
        
        // Rotates the note head.
        // We need to translate it by the center point
        // since the rotation is around the origin 
        // yet the center point is not.
        if (note.note.value != Note.Value.whole) {
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
    
    func getStemPath(notePath: UIBezierPath) -> UIBezierPath {
        // The stem path is a just a rectangle, but we need to make sure it 
        // connects smoothly with the note head
        let noteBounds = notePath.cgPath.boundingBox
        
        // We start with the top right corner of the bounding box for the note
        // head path
        let upStart = CGPoint(x: noteBounds.origin.x + noteBounds.size.width,
                                  y: noteBounds.origin.y)
        
        var stemEndOffset = CGFloat(0)
        if (note.note.value.nominalDuration < Note.Value.quarter.nominalDuration) {
            stemEndOffset = flagOffset
        }
        
        let stemEnd = stemEndingY - frame.origin.y
        
        // Since the note head is an oval, we need to add an offset to
        // ensure a smooth merge between the head and stem. 
        // this is the bottom left corner of the final stem rectangle
        var stemStart = CGPoint(x: upStart.x + stemOffset.x, y: upStart.y + stemOffset.y)
        var stemOrigin = CGPoint(x: stemStart.x,
                                 y: stemEnd + stemEndOffset)
        
        var stemSize = CGSize(width: stemThickness, height: stemStart.y - stemOrigin.y)

        
        // flipped means we go the bottom left
        if (note.flipped) {
            let downStart = CGPoint(x: noteBounds.origin.x, y: noteBounds.origin.y + noteBounds.size.height)
            stemStart = CGPoint(x: downStart.x - stemOffset.x, y: downStart.y - stemOffset.y)
            stemOrigin = CGPoint(x: stemStart.x - stemThickness, y: stemStart.y)
            stemSize = CGSize(width: stemThickness, height: stemEnd - stemOrigin.y - stemEndOffset)
        }
        
        let stemRect = CGRect(
            origin: stemOrigin,
            size: stemSize)
        return UIBezierPath(rect: stemRect)
    }
    
    func getFlagPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        var start = flagStart
        var sign = note.flipped ? CGFloat(-1) : CGFloat(1)
        
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
            if note.note.value.nominalDuration > iterDuration {
                break
            }
            
            drawSingleFlag(path: path, start: start)
            
            start = CGPoint(x: start.x, y: start.y + sign * flagIterOffset)
            iterDuration = iterDuration / 2
        }
        
        if (note.flipped) {
            // not reversing the path causes the union to be incorrect
            // when combining paths. It has something to do with winding order
            return path.reversing()
        }
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        let notePath = getNoteHeadPath(rect: bounds)
        color.set()
        notePath.fill()
    }
    
    func computePaths() {
        let path = UIBezierPath()
        let notePath = getNoteHeadPath(rect: bounds)

        if (note.note.value.nominalDuration < Note.Value.whole.nominalDuration) {
            path.append(getStemPath(notePath: notePath))
        }
        
        if (note.note.value.nominalDuration < Note.Value.quarter.nominalDuration
            && shouldDrawFlag) {
            path.append(getFlagPath())
        }
        
        stemLayer.path = path.cgPath
        stemLayer.fillColor = color.cgColor
    }
}
