//
//  PartListingCell.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import DateToolsSwift
import UIKit
import SwipyCell

class PartListingCell: SwipyCell {

    static let reuseID = "PartListingCell"
    static let height: CGFloat = 80
    static let margin: CGFloat = 3

    var filename: String? {
        didSet {
            if let filename = filename {
                let partNumber: String = filename.components(separatedBy: "_").last ?? "X"
                partTitle.text = part?.title ?? "Untitled Part \(partNumber)"
            } else {
                partTitle.text = part?.title ?? "Untitled Part X"
            }
        }
    }

    var part: Part? {
        didSet {
            if let filename = filename {
                let partNumber: String = filename.components(separatedBy: "_").last ?? "X"
                partTitle.text = part?.title ?? "Untitled Part \(partNumber)"
            } else {
                partTitle.text = part?.title ?? "Untitled Part X"
            }
        }
    }

    var modified: Date? {
        didSet {
            if let modified = modified {
                date.text = Date.timeAgo(since: modified)
            } else {
                date.text = ""
            }
        }
    }

    private let partTitle: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: DEFAULT_FONT, size: 14)
        v.backgroundColor = .white
        return v
    }()

    private let date: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: DEFAULT_FONT, size: 12)
        v.backgroundColor = .white
        return v
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        addSubview(partTitle)
        addSubview(date)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func layoutSubviews() {
        partTitle.frame = CGRect(x: PartListingCell.margin,
                                 y: PartListingCell.margin,
                                 width: bounds.width - 2 * PartListingCell.margin,
                                 height: bounds.height / 2 - 20)
        date.frame = CGRect(x: PartListingCell.margin,
                            y: partTitle.frame.maxY,
                            width: bounds.width - 2 * PartListingCell.margin,
                            height: bounds.height / 2 - 20)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        filename = nil
        part = nil
        modified = nil
    }
}
