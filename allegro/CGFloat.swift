//
//  CGFloat.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/13/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational
import UIKit

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180.0 / M_PI)
    }
    
    func round(denom: Int) -> Rational {
        guard let output = Rational(Int(self * CGFloat(denom)), denom) else { return Rational(0) }
        return output
    }
}
