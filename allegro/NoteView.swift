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
    let xDelta: CGFloat = 5
    let yDelta: CGFloat = 15

    let note: NoteViewModel

    init(note: NoteViewModel) {
        self.note = note
        super.init(frame: .zero)
        //self.layer.masksToBounds = false
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(_: rect)
        
        let center = CGPoint(
            x: rect.origin.x + rect.size.width / 2,
            y: rect.origin.y + rect.size.height / 2
        )
        
        let path = UIBezierPath(ovalIn: rect)
        path.append(UIBezierPath(ovalIn: rect.insetBy(dx: xDelta, dy: yDelta)))
        path.usesEvenOddFillRule = true
        
        let rotation = CGAffineTransform.identity
            .translatedBy(x: center.x, y: center.y)
            .rotated(by: CGFloat(-30 * Double.pi / 180))
            .translatedBy(x: -center.x, y: -center.y)
        path.apply(rotation)
        
        
        let bounds = path.cgPath.boundingBox
        
        let sw     = rect.size.width / bounds.width
        let sh     = rect.size.height / bounds.height
        let factor = min(sw, sh)
        
        let scale = CGAffineTransform.identity
            .translatedBy(x: center.x, y: center.y)
            .scaledBy(x: factor, y: factor)
            .translatedBy(x: -center.x, y: -center.y)
        path.apply(scale)
        
        UIColor.black.set()
        path.fill()
    }
}
