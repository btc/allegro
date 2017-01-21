//
//  CompositionContainer.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/17/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class PartEditor: UICollectionView {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        panGestureRecognizer.minimumNumberOfTouches = 3
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
        return 2 // TODO(btc): this is where the shadow measure comes into play
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PartEditorCell.reuseID,
                                                      for: indexPath)
        return cell
    }
}
