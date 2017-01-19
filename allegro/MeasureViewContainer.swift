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
        return v
    }()

    init() {
        super.init(frame: .zero)

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
