//
//  MeasureView.swift
//  allegro
//
//  Created by Qingping He on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Foundation
import UIKit

class MeasureView: UIView {
    var thickness: CGFloat = 0.0
    var staffHeight: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // iOS expects draw(rect:) to completely fill
        // the view region with opaque content. This causes
        // the view background to be black unless we disable this.
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(_: rect)
        
        let staffDrawStart = (rect.height - staffHeight) / 2
        let staffLineOffset = (staffHeight - thickness) / CGFloat(NUM_BARS - 1)
        
        for i in 0..<NUM_BARS {
            let path = UIBezierPath(rect: CGRect(
                x: 0,
                y: staffDrawStart + CGFloat(i) * staffLineOffset,
                width: rect.width,
                height: thickness
                )
            )
            
            UIColor.black.setFill()
            path.fill()
        }
        
        func drawHalfNote(point: CGPoint) {
            let width = 100
            let height = 50
            let xDelta: CGFloat = 5
            let yDelta: CGFloat = 15

            let bounds = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
            let smaller = bounds.insetBy(dx: xDelta, dy: yDelta)

            let path = UIBezierPath(ovalIn: bounds)
            path.append(UIBezierPath(ovalIn: bounds.insetBy(dx: xDelta, dy: yDelta)))
            path.usesEvenOddFillRule = true
            
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: point.x, y: point.y)
            transform = transform.rotated(by: CGFloat(-30 * Double.pi / 180))
            
            path.apply(transform)
            
            UIColor.black.set()
            path.fill()
        }
        
        let notes = [Note(pitch: 0), Note(pitch: -3), Note(pitch: 3)]
        for (i, note) in notes.enumerated() {
            let x = CGFloat(100 * (i + 1))
            let y = staffDrawStart + staffHeight / 2 + staffLineOffset / 2 * CGFloat(note.pitch)
            
            drawHalfNote(point: CGPoint(x: x, y: y))
        }
    }
}
