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
    
    fileprivate let noteHeadFrame: CGRect
    
    // we're assuming the stem is always going up for now
    init(noteHeadFrame: CGRect, stemEndY: CGFloat) {
        let offset = noteHeadFrame.origin.y - stemEndY
        let noteFrame = CGRect(
            x: noteHeadFrame.origin.x,
            y: stemEndY,
            width: noteHeadFrame.size.width,
            height: noteHeadFrame.size.height + offset)
        self.noteHeadFrame = CGRect(origin: CGPoint(x: 0, y: offset), size: noteHeadFrame.size)
        
        super.init(frame: noteFrame)
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getNoteHeadPath(drawRect: CGRect) -> UIBezierPath {
        let frame = noteHeadFrame.offsetBy(dx: drawRect.origin.x, dy: drawRect.origin.y)
        
        let center = CGPoint(
            x: frame.origin.x + frame.size.width / 2,
            y: frame.origin.y + frame.size.height / 2
        )
        
        let path = UIBezierPath(ovalIn: frame)
        path.append(UIBezierPath(ovalIn: frame.insetBy(dx: noteInset.x, dy: noteInset.y)))
        path.usesEvenOddFillRule = true
        
        let rotation = CGAffineTransform.identity
            .translatedBy(x: center.x, y: center.y)
            .rotated(by: rotationAngle)
            .translatedBy(x: -center.x, y: -center.y)
        path.apply(rotation)
        
        
        let pathBounds = path.cgPath.boundingBox
        
        let sw     = frame.size.width / pathBounds.width
        let sh     = frame.size.height / pathBounds.height
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
