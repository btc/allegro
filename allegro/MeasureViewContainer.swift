//
//  MeasureViewContainer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class MeasureViewContainer: UIScrollView {

    var store: PartStore? {
        set {
            measureView.store = newValue
        }
        get {
            return measureView.store
        }
    }

    var index: Int? {
        set {
            measureView.index = newValue
        }
        get {
            return measureView.index
        }
    }

    let measureView: MeasureView = {
        let v = MeasureView()
        return v
    }()

    override var frame: CGRect {
        didSet {
            // once we know our size, we have enough information to determine the size of the measure view and scroll
            // to the center. So, we scroll to the center as soon as the frame is set.
            measureView.geometry = MeasureGeometry(visibleSize: bounds.size)
            contentSize = measureView.bounds.size
            scrollToCenterOfStaffLines()
        }
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        panGestureRecognizer.minimumNumberOfTouches = 2
        isDirectionalLockEnabled = true

        addSubview(measureView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    func scrollToCenterOfStaffLines() {
        let g = measureView.geometry
        let point = CGPoint(x: 0, y: g.totalHeight / 2 - g.visibleSize.height / 2)
        setContentOffset(point, animated: false)
    }
}
