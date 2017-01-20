//
//  MeasureViewContainer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class MeasureViewContainer: UIScrollView {

    let measureView: UIView = {
        let v = MeasureView()
        v.staffLineThickness = 5
        v.staffHeight = 200
        return v
    }()

    init() {
        super.init(frame: .zero)
        panGestureRecognizer.minimumNumberOfTouches = 2

        addSubview(measureView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        measureView.frame = bounds
    }
}
