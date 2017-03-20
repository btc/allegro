//
//  CompositionModeToggleButton.swift
//  allegro
//
//  Created by Brian Tiger Chow on 3/20/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class CompositionModeToggleButton: UIButton {
    init() {
        super.init(frame: .zero)
        backgroundColor = .allegroPurple
        setImage(#imageLiteral(resourceName: "note mode"), for: .normal)
        setImage(#imageLiteral(resourceName: "eraser"), for: .selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var frame: CGRect {
        didSet {
            guard let w = imageView?.frame.size.width, let h = imageView?.frame.size.height else { return }
            imageEdgeInsets = UIEdgeInsetsMake(h * 0.2, w * 0.2, h * 0.2, w * 0.2)
        }
    }
}
