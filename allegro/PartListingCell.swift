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

    var filename: String? {
        didSet {
            if let filename = filename {
                let partNumber: String = filename.components(separatedBy: "_").last ?? "X"
                self.textLabel?.text = part?.title ?? "Untitled Part \(partNumber)"
            } else {
                self.textLabel?.text = part?.title ?? "Untitled Part X"
            }
        }
    }

    var part: Part? {
        didSet {
            if let filename = filename {
                let partNumber: String = filename.components(separatedBy: "_").last ?? "X"
                self.textLabel?.text = part?.title ?? "Untitled Part \(partNumber)"
            } else {
                self.textLabel?.text = part?.title ?? "Untitled Part X"
            }
        }
    }

    var modified: Date? {
        didSet {
            if let modified = modified {
                self.detailTextLabel?.text = Date.timeAgo(since: modified)
            } else {
                self.detailTextLabel?.text = "MODIFIED"
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        // use subtitle style
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        filename = nil
        part = nil
        modified = nil
    }
}
