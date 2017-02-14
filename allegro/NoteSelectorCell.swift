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
    static let unselectedCellColor = UIColor.white
    static let unselectedTextColor = UIColor.black

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = .white
                label.backgroundColor = .white
            } else {
                backgroundColor = NoteSelectorCell.unselectedCellColor
                label.backgroundColor = NoteSelectorCell.unselectedCellColor
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .allegroBlue
                label.backgroundColor = .allegroBlue
            } else {
                backgroundColor = NoteSelectorCell.unselectedCellColor
                label.backgroundColor = NoteSelectorCell.unselectedCellColor
            }
        }
    }

    private let label: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = NoteSelectorCell.unselectedCellColor
        v.contentMode = .scaleAspectFit
        return v
    }()
    

    var note: Note.Value? = nil {
        didSet {
            guard let note = note else { return }
            switch note {
            case .whole:
                label.image = #imageLiteral(resourceName: "whole")
            case .half:
                label.image = #imageLiteral(resourceName: "half note")
            case .quarter:
                label.image = #imageLiteral(resourceName: "quarter note")
            case .eighth:
                label.image = #imageLiteral(resourceName: "eighth note")
            case .sixteenth:
                label.image = #imageLiteral(resourceName: "sixteenth note")
            default:
                //nothing higher is currently supported. Will add relevant assets
                //as needed
                label.image = #imageLiteral(resourceName: "quarter note")
            }
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
        label.frame = bounds.insetBy(dx: bounds.width*0.1, dy: bounds.height*0.1)
        
    }
}
