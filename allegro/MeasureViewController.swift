//
//  MeasureViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 3/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class MeasureViewController: UIViewController {

    var measureViewContainer: MeasureViewContainer = {
        let v = MeasureViewContainer()
        v.isExtendEnabled = true
        return v
    }()

    let store: PartStore

    let index: Int

    init(store: PartStore, index: Int) {
        self.store = store
        self.index = index
        super.init(nibName: nil, bundle: nil)
        measureViewContainer.store = store
        measureViewContainer.index = index
        view.addSubview(measureViewContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        measureViewContainer.frame = view.bounds
    }
}
