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
    case toggleDot
    case toggleDoubleDot
}

protocol NoteActionDelegate: class {
    func actionRecognized(gesture: NoteAction, by view: UIView)
}
