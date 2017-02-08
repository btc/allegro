//
//  CGRect.swift
//  allegro
//
//  Created by Qingping He on 2/8/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

extension CGRect {
    func boundingBox(other: CGRect) -> CGRect {
        let topLeft = CGPoint(x: min(origin.x, other.origin.x), y: min(origin.y, other.origin.y))
        
        let bottom = max(origin.y + size.height, other.origin.y + other.size.height)
        let right = max(origin.x + size.width, other.origin.x + other.size.width)
        
        let sz = CGSize(width: right - topLeft.x, height: bottom - topLeft.y)
        
        return CGRect(origin: topLeft, size: sz)
    }
    
}
