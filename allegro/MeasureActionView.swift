//
//  AbstractNoteView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/1/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class MeasureActionView: UIView {

    var measureActionFrame: CGRect = .zero {
        didSet {
            // TODO(btc): configure the gesture recognizer
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
