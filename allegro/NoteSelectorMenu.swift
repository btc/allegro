//
//  NoteSelectorView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class NoteSelectorMenu: UICollectionView {

    private let indexofDefaultSelectedNote = 0
    fileprivate let numNotesVisibleAtOnce: CGFloat = 5
    fileprivate let notes = ["1", "2", "4", "8", "16", "18", "32", "64", "128", "256"] // TODO(btc): replace with actual notes
    private let layout = UICollectionViewFlowLayout()

    init() {
        super.init(frame: .zero, collectionViewLayout: layout)
        register(NoteSelectorCell.self, forCellWithReuseIdentifier: NoteSelectorCell.reuseID)
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
}


extension NoteSelectorMenu: UICollectionViewDelegate {
    // TODO(btc): manage highlighting and selection
}

extension NoteSelectorMenu: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteSelectorCell.reuseID,
                                                      for: indexPath)
        if let c = cell as? NoteSelectorCell {
            c.note = notes[indexPath.row]
        }
        return cell
    }
}

extension NoteSelectorMenu: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: bounds.width, height: bounds.height/numNotesVisibleAtOnce)
    }

    // controls the spacing between buttons
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
