//
//  MeasureCollectionViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 3/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class MeasureCollectionViewController: UIPageViewController {

    let store: PartStore

    var changedMeasureMyself: Bool = false

    init(store: PartStore) {
        self.store = store
        super.init(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        store.subscribe(self)
        dataSource = self
        delegate = self
        let measureOne = MeasureViewController(store: store, index: store.currentMeasure)
        let vcs = [measureOne]
        setViewControllers(vcs, direction: .forward, animated: false, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MeasureCollectionViewController: PartStoreObserver {
    func didChangeMeasure(oldValue: Int, currentMeasure: Int) {
        guard !changedMeasureMyself else {
            changedMeasureMyself = false
            return
        }
        let m = MeasureViewController(store: store, index: currentMeasure)
        let vcs = [m]
        setViewControllers(vcs, direction: .forward, animated: true, completion: nil)
    }
}

extension MeasureCollectionViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? MeasureViewController else { return nil }
        guard vc.index != 0 else { return nil }
        let before = MeasureViewController(store: store, index: vc.index - 1)
        return before
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? MeasureViewController else { return nil }
        let after = MeasureViewController(store: store, index: vc.index + 1)
        return after
    }
}

extension MeasureCollectionViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed, viewControllers?.count == 1 else { return }
        guard let vc = viewControllers?.first as? MeasureViewController else { return }
        changedMeasureMyself = true
        store.currentMeasure = vc.index
    }
}
