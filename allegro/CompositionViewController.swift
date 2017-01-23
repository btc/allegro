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
        let sideMenuVC = SideMenuViewController()
        let container = SlideMenuController(mainViewController: vc, rightMenuViewController: sideMenuVC)
        return container
    }

    private init(store: PartStore) {
        self.store = store
        editor = PartEditor(store: store)

        super.init(nibName: nil, bundle: nil)

        store.selectedNoteDuration = noteSelectorMenu.selectedNoteDuration // first
        noteSelectorMenu.selectorDelegate = self // second
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
