//
//  SideMenuButtonView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/4/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class SideMenuButtonView: UIButton {

    let margin: CGFloat = 5

    override var isSelected: Bool {
        didSet {

        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        titleLabel?.font = UIFont(name: DEFAULT_FONT_BOLD, size: 20)
        imageView?.contentMode = .scaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let h = bounds.height - 2 * margin
        imageView?.frame = CGRect(x: margin, y: margin, width: h, height: h)
        titleLabel?.frame = CGRect(x: bounds.width / 2, y: margin, width: bounds.width / 2, height: h)
    }
}
