//
//  HomeMenuViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class PartListingViewController: UIViewController {

    private let newCompositionButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = UIColor.gray
        v.setTitle(Strings.NEW, for: .normal)
        return v
    }()

    private let partListing: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.register(PartListingCell.self, forCellWithReuseIdentifier: PartListingCell.reuseID)
        v.backgroundColor = .allegroBlue
        return v
    }()

    fileprivate let partFileManager: PartFileManager = PartFileManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        partListing.dataSource = self
        partListing.delegate = self

        view.backgroundColor = UIColor.white

        view.addSubview(partListing)
        view.addSubview(newCompositionButton)

        newCompositionButton.addTarget(self, action: #selector(newCompositionTapped), for: .touchUpInside)

        let p = newPart()
        let vc = CompositionViewController.create(part: p)
        navigationController?.pushViewController(vc, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews() // NB: does nothing

        partListing.frame = view.bounds
    }
    
    func newCompositionTapped() {
        let p = newPart()
        let vc = CompositionViewController.create(part: p)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func newPart() -> Part {
        let i = Tweaks.assign(Tweaks.mockPartTweak)
        if mocks.indices.contains(i) {
            return mocks[i]
        }
        return Part()
    }
}

extension PartListingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let p = partFileManager.load(forIndex: indexPath.item)
        let vc = CompositionViewController.create(part: p)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PartListingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: 100)
    }
}

extension PartListingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return partFileManager.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: PartListingCell.reuseID, for: indexPath)
        let cell = aCell as? PartListingCell
        cell?.part = partFileManager.load(forIndex: indexPath.item)

        return aCell
    }
}
