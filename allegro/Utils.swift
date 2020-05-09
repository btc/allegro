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
    static let allegroBlue = UIColor(red:0.68, green:0.92, blue:1.0, alpha:1.0) // #AEEBFF
    static let allegroGray = UIColor.lightGray
    static let allegroPurple = UIColor(red:0.87, green:0.32, blue:0.63, alpha:1.0) // #DD51A0
    static let allegroDarkGray = UIColor(red: 0.46245, green: 0.46245, blue: 0.46245, alpha: 1.0) // #767676
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

    // -1 disables the tweak
    static let mockPartTweak = Tweak<Int>("Data", "Mocks", "Mock Index", defaultValue: -1, min: -1, max: mocks.count - 1, stepSize: 1)

    static let audio = Tweak<Bool>("General", "Audio", "Audio Enabled", false)

    static let defaultStore: TweakStore = {
        let allTweaks: [TweakClusterType] = [actionCost, actionDelta, mockPartTweak, audio]
        
        return TweakStore(tweaks: allTweaks, enabled: DEBUG)
    }()
}
