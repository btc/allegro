//
//  KeySignatureView.swift
//  allegro
//
//  Created by Nikhil Lele on 3/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

// Changes image based on Key Signature
class KeySignatureView: UIImageView {
    
    var key: Key {
        didSet {
            switch key.fifths {
            case -7:
                self.image = #imageLiteral(resourceName: "C-flat-major_a-flat-minor") // C flat Major
            case -6:
                self.image = #imageLiteral(resourceName: "G-flat-major_e-flat-minor") // G flat Major
            case -5:
                self.image = #imageLiteral(resourceName: "D-flat-major_b-flat-minor") // D flat Major
            case -4:
                self.image = #imageLiteral(resourceName: "A-flat-major_f-minor") // A flat Major
            case -3:
                self.image = #imageLiteral(resourceName: "E-flat-major_c-minor") // E flat Major
            case -2:
                self.image = #imageLiteral(resourceName: "B-flat-major_g-minor") // B flat Major
            case -1:
                self.image = #imageLiteral(resourceName: "F-major_d-minor") // F Major
            case 0:
                self.image = #imageLiteral(resourceName: "C-Major_a-minor") // C Major
            case 1:
                self.image = #imageLiteral(resourceName: "G-major_e-minor") // G Major
            case 2:
                self.image = #imageLiteral(resourceName: "D-major_h-minor") // D Major
            case 3:
                self.image = #imageLiteral(resourceName: "A-major_f-sharp-minor") // A Major
            case 4:
                self.image = #imageLiteral(resourceName: "E-major_c-sharp-minor") // E Major
            case 5:
                self.image = #imageLiteral(resourceName: "B-major_g-sharp-minor") // B Major
            case 6:
                self.image = #imageLiteral(resourceName: "F-sharp-major_d-sharp-minor") // F sharp Major
            case 7:
                self.image = #imageLiteral(resourceName: "C-sharp-major_a-sharp-minor") // C Sharp Major
            default:
                self.image = #imageLiteral(resourceName: "C-Major_a-minor") // C Major as default
            }
        }
    }

    init() {
        key = Key()
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
