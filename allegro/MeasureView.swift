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
    var thickness: CGFloat = 0.0;
    var distanceApart: CGFloat = 0.0;
    
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
        
        for i in 0...NUM_BARS - 1 {
            let path = UIBezierPath(rect: CGRect(
                x: 0,
                y: 0 + CGFloat(i) * (thickness + distanceApart),
                width: rect.width,
                height: thickness
                )
            )
            
            UIColor.black.setFill()
            path.fill()
        }
    }
}
