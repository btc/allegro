//
//  NoteSelectorView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

protocol NoteSelectorDelegate: class {
    func didChangeSelection(duration: Note.Duration)
}

class NoteSelectorMenu: UICollectionView {

    var selectedNoteDuration: Note.Duration {
        get {
            return notes[selectedNote]
        }
    }

    weak var selectorDelegate: NoteSelectorDelegate?

    fileprivate var selectedNote = 2 { // quarter is default selection
        didSet {
            selectorDelegate?.didChangeSelection(duration: selectedNoteDuration)
        }
    }

    fileprivate let numNotesVisibleAtOnce: CGFloat = 5

    fileprivate let notes: [Note.Duration] = [.whole, .half, .quarter, .eighth, .sixteenth,
                                           .thirtysecond, .sixtyfourth, .onetwentyeighth, .twofiftysixth]

    private let layout = UICollectionViewFlowLayout()

    init() {
        super.init(frame: .zero, collectionViewLayout: layout)
        register(NoteSelectorCell.self, forCellWithReuseIdentifier: NoteSelectorCell.reuseID)
        dataSource = self
        delegate = self // to get selected note callback
        isPagingEnabled = true // snaps the menu
        selectItem(at: IndexPath(row: selectedNote, section: 0), animated: true, scrollPosition: .top)
        backgroundColor = NoteSelectorCell.unselectedCellColor // to match the unselected color of the cell
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
}


extension NoteSelectorMenu: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedNote = indexPath.row
    }
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
