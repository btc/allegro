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
let DEFAULT_FONT_BOLD = "HelveticaNeue-Bold"

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
    
    static let defaultStore: TweakStore = {
        let allTweaks: [TweakClusterType] = [actionCost, actionDelta]
        
        return TweakStore(tweaks: allTweaks, enabled: DEBUG)
    }()
}
