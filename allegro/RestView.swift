//
//  RestView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/30/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class RestView: NoteActionView {
    fileprivate var images = [UIImageView(), UIImageView()]
    static let restImages = [
        "quarter": #imageLiteral(resourceName: "quarterrest"),
        "eighth": #imageLiteral(resourceName: "eighthrest")
    ]
    
    static let selectedRestImages = [
        "quarter": #imageLiteral(resourceName: "selectedquarterrest"),
        "eighth": #imageLiteral(resourceName: "selectedeighthrest")
    ]
    
    override var isSelected: Bool {
        didSet {
            for image in images {
                // gotta check if an image is a descendant since 16th rest is made of 
                // two images
                if image.isDescendant(of: self) {
                    image.removeFromSuperview()
                }
            }
            
            let image = images[0]
            let imageDict = isSelected ? RestView.selectedRestImages : RestView.restImages
            
            if note.note.value == .quarter {
                image.image = imageDict["quarter"]
            } else if note.note.value.nominalDuration <= Note.Value.eighth.nominalDuration {
                image.image = imageDict["eighth"]
                if note.note.value == .sixteenth {
                    let secondImage = images[1]
                    secondImage.image = imageDict["eighth"]
                    addSubview(secondImage)
                }
            } else {
                image.backgroundColor = isSelected ? .allegroBlue : .black
            }
            
            addSubview(image)
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if note.note.value.nominalDuration >= Note.Value.half.nominalDuration {
            let insetSize = (bounds.size.width - geometry.restBoxWidth) / 2
            let imageSize = bounds.insetBy(dx: insetSize, dy: 0)
            images[0].frame = imageSize
            return
        }
        
        if note.note.value.nominalDuration > Note.Value.sixteenth.nominalDuration {
            images[0].frame = bounds
        } else {
            // we draw sixteenth rests as two images stacked on top of each other
            // because we can't find an actual sixteenth rest that fits with the eighth rest
            let center = bounds.origin.offset(dx: bounds.size.width / 2, dy: bounds.size.height / 2)
            
            let size = geometry.getRestSize(value: Note.Value.eighth)
            let origin1 = center.offset(dx: -geometry.sixteenthSecondImageOffset.x - size.width / 2, dy: -size.height / 2)
            let origin2 = origin1.offset(dx: geometry.sixteenthSecondImageOffset.x, dy: geometry.sixteenthSecondImageOffset.y)
            
            
            images[0].frame = CGRect(origin: origin1, size: size)
            images[1].frame = CGRect(origin: origin2, size: size)
        }
    }
    
    func setDotPosition(geometry: MeasureGeometry) {
        guard let view = dotView else { return }
        let y = geometry.staffY(pitch: 1) - view.frame.height / 2
        view.frame.origin.y = y - frame.origin.y
    }
    
}
