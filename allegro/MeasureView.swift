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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let bars = UIBezierPath()
        
        for i in 0...NUM_BARS - 1 {
            let path = UIBezierPath(rect: CGRect(
                x: 0,
                y: 0 + CGFloat(i) * (thickness + distanceApart),
                width: self.frame.width,
                height: thickness
                )
            )
            
            UIColor.black.setFill()
            path.fill()
            
            bars.append(path)
        }
        
        bars.close()
        
        let barLayer = CAShapeLayer()
        barLayer.path = bars.cgPath
        self.layer.addSublayer(barLayer)
    }
}
