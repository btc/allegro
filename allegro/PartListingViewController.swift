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
        v.backgroundColor = .allegroPurple
        v.setTitle(Strings.NEW, for: .normal)
        return v
    }()

    private let partListing: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.register(PartListingCell.self, forCellWithReuseIdentifier: PartListingCell.reuseID)
        v.backgroundColor = .white
        return v
    }()

    fileprivate var files = [(filename: String, modified: Date)]() {
        didSet {
            partListing.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        partListing.dataSource = self
        partListing.delegate = self

        view.backgroundColor = UIColor.white

        view.addSubview(partListing)
        view.addSubview(newCompositionButton)

        newCompositionButton.addTarget(self, action: #selector(newCompositionTapped), for: .touchUpInside)

        var part: Part
        var filename: String
        if let name = PartFileManager.mostRecentFilename() {
            // use this filename
            part = PartFileManager.load(filename: name)
            filename = name
        } else {
            // use a new part
            part = newPart()
            filename = PartFileManager.nextFilename()
        }

        let store = PartStore(part: part)

        let vc = CompositionViewController.create(store: store, filename: filename)
        navigationController?.pushViewController(vc, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        // look for files from disk. files are already sorted by modified time
        DispatchQueue.main.async { [weak self] in
            self?.files = PartFileManager.files
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews() // NB: does nothing

        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 50

        newCompositionButton.frame = CGRect(x: view.bounds.width - buttonWidth - DEFAULT_MARGIN_PTS,
                                            y: DEFAULT_MARGIN_PTS,
                                            width: buttonWidth,
                                            height: buttonHeight)

        partListing.frame = CGRect(x: 0,
                                   y: newCompositionButton.frame.maxY + DEFAULT_MARGIN_PTS,
                                   width: view.bounds.width,
                                   height: view.bounds.height - newCompositionButton.frame.height - 2 * DEFAULT_MARGIN_PTS)
    }

    func newCompositionTapped() {
        let store = PartStore(part: newPart())
        let vc = CompositionViewController.create(store: store, filename: PartFileManager.nextFilename())
        navigationController?.pushViewController(vc, animated: true)
    }

    // make a new part or use a mock from tweaks
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

        let filename = PartFileManager.files[indexPath.item].filename
        let part = PartFileManager.load(filename: filename)

        let partStore = PartStore(part: part)

        let vc = CompositionViewController.create(store: partStore, filename: filename)
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
        return files.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: PartListingCell.reuseID, for: indexPath)
        let cell = aCell as? PartListingCell

        let (filename, modified) = files[indexPath.item]
        cell?.filename = filename
        cell?.part = PartFileManager.load(filename: filename)
        cell?.modified = modified

        return aCell
    }
}
