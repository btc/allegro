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
            newValue?.subscribe(self)
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
            // perhaps this should be done in bounds.didSet

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
        guard let store = store, let index = index else { return }
        let measure = store.measure(at: index)
        let s = MeasureGeometry.State(measureVM: measure,
                                      visibleSize: bounds.size,
                                      selectedNoteDuration: store.selectedNoteValue.nominalDuration)
        measureView.geometry = MeasureGeometry(state: s)
        contentSize = measureView.bounds.size
    }

    func scrollToCenterOfStaffLines() {
        guard let store = store, let index = index else { return }
        let measure = store.measure(at: index)
        let s = MeasureGeometry.State(measureVM: measure,
                                      visibleSize: bounds.size,
                                      selectedNoteDuration: store.selectedNoteValue.nominalDuration)
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
            let state = MeasureGeometry.State(measureVM: measure,
                                              visibleSize: measureView.geometry.state.visibleSize,
                                              selectedNoteDuration: store.selectedNoteValue.nominalDuration)
            measureView.geometry = MeasureGeometry(state: state)
        }
        
        contentSize = measureView.bounds.size
    }
}
