//
//  MeasureTouchGuide.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/6/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class MeasureTouchGuide: UIView {

    let topGradient = CAGradientLayer()
    let botGradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        for l in [topGradient, botGradient] {
            layer.addSublayer(l)
        }
        let colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.allegroBlue.cgColor]
        topGradient.colors = colors
        botGradient.colors = colors.reversed()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let half = CGSize(width: bounds.width, height: bounds.height / 2)
        topGradient.frame = CGRect(origin: bounds.origin, size: half)
        let offset = bounds.offsetBy(dx: 0, dy: bounds.height / 2).origin
        botGradient.frame = CGRect(origin: offset, size: half)
    }
}
