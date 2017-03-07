//
//  HomeMenuViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class PartListingViewController: UIViewController {
    let audio: Audio?
    
    fileprivate static let deletionLabel: UILabel = {
        let v = UILabel()
        v.text = "Delete"
        v.font = UIFont(name: DEFAULT_FONT, size: 14)
        v.textColor = .white
        v.textAlignment = .right
        v.sizeToFit()
        return v
    }()

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
    
    init(audio: Audio?) {
        self.audio = audio
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
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

        let vc = CompositionViewController.create(store: store, audio: audio, filename: filename)
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
                                            y: 15,
                                            width: buttonWidth,
                                            height: buttonHeight)

        partListing.frame = view.bounds
    }

    func newCompositionTapped() {
        let store = PartStore(part: newPart())
        let vc = CompositionViewController.create(store: store, audio: audio, filename: PartFileManager.nextFilename())
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

        let deleteButton = MGSwipeButton(title: "Delete", backgroundColor: .red) {
            (sender: MGSwipeTableCell!) -> Bool in
            self.deleteCell(indexPath: indexPath)
            return true
        }

        let moreButton = MGSwipeButton(title: "More", backgroundColor: .lightGray) {
            (sender: MGSwipeTableCell!) -> Bool in
            // TODO more button callback
            Log.info?.message("More on cell with index: \(indexPath.item)")
            return true
        }

        c.leftButtons = [deleteButton, moreButton]
        c.rightSwipeSettings.transition = .border
    }

    private func deleteCell(indexPath: IndexPath) {

        DispatchQueue.global(qos: .background).async {
            // delete the file
            let filename = self.files[indexPath.item].filename
            PartFileManager.delete(filename: filename)

            // update cached files
            self.files = PartFileManager.files

            // delete the row
            DispatchQueue.main.async {
                self.partListing.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filename = PartFileManager.files[indexPath.item].filename
        let part = PartFileManager.load(filename: filename)

        let partStore = PartStore(part: part)

        let vc = CompositionViewController.create(store: partStore, audio: audio, filename: filename)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PartListingCell.height
    }
}
