//
//  NoteAction.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/8/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

enum NoteAction: String {
    case flat
    case sharp
    case natural
    case rest
    case undot
    case dot
    case doubleDot
}

protocol NoteActionDelegate: class {
    func actionRecognized(gesture: NoteAction, at location: CGPoint)
}
