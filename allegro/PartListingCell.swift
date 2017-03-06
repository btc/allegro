//
//  PartListingCell.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import DateToolsSwift
import UIKit

class PartListingCell: UITableViewCell {

    static let reuseID = "PartListingCell"
    static let height: CGFloat = 100

    let margin: CGFloat = 3

    var filename: String = "" {
        didSet {
            partTitle.text = part?.title ?? "Untitled Part (\(filename).xml)"
        }
    }

    var part: Part? {
        didSet {
            partTitle.text = part?.title ?? "Untitled Part (\(filename).xml)"
        }
    }

    var modified = Date() {
        didSet {
            date.text = Date.timeAgo(since: modified)
        }
    }

    private let partTitle: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: DEFAULT_FONT, size: 14)
        return v
    }()

    private let date: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: DEFAULT_FONT, size: 14)
        return v
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(partTitle)
        addSubview(date)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func layoutSubviews() {
        partTitle.frame = CGRect(x: margin,
                                 y: margin,
                                 width: bounds.width - 2 * margin,
                                 height: bounds.height / 2)
        date.frame = CGRect(x: margin,
                            y: partTitle.frame.maxY,
                            width: bounds.width - 2 * margin,
                            height: bounds.height / 2)

    }
}
