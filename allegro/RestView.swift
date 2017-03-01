//
//  RestView.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/30/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class RestView: NoteActionView {
    let image = UIImageView()
    
    override init(note: NoteViewModel, geometry: NoteGeometry, store: PartStore) {
        super.init(note: note, geometry: geometry, store: store)
        addSubview(image)
        
        if note.note.value == .eighth {
            image.image = #imageLiteral(resourceName: "quarterrest")
        } else if note.note.value == .sixteenth {
            image.image = #imageLiteral(resourceName: "eighthrest")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        image.frame = bounds
    }
}
