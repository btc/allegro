//
//  CompositionContainer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/17/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

class MeasureViewCollection: UICollectionView {

    let store: PartStore

    // it's necessary to track the measure count because we need to know when the value increases. when the value
    // increases, we add new measures to the view
    fileprivate var measureCount: Int {
        didSet {
            if oldValue < measureCount {
                var new = [IndexPath]()
                for i in stride(from: oldValue, to: measureCount, by: 1) {
                    new.append(IndexPath(row: i, section: 0))
                }
                insertItems(at: new)
            }

        }
    }

    var visibleMeasure: IndexPath? {
        didSet {
            guard let visibleMeasure = visibleMeasure else { return }
            store.currentMeasure = visibleMeasure.item
        }
    }

    let overviewPinchRecognizer: UIGestureRecognizer = {
        let gr = UIPinchGestureRecognizer()
        return gr
    }()
    
    init(store: PartStore) {

        let layout = AnimatedCollectionViewLayout()
        let animator = PageAttributeAnimator(scaleRate: 0.8)
        layout.scrollDirection = .horizontal
        layout.animator = animator

        self.store = store
        measureCount = store.measureCount

        super.init(frame: .zero, collectionViewLayout: layout)

        store.subscribe(self)

        addGestureRecognizer(overviewPinchRecognizer)
        overviewPinchRecognizer.addTarget(self, action: #selector(pinched))

        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 2
        panGestureRecognizer.delegate = self
        isPagingEnabled = true
        backgroundColor = .white
        register(MeasureViewCollectionCell.self, forCellWithReuseIdentifier: MeasureViewCollectionCell.reuseID)
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    func pinched(sender: UIPinchGestureRecognizer) {
        if sender.scale < 0.5 {
            store.view = .overview
        }
    }
}

extension MeasureViewCollection: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MeasureViewCollection: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let i = indexPathForItem(at: visiblePoint) {
            visibleMeasure = i
        }
    }
}

extension MeasureViewCollection: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return measureCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MeasureViewCollectionCell.reuseID,
                                                      for: indexPath)
        if let c = cell as? MeasureViewCollectionCell {
            c.store = store
            c.index = indexPath.row
        }
        return cell
    }
}

extension MeasureViewCollection: PartStoreObserver {
    func partStoreChanged() {
        measureCount = store.measureCount
        switch store.mode {
        case .edit:
            panGestureRecognizer.minimumNumberOfTouches = 1
        case .erase:
            panGestureRecognizer.minimumNumberOfTouches = 2
        }
        if visibleMeasure != nil && store.currentMeasure != visibleMeasure?.item {
            let item = IndexPath(item: store.currentMeasure, section: 0)
            visibleMeasure = item
            scrollToItem(at: item, at: .centeredHorizontally, animated: false)
        }
    }
}

extension MeasureViewCollection: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == panGestureRecognizer && otherGestureRecognizer as? UIScreenEdgePanGestureRecognizer != nil
    }
}
