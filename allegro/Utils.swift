//
//  Utils.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import CleanroomLogger
import UIKit
import SwiftTweaks
import Rational

#if DEBUG
    let DEBUG = true
#else
    let DEBUG = false
#endif

typealias Log = CleanroomLogger.Log // to avoid importing CleanroomLogger in every file where we log things

let THE_GOLDEN_RATIO: CGFloat = 1.61803398875
let DEFAULT_MARGIN_PTS: CGFloat = 22
let DEFAULT_TAP_TARGET_SIZE: CGFloat = 60
let DEFAULT_FONT_BOLD = "Montserrat-Bold"
let DEFAULT_FONT = "Montserrat-Regular"

extension UIColor {
    static let allegroBlue = UIColor(red:0.68, green:0.92, blue:1.0, alpha:1.0)
    static let allegroPurple = UIColor(red:0.87, green:0.32, blue:0.63, alpha:1.0)
}

// TODO(btc): Handle localization
// All strings are here so we know where to look when we want to add new languages
struct Strings {
    static let APP_NAME = "Allegro"
    static let NEW = "New"
    static let INSTRUCTIONS = "Instructions"
}

struct Tweaks: TweakLibraryType {
    static let actionCost = Tweak<Int>("General", "Gestures", "Action Cost", defaultValue: 1, min: 0)
    static let actionDelta = Tweak<Double>("General", "Gestures", "Delta", defaultValue: 22, min: 0)

    
    static let flagThickness = Tweak<CGFloat>("UI", "Flags", "Thickness", defaultValue: 10, min: 1)
    static let flagOffset = Tweak<CGFloat>("UI", "Flags", "Offset for the stem to prevent it from poking out", defaultValue: 5, min: 1)
    static let flagIterOffset = Tweak<CGFloat>("UI", "Flags", "Distance between flags", defaultValue: 10, min: 1)
    static let flagEndOffsetX = Tweak<CGFloat>("UI", "Flags", "Flag length X", defaultValue: 40, min: 1)
    static let flagEndOffsetY = Tweak<CGFloat>("UI", "Flags", "Flag length Y", defaultValue: 70, min: 1)


    static let defaultStore: TweakStore = {
        let allTweaks: [TweakClusterType] = [actionCost, actionDelta, flagThickness, flagOffset, flagIterOffset, flagEndOffsetX, flagEndOffsetY]
        
        return TweakStore(tweaks: allTweaks, enabled: DEBUG)
    }()
}

extension Rational {
    var cgFloat: CGFloat {
        return CGFloat(Double(rational: self))
    }

    var intApprox: Int {
        return Int(Double(self.numerator)/Double(self.denominator))
    }

    var double: Double {
        return Double(rational: self)
    }
}
