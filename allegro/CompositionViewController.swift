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

    fileprivate let noteSelectorMenu: NoteSelectorMenu = {
        let v = NoteSelectorMenu()
        return v
    }()

    fileprivate let modeToggle: UIButton = {
        let v = UIButton()
        v.addTarget(self, action: #selector(toggled), for: .touchUpInside)
        v.titleLabel?.font = UIFont(name: DEFAULT_FONT, size: 16)
        v.backgroundColor = .allegroPurple

        v.setImage(#imageLiteral(resourceName: "note mode"), for: .normal)
        v.setTitleColor(.white, for: .selected)

        v.setImage(#imageLiteral(resourceName: "eraser"), for: .selected)
        v.imageView?.layer.minificationFilter = kCAFilterTrilinear

        return v
    }()
    
    private let menuIndicator: UIView = {
        let v = UIButton()
        v.setImage(#imageLiteral(resourceName: "arrow"), for: UIControlState.normal)
        v.imageView?.contentMode = .scaleAspectFit
        v.backgroundColor = .clear
        return v
    }()

    fileprivate let store: PartStore

    fileprivate var editor: MeasureViewCollection

    fileprivate let audio: Audio?

    static func create(part: Part) -> UIViewController {
        let store = PartStore(part: part)
        let vc = CompositionViewController(store: store)
        let sideMenuVC = SideMenuViewController(store: store)

        // NB(btc): The way the library provides customization (static options) makes it so that it's only feasible to have
        // one sidemenu controller in the project. If we decide we need another, with different options, fork the repo
        // and move the options to the instance of the SideMenuViewController.
        SlideMenuOptions.animationDuration = 0.07 // seconds

        let container = SlideMenuController(mainViewController: vc, rightMenuViewController: sideMenuVC)
        return container
    }

    private init(store: PartStore) {
        self.store = store
        editor = MeasureViewCollection(store: store)
        audio = Tweaks.assign(Tweaks.audio) ? Audio(store: store) : nil

        super.init(nibName: nil, bundle: nil)

        noteSelectorMenu.selectorDelegate = self
        store.selectedNoteValue = noteSelectorMenu.selectedNoteValue
        store.subscribe(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        view.addSubview(editor)
        view.addSubview(noteSelectorMenu)
        view.addSubview(modeToggle)
        view.addSubview(menuIndicator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        audio?.start()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audio?.stop()
    }

    override func viewDidLayoutSubviews() {
        let leftMenuWidth = DEFAULT_TAP_TARGET_SIZE
        let toggleHeight = DEFAULT_TAP_TARGET_SIZE
        // occupies (most of) the left side of the screen
        noteSelectorMenu.frame = CGRect(x: 0,
                                        y: 0,
                                        width: leftMenuWidth,
                                        height: view.bounds.height - toggleHeight)

        modeToggle.frame = CGRect(x: 0,
                                  y: noteSelectorMenu.frame.maxY,
                                  width: leftMenuWidth,
                                  height: toggleHeight)
        //Added insets for button images. Added here instead of closure initalizer 
        //because the frame size is set above.
        modeToggle.imageEdgeInsets = UIEdgeInsetsMake((modeToggle.imageView?.frame.size.height)!*0.2, (modeToggle.imageView?.frame.size.width)!*0.2, (modeToggle.imageView?.frame.size.height)!*0.2, (modeToggle.imageView?.frame.size.width)!*0.2)

        // occupies space to the right of the menu
        editor.frame = CGRect(x: noteSelectorMenu.frame.maxX,
                                  y: 0,
                                  width: view.bounds.width - noteSelectorMenu.frame.width,
                                  height: view.bounds.height)
        
        let buttonW = view.bounds.width/30
        
        menuIndicator.frame = CGRect(x: view.bounds.width - buttonW,
                                     y: -DEFAULT_MARGIN_PTS/2,
                                     width: buttonW,
                                     height: view.bounds.height)
    }

    func toggled() {
        switch store.mode {
        case .edit:
            store.mode = .erase
        case .erase:
            store.mode = .edit
        }
    }
}

extension CompositionViewController: PartStoreObserver {
    func partStoreChanged() {
        switch store.mode {
        case .edit:
            modeToggle.isSelected = false
        case .erase:
            modeToggle.isSelected = true
        }
    }
}

extension CompositionViewController: NoteSelectorDelegate {
    func didChangeSelection(value: Note.Value) {
        store.selectedNoteValue = value
        Log.info?.message("user selected \(value) value")
    }
}
