//
//  NoteView.swift
//  allegro
//
//  Created by Qingping He on 1/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Foundation
import UIKit

class NoteView: UIView {
    fileprivate let noteInset = CGPoint(x: 5, y: 15)
    
    fileprivate let stemThickness: CGFloat = 3.5
    fileprivate let stemOffset = CGPoint(x: -7, y: 15)
    
    //radians only!
    fileprivate let rotationAngle = CGFloat(-30 * Double.pi / 180.0)
    
    var noteFrame = CGRect.zero {
        didSet {
            updateNoteFrame()
        }
    }
    var stemEndY = CGFloat(0) {
        didSet {
            updateNoteFrame()
        }
    }
    fileprivate var noteHeadFrame = CGRect.zero
    
    let note: NoteViewModel

    init(note: NoteViewModel) {
        self.note = note
        super.init(frame: .zero)
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateNoteFrame() {
        let offset = noteFrame.origin.y - stemEndY
        frame = CGRect(
            x: noteFrame.origin.x,
            y: stemEndY,
            width: noteFrame.size.width,
            height: noteFrame.size.height + offset)
        noteHeadFrame = CGRect(origin: CGPoint(x: 0, y: offset), size: noteFrame.size)
    }
    
    func getNoteHeadPath(drawRect: CGRect) -> UIBezierPath {
        let rect = noteHeadFrame.offsetBy(dx: drawRect.origin.x, dy: drawRect.origin.y)
        
        let center = CGPoint(
            x: rect.origin.x + rect.size.width / 2,
            y: rect.origin.y + rect.size.height / 2
        )
        
        let path = UIBezierPath(ovalIn: rect)
        path.append(UIBezierPath(ovalIn: rect.insetBy(dx: noteInset.x, dy: noteInset.y)))
        path.usesEvenOddFillRule = true
        
        let rotation = CGAffineTransform.identity
            .translatedBy(x: center.x, y: center.y)
            .rotated(by: rotationAngle)
            .translatedBy(x: -center.x, y: -center.y)
        path.apply(rotation)
        
        
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
        let bounds = notePath.cgPath.boundingBox
        let upStart = CGPoint(x: bounds.origin.x + bounds.size.width,
                                  y: bounds.origin.y)
        let stemStart = CGPoint(x: upStart.x + stemOffset.x, y: upStart.y + stemOffset.y)
        
        let stemOrigin = CGPoint(x: stemStart.x,
                                 y: drawRect.origin.y)
        let stemSize = CGSize(width: stemThickness, height: stemStart.y)
        
        let stemRect = CGRect(
            origin: stemOrigin,
            size: stemSize)
        return UIBezierPath(rect: stemRect)
    }

    override func draw(_ rect: CGRect) {
        super.draw(_: rect)
        
        let notePath = getNoteHeadPath(drawRect: rect)
        let stemPath = getStemPath(notePath: notePath, drawRect: rect)

        UIColor.black.set()
        notePath.fill()
        stemPath.fill()
    }
}
