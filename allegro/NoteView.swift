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

    override func draw(_ rect: CGRect) {
        super.draw(_: rect)
        
        let noteFrame = noteHeadFrame.offsetBy(dx: rect.origin.x, dy: rect.origin.y)
        
        let center = CGPoint(
            x: noteFrame.origin.x + noteFrame.size.width / 2,
            y: noteFrame.origin.y + noteFrame.size.height / 2
        )
        
        let notePath = UIBezierPath(ovalIn: noteFrame)
        notePath.append(UIBezierPath(ovalIn: noteFrame.insetBy(dx: noteInset.x, dy: noteInset.y)))
        notePath.usesEvenOddFillRule = true
        
        let rotation = CGAffineTransform.identity
            .translatedBy(x: center.x, y: center.y)
            .rotated(by: rotationAngle)
            .translatedBy(x: -center.x, y: -center.y)
        notePath.apply(rotation)
        
        
        let pathBounds = notePath.cgPath.boundingBox
        
        let sw     = noteFrame.size.width / pathBounds.width
        let sh     = noteFrame.size.height / pathBounds.height
        let factor = min(sw, sh)
        
        let scale = CGAffineTransform.identity
            .translatedBy(x: center.x, y: center.y)
            .scaledBy(x: factor, y: factor)
            .translatedBy(x: -center.x, y: -center.y)
        notePath.apply(scale)
        
        let rotatedBounds = notePath.cgPath.boundingBox
        let stemUpStart = CGPoint(x: rotatedBounds.origin.x + rotatedBounds.size.width,
                                  y: rotatedBounds.origin.y)
        let stemUpOffsetStart = CGPoint(x: stemUpStart.x + stemOffset.x, y: stemUpStart.y + stemOffset.y)
        
        let stemOrigin = CGPoint(x: stemUpOffsetStart.x,
                                   y: rect.origin.y)
        let stemSize = CGSize(width: stemThickness, height: stemUpOffsetStart.y)
        
        let stemRect = CGRect(
            origin: stemOrigin,
            size: stemSize)
        let stemPath = UIBezierPath(rect: stemRect)

        UIColor.black.set()
        notePath.fill()
        stemPath.fill()
    }
}
