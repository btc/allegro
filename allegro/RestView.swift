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
    
    override init(note: NoteViewModel, geometry: NoteGeometry, store: PartStore) {
        super.init(note: note, geometry: geometry, store: store)
        let image = images[0]
        
        if note.note.value == .quarter {
            image.image = RestView.restImages["quarter"]
        } else if note.note.value.nominalDuration <= Note.Value.eighth.nominalDuration {
            image.image = RestView.restImages["eighth"]
            if note.note.value == .sixteenth {
                let secondImage = UIImageView()
                secondImage.image = RestView.restImages["eighth"]
                images.append(secondImage)
            }
        } else {
            image.backgroundColor = UIColor.black
        }
        
        for image in images {
            addSubview(image)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            guard let size = geometry.restSize[Note.Value.eighth] else { return }
            let origin1 = center.offset(dx: -size.width / 2, dy: -size.height / 2)
            images[0].frame = CGRect(origin: origin1, size: size)
            let origin2 = origin1.offset(dx: -14.5, dy: 45)
            
            images[1].frame = CGRect(origin: origin2, size: size)
        }
    }
}
