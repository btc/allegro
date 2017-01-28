//
//  Snackbar.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import TTGSnackbar

class Snackbar: TTGSnackbar {
    override init(message: String, duration: TTGSnackbarDuration) {
        super.init(message: message, duration: duration)
        messageTextColor = .white
        if let font = UIFont(name: DEFAULT_FONT, size: 16) {
            messageTextFont = font
        }
        messageTextAlign = .center
        animationType = .slideFromTopBackToTop
        backgroundColor = .allegroPurple
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
