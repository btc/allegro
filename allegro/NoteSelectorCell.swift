//
//  NoteSelectorCell.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class NoteSelectorCell: UICollectionViewCell {
    static let reuseID = "NoteSelectorCell"
    static let unselectedCellColor = UIColor.gray

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                label.textColor = .gray
                label.backgroundColor = .white
            } else {
                label.backgroundColor = NoteSelectorCell.unselectedCellColor
                label.textColor = .white
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.textColor = .white
                label.backgroundColor = .lightGray
            } else {
                label.backgroundColor = NoteSelectorCell.unselectedCellColor
                label.textColor = .white
            }
        }
    }

    private let label: UILabel = {
        let v = UILabel()
        v.backgroundColor = NoteSelectorCell.unselectedCellColor
        v.textColor = .white
        v.textAlignment = .center
        return v
    }()

    // TODO(btc): replace with Note model
    var note: Note.Duration? = nil {
        didSet {
            label.text = note?.description
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        label.frame = bounds
    }
}
