//
//  CompositionContainer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/17/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

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
    
    init(store: PartStore) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.store = store
        measureCount = store.measureCount
        super.init(frame: .zero, collectionViewLayout: layout)

        store.subscribe(self)

        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 2
        isPagingEnabled = true
        backgroundColor = .lightGray
        register(MeasureViewCollectionCell.self, forCellWithReuseIdentifier: MeasureViewCollectionCell.reuseID)
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
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

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let finalCellFrame = cell.frame
        let translation: CGPoint = panGestureRecognizer.translation(in: superview)
        if translation.x > 0 {
            cell.frame = CGRect(x: finalCellFrame.origin.x - 1000, y: -500, width: 0, height: 0)
        } else {
            cell.frame = CGRect(x: finalCellFrame.origin.x + 1000, y: -500, width: 0, height: 0)
        }
        UIView.animate(withDuration: 0.5) {
            cell.frame = finalCellFrame
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
    }
}
