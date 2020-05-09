//
//  HomeMenuViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class PartListingViewController: UIViewController, MGSwipeTableCellDelegate {
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

    fileprivate let partListing: UITableView = {
        let v = UITableView(frame: .zero, style: UITableView.Style.plain)
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

        let tutorialButton = UIBarButtonItem(title: "Tutorial", style: .plain, target: self, action: #selector(tutorialTapped))
        tutorialButton.tintColor = .allegroPurple

        // TUTORIAL DISABLED UNTIL FURTHER NOTICE
        // navigationController?.navigationBar.topItem?.leftBarButtonItem = tutorialButton

        let newButton = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(newCompositionTapped))
        newButton.tintColor = .allegroPurple
        navigationController?.navigationBar.topItem?.rightBarButtonItem = newButton
        navigationController?.navigationBar.topItem?.title = "Parts"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        DispatchQueue.global(qos: .userInteractive).async {
            self.files = PartFileManager.files // look for files from disk. files are already sorted by modified time
            DispatchQueue.main.async {
                self.partListing.reloadData() // must happen on main thread
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews() // NB: does nothing
        partListing.frame = view.bounds
    }

    @objc func tutorialTapped() {
        navigationController?.pushViewController(TutorialViewController(), animated: true)
    }

    @objc func newCompositionTapped() {
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

        c.delegate = self

        DispatchQueue.global(qos: .userInteractive).async {
            let part = PartFileManager.load(filename: filename)
            DispatchQueue.main.async {
                c.part = part
            }
        }

        let deleteButtonLeft = MGSwipeButton(title: "Delete", backgroundColor: .red)
        let deleteButtonRight = MGSwipeButton(title: "Delete", backgroundColor: .red)

        let renameButtonLeft = MGSwipeButton(title: "Rename", backgroundColor: .allegroPurple)
        let renameButtonRight = MGSwipeButton(title: "Rename", backgroundColor: .allegroPurple)

        c.leftButtons = [deleteButtonLeft, renameButtonLeft]
        c.leftSwipeSettings.transition = .border
        c.rightButtons = [deleteButtonRight, renameButtonRight]
        c.rightSwipeSettings.transition = .border
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {

        guard let indexPath = partListing.indexPath(for: cell) else { return true }

        switch index {
        case 0:
            deleteCell(indexPath: indexPath)
            return false // dont autohide
        case 1:
            renameCell(indexPath: indexPath)
        default:
            break
        }

        return true
    }

    // set the part's title, this doesn't rename the file on disk!
    private func renameCell(indexPath: IndexPath) {

        let filename = self.files[indexPath.item].filename
        let part = PartFileManager.load(filename: filename)

        // open an alert
        let alert = UIAlertController(title: "Part Title", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField: UITextField) -> Void in
            if let title = part.title {
                textField.text = title
            } else {
                textField.placeholder = "Enter Part Title"
            }
        }

        let setTitle = { (action: UIAlertAction) -> Void in
            let newTitle = alert.textFields?[0].text
            part.title = newTitle
            PartFileManager.save(part: part, as: filename)
            self.partListing.reloadData()
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: setTitle))

        self.present(alert, animated: true, completion: nil)
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
