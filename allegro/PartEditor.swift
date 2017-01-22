//
//  CompositionContainer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/17/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class PartEditor: UICollectionView {

    let store: PartStore
    
    init(store: PartStore) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.store = store
        super.init(frame: .zero, collectionViewLayout: layout)

        store.observers.append(Weak<PartStoreObserver>(self))

        panGestureRecognizer.minimumNumberOfTouches = 3
        panGestureRecognizer.maximumNumberOfTouches = 3
        isPagingEnabled = true
        register(PartEditorCell.self, forCellWithReuseIdentifier: PartEditorCell.reuseID)
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
}

extension PartEditor: UICollectionViewDelegateFlowLayout {

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

extension PartEditor: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return store.measureCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PartEditorCell.reuseID,
                                                      for: indexPath)
        if let c = cell as? PartEditorCell {
            c.store = store
            c.index = indexPath.row
        }
        return cell
    }
}

extension PartEditor: PartStoreObserver {
    func partStoreChanged() {
        // TODO(btc): update collection view to reflect any changes in number of measures
    }
}
