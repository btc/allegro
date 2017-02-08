//
//  Rational.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/6/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Rational
import UIKit

extension Rational {
    var cgFloat: CGFloat {
        return CGFloat(Double(rational: self))
    }

    var intApprox: Int {
        return Int(Double(self.numerator)/Double(self.denominator))
    }

    var double: Double {
        return Double(rational: self)
    }
}
