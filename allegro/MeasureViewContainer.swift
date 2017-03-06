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
        willSet {
            store?.unsubscribe(self)
        }
        didSet {
            store?.subscribe(self)
            measureView.store = store
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
            // perhaps this should be done in bounds.didSet

            scrollToCenterOfStaffLines()
        }
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        panGestureRecognizer.minimumNumberOfTouches = 1

        addSubview(measureView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let store = store, let index = index else { return }
        let measure = store.measure(at: index)
        let s = MeasureGeometry.State(measure: measure,
                                      visibleSize: bounds.size)
        measureView.geometry = MeasureGeometry(state: s)
        contentSize = measureView.bounds.size
    }

    func scrollToCenterOfStaffLines() {
        guard let store = store, let index = index else { return }
        let measure = store.measure(at: index)
        let s = MeasureGeometry.State(measure: measure,
                                      visibleSize: bounds.size)
        let g = MeasureGeometry(state: s) // because measureView doesn't have a geometry until layoutSubviews
        let point = CGPoint(x: 0, y: g.totalHeight / 2 - g.state.visibleSize.height / 2)
        setContentOffset(point, animated: false)
    }
}

extension MeasureViewContainer: PartStoreObserver {
    func partStoreChanged() {
        guard let store = store, let index = index else { return }
        if measureView.geometry.state.visibleSize != .zero {
            let measure = store.measure(at: index)
            let state = MeasureGeometry.State(measure: measure,
                                              visibleSize: measureView.geometry.state.visibleSize)
            measureView.geometry = MeasureGeometry(state: state)
        }
        
        contentSize = measureView.bounds.size
        
        switch store.mode {
        case .edit:
            panGestureRecognizer.minimumNumberOfTouches = 1
        case .erase:
            panGestureRecognizer.minimumNumberOfTouches = 2
        }
    }
}
