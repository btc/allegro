//
//  KeySignatureView.swift
//  allegro
//
//  Created by Nikhil Lele on 3/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class KeySignatureView: UIImageView {
    
    var key: Key {
        didSet {
            // update keyView image
            // TODO replace this placeholder image
            self.image = #imageLiteral(resourceName: "timesig34")
        }
    }

    init() {
        key = Key()
        super.init(frame: CGRect.zero)
        image = #imageLiteral(resourceName: "timesig34")
        backgroundColor = .allegroBlue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
