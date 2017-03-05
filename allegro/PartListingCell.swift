//
//  PartListingCell.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class PartListingCell: UICollectionViewCell {

    static let reuseID = "PartListingCell"

    var part: Part? {
        didSet {
            partTitle.text = part?.title ?? "Untitled Part"
        }
    }

    var modified = Date() {
        didSet {
            date.text = modified.description
        }
    }

    private let partTitle: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: DEFAULT_FONT, size: 14)
        v.backgroundColor = .green
        return v
    }()

    private let date: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: DEFAULT_FONT, size: 14)
        v.backgroundColor = .blue
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(partTitle)
        addSubview(date)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func layoutSubviews() {
        partTitle.frame = CGRect(x: DEFAULT_MARGIN_PTS,
                                 y: DEFAULT_MARGIN_PTS,
                                 width: bounds.width - 2 * DEFAULT_MARGIN_PTS,
                                 height: bounds.height / 2)
        date.frame = CGRect(x: DEFAULT_MARGIN_PTS,
                            y: partTitle.frame.maxY,
                            width: bounds.width - 2 * DEFAULT_MARGIN_PTS,
                            height: bounds.height / 2)

    }
}
