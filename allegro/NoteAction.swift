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

extension NoteAction: CustomStringConvertible {
    var description: String {
        switch self {
        case .flat, .sharp, .natural, .rest, .dot: return rawValue
        case .undot: return "un-dot"
        case .doubleDot: return "double dot"
        }
    }
}

protocol NoteActionDelegate: class {
    func actionRecognized(gesture: NoteAction, at location: CGPoint)
}
