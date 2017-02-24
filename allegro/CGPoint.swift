//
//  CGPoint.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/6/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }

    func angle(to other: CGPoint) -> CGFloat {
        let relative = other - self
        return atan2(relative.y, relative.x).degrees
    }

    func distance(to other: CGPoint) -> CGFloat {
        return sqrt(pow(x-other.x, 2) + pow(y-other.y, 2))
    }
}
