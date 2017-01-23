//
//  CompositionViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit
import Rational
import SlideMenuControllerSwift

class CompositionViewController: UIViewController {

    fileprivate var noteSelectorMenu: NoteSelectorMenu = {
        // TODO(btc): when noteSelectorMenu's selected note changes, update the PartStore
        let v = NoteSelectorMenu()
        return v
    }()

    fileprivate var store: PartStore

    fileprivate var editor: PartEditor

    static func create(part: Part) -> UIViewController {
        let store = PartStore(part: part)
        let vc = CompositionViewController(store: store)
        let sideMenuVC = SideMenuViewController(store: store)

        // NB(btc): The way the library provides customization (static options) makes it so that it's only feasible to have
        // one sidemenu controller in the project. If we decide we need another, with different options, fork the repo
        // and move the options to the instance of the SideMenuViewController.
        SlideMenuOptions.animationDuration = 0.15 // seconds

        let container = SlideMenuController(mainViewController: vc, rightMenuViewController: sideMenuVC)
        return container
    }

    private init(store: PartStore) {
        self.store = store
        editor = PartEditor(store: store)

        super.init(nibName: nil, bundle: nil)

        noteSelectorMenu.selectorDelegate = self
        store.selectedNoteDuration = noteSelectorMenu.selectedNoteDuration
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        view.addSubview(editor)
        view.addSubview(noteSelectorMenu)
    }

    override func viewDidLayoutSubviews() {
        // occupies the left side of the screen
        noteSelectorMenu.frame = CGRect(x: 0,
                                        y: 0,
                                        width: DEFAULT_TAP_TARGET_SIZE,
                                        height: view.bounds.height)

        // occupies space to the right of the menu
        editor.frame = CGRect(x: noteSelectorMenu.frame.maxX,
                                  y: 0,
                                  width: view.bounds.width - noteSelectorMenu.frame.width,
                                  height: view.bounds.height)
    }
}


extension CompositionViewController: NoteSelectorDelegate {
    func didChangeSelection(duration: Note.Duration) {
        store.selectedNoteDuration = duration
        Log.info?.message("user selected \(duration) duration")
    }
}
