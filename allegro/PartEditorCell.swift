//
//  PartEditorCollectionViewCell.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class PartEditorCell: UICollectionViewCell {
    static let reuseID = "PartEditorCell"

    var store: PartStore? {
        didSet {
            if let store = store {
                measureViewContainer.store = store
            }
        }
    }

    let measureViewContainer: MeasureViewContainer = {
        let v = MeasureViewContainer()
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(measureViewContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        measureViewContainer.frame = bounds
    }
}
