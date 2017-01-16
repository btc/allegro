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
    var lines: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for _ in 1...5 {
            let view = UIView()
            view.backgroundColor = UIColor.black
            lines.append(view)
            self.addSubview(view)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutLines(thickness: CGFloat, distanceApart: CGFloat) {
        for (index, view) in lines.enumerated() {
            view.frame = CGRect(
                x: 0,
                y: 0 + CGFloat(index) * (thickness + distanceApart),
                width: self.frame.width,
                height: thickness
            );
        }
    }
}
