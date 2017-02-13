//
//  CGFloat.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/13/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180.0 / M_PI)
    }
}
