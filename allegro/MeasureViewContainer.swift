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
        v.staffLineThickness = 2
        return v
    }()

    override var frame: CGRect {
        didSet {
            // once we know our size, we have enough information to determine the size of the measure view and scroll 
            // to the center. So, we scroll to the center as soon as the frame is set.
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

    override func layoutSubviews() {
        super.layoutSubviews()

        measureView.sizeOfParentsVisibleArea = bounds.size
        contentSize = measureView.bounds.size
    }

    func scrollToCenterOfStaffLines() {
        let point = CGPoint(x: 0, y: MeasureView.totalHeight(visibleHeight: bounds.height) / 2 - bounds.height / 2)
        setContentOffset(point, animated: false)
    }
}
