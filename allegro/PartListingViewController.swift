//
//  HomeMenuViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import SwipyCell
import UIKit

class PartListingViewController: UIViewController {

    fileprivate static let deletionView = UIImageView(image: #imageLiteral(resourceName: "whole"))

    private let newCompositionButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .allegroPurple
        v.setTitle(Strings.NEW, for: .normal)
        return v
    }()

    fileprivate let partListing: UITableView = {
        let v = UITableView(frame: .zero, style: UITableViewStyle.plain)
        v.backgroundColor = .white
        v.register(PartListingCell.self, forCellReuseIdentifier: PartListingCell.reuseID)
        return v
    }()

    fileprivate var files = [(filename: String, modified: Date)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        partListing.dataSource = self
        partListing.delegate = self

        view.backgroundColor = UIColor.white

        view.addSubview(partListing)
        view.addSubview(newCompositionButton) // on top of part listing

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
        DispatchQueue.global(qos: .userInteractive).async {
            self.files = PartFileManager.files // look for files from disk. files are already sorted by modified time
            DispatchQueue.main.async {
                self.partListing.reloadData() // must happen on main thread
            }
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

        partListing.frame = view.bounds
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

extension PartListingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: PartListingCell.reuseID, for: indexPath)
    }
}

extension PartListingViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let c = cell as? PartListingCell else { return }

        let (filename, modified) = files[indexPath.item]
        c.filename = filename
        c.modified = modified

        DispatchQueue.global(qos: .userInteractive).async {
            let part = PartFileManager.load(filename: filename)
            DispatchQueue.main.async {
                c.part = part
            }
        }


        (cell as? SwipyCell)?.setSwipeGesture(type(of: self).deletionView,
                                              color: .red,
                                              mode: .exit,
                                              state: .state1,
                                              completionHandler: deleteCell)
    }

    private func deleteCell(cell: SwipyCell, state: SwipyCellState, mode: SwipyCellMode) {

        // TODO(nlele): uncomment the following lines when deletion is implemented.

        // guard let indexPath = partListing.indexPath(for: cell) else { return }
        // partListing.deleteRows(at: [indexPath], with: .fade)

        DispatchQueue.global(qos: .background).async {
            // TODO(nlele): delete part file here
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filename = PartFileManager.files[indexPath.item].filename
        let part = PartFileManager.load(filename: filename)

        let partStore = PartStore(part: part)

        let vc = CompositionViewController.create(store: partStore, filename: filename)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PartListingCell.height
    }
}
