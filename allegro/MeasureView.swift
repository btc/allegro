//
//  MeasureView.swift
//  allegro
//
//  Created by Qingping He on 1/16/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Foundation
import UIKit

class MeasureView: UIView {
    var staffLineThickness: CGFloat = 0
    var staffHeight: CGFloat = 0
    var staffDrawStart: CGFloat {
        return (self.frame.size.height - staffHeight) / 2
    }
    
    var staffLineOffset: CGFloat {
        return (staffHeight - staffLineThickness) / CGFloat(staffCount - 1)
    }
    
    fileprivate let staffCount = 5
    fileprivate let noteWidth = CGFloat(100)
    fileprivate let noteHeight = CGFloat(50)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // iOS expects draw(rect:) to completely fill
        // the view region with opaque content. This causes
        // the view background to be black unless we disable this.
        self.isOpaque = false
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(_: rect)

        for i in 0..<staffCount {
            let path = UIBezierPath(rect: CGRect(
                x: 0,
                y: staffDrawStart + CGFloat(i) * staffLineOffset,
                width: rect.width,
                height: staffLineThickness
                )
            )
            
            UIColor.black.setFill()
            path.fill()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let notes = [Note(value: .half, letter: .B, octave: 4), Note(value: .half, letter: .G, octave: 4), Note(value: .half, letter: .D, octave: 5)]
        let noteViewModels = notes.map { NoteViewModel(note: $0) }
        let noteViews = noteViewModels.map { NoteView(note: $0) }
        for v in noteViews {
            addSubview(v)
        }

        for (i, noteView) in noteViews.enumerated() {
            let x = CGFloat(100 * (i + 1))
            let y = staffDrawStart + staffHeight / 2 + staffLineOffset / 2 * CGFloat(noteView.note.pitch) - noteHeight / 2
            noteView.frame = CGRect(x: x, y: y, width: noteWidth, height: noteHeight)
        }
    }
}
