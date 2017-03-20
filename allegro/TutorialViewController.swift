//
//  TutorialViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 3/20/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    let store: PartStore

    let measure = MeasureViewContainer()

    fileprivate let noteSelectorMenu: NoteSelectorMenu = {
        let v = NoteSelectorMenu()
        return v
    }()

    fileprivate let modeToggle: CompositionModeToggleButton = {
        let v = CompositionModeToggleButton()
        return v
    }()

    init() {
        self.store = PartStore(part: Part())
        super.init(nibName: nil, bundle: nil)
        store.subscribe(self)
        modeToggle.store = store
        noteSelectorMenu.store = store
        measure.store = store
        measure.index = store.part.measures.startIndex
        measure.isExtendEnabled = false
        view.addSubview(noteSelectorMenu)
        view.addSubview(modeToggle)
        view.addSubview(measure)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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

        measure.frame = CGRect(x: noteSelectorMenu.frame.maxX,
                               y: 0,
                               width: view.bounds.width - noteSelectorMenu.frame.width,
                               height: view.bounds.height)
    }
}

extension TutorialViewController: PartStoreObserver {
    func partStoreChanged(store: PartStore) {
    }
}
