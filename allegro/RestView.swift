//
//  RestView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/30/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class RestView: NoteActionView {
    fileprivate var images = [UIImageView()]
    static let restImages = [
        "quarter": #imageLiteral(resourceName: "quarterrest"),
        "eighth": #imageLiteral(resourceName: "eighthrest")
    ]
    
    static let selectedRestImages = [
        "quarter": #imageLiteral(resourceName: "selectedquarterrest"),
        "eighth": #imageLiteral(resourceName: "selectedeighthrest")
    ]
    
    // we can only call this once
    // but it should be fine since we are regenerating the ui every time
    override var isSelected: Bool {
        didSet {
            let image = images[0]
            let imageDict = isSelected ? RestView.selectedRestImages : RestView.restImages
            
            if note.note.value == .quarter {
                image.image = imageDict["quarter"]
            } else if note.note.value.nominalDuration <= Note.Value.eighth.nominalDuration {
                image.image = imageDict["eighth"]
                if note.note.value == .sixteenth {
                    let secondImage = UIImageView()
                    secondImage.image = imageDict["eighth"]
                    images.append(secondImage)
                }
            } else {
                image.backgroundColor = isSelected ? .allegroBlue : .black
            }
            
            for image in images {
                addSubview(image)
            }
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
        
        if images.count == 1 {
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
