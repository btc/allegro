//
//  PartListingCell.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import DateToolsSwift
import UIKit
import MGSwipeTableCell

class PartListingCell: MGSwipeTableCell {

    static let reuseID = "PartListingCell"
    static let height: CGFloat = 80
    static let xMargin: CGFloat = 20
    static let yMargin: CGFloat = 10
    static let titleWidth: CGFloat = 200

    // TODO try detailTextLabel

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
        v.lineBreakMode = .byTruncatingTail
        v.backgroundColor = .white
        return v
    }()

    private let date: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: DEFAULT_FONT, size: 12)
        v.lineBreakMode = .byTruncatingTail
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
        super.layoutSubviews()
        partTitle.frame = CGRect(x: PartListingCell.xMargin,
                                 y: PartListingCell.yMargin,
                                 width: PartListingCell.titleWidth,
                                 height: bounds.height / 3)
        
        date.frame = CGRect(x: PartListingCell.xMargin,
                            y: partTitle.frame.maxY,
                            width: PartListingCell.titleWidth,
                            height: bounds.height / 2)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        filename = nil
        part = nil
        modified = nil
    }
}
