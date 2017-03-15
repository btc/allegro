//
//  SideMenuViewController.swift
//  allegro
//
//  Created by Priyanka Sekhar on 1/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

//TODO: Add all menu items, link to actions, resize menu

import UIKit

class SideMenuViewController: UIViewController {

    fileprivate let store: PartStore
    fileprivate var audio: Audio?
    fileprivate let filename: String

    private let NewButton: UIView = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "new-page"), for: UIControlState.normal)
        v.imageView?.contentMode = .scaleAspectFit
        return v
    }()
    
    private let instructionsButton: UIView = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "question"), for: UIControlState.normal)
        v.imageView?.contentMode = .scaleAspectFit
        return v
    }()
    
    private let timeSignature: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setTitleColor(.black, for: .normal)
        v.titleLabel?.font = UIFont(name: DEFAULT_FONT, size: DEFAULT_TAP_TARGET_SIZE)
        return v
    }()
    
    private let keySignature: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setTitleColor(.black, for: .normal)
        v.titleLabel?.font = UIFont(name: DEFAULT_FONT, size: DEFAULT_TAP_TARGET_SIZE/2)
        return v
    }()
    
    private let exportButton: UIButton = {
        let v = UIButton()
        v.setTitle("Export", for: .normal)
        v.backgroundColor = .clear
        v.titleLabel?.textAlignment = .center
        v.setTitleColor(.black, for: .normal)
        v.titleLabel?.font = UIFont(name: DEFAULT_FONT_BOLD, size: 20)
        v.showsTouchWhenHighlighted = true
        return v
    }()

    //TODO: ppsekhar make these highlight upon selection/toggle
    private let editButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "note mode"), for: UIControlState.normal)
        v.imageView?.layer.minificationFilter = kCAFilterTrilinear
        v.showsTouchWhenHighlighted = true
        v.imageView?.contentMode = .scaleAspectFit
        return v
    }()

    private let eraseButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "eraser"), for: UIControlState.normal)
        v.showsTouchWhenHighlighted = true
        v.imageView?.contentMode = .scaleAspectFit
        return v
    }()
    
    private let playButton: UIButton = {
        let v = UIButton()
        v.setTitle(" ► ", for: .normal)
        v.backgroundColor = .clear
        v.setTitleColor(.black, for: .normal)
        v.titleLabel?.font = UIFont(name: DEFAULT_FONT, size: DEFAULT_TAP_TARGET_SIZE)
        v.showsTouchWhenHighlighted = true
        return v
    }()

    init(store: PartStore, audio: Audio?, filename: String) {
        self.store = store
        self.audio = audio
        self.filename = filename
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.allegroPurple
        view.addSubview(NewButton)
        view.addSubview(exportButton)
        view.addSubview(instructionsButton)
        view.addSubview(eraseButton)
        view.addSubview(editButton)
        view.addSubview(timeSignature)
        view.addSubview(keySignature)
        view.addSubview(playButton)
        
        eraseButton.addTarget(self, action: #selector(eraseButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        timeSignature.addTarget(self, action: #selector(timeSignaturesTapped), for: .touchUpInside)
        keySignature.addTarget(self, action: #selector(keySignaturesTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self)
        updateUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }

    override func viewDidLayoutSubviews() {
        //refernece values
        let parent = view.bounds

        let verticallyStackedButtons = [NewButton, exportButton, instructionsButton]
        let modeButtonBlocks = [editButton, eraseButton, playButton]
        let signatureButtonBlocks = [keySignature, timeSignature]

        for (i, b) in verticallyStackedButtons.enumerated() {
            let heightOfVerticallyStacked: CGFloat = parent.height / 2 / CGFloat(verticallyStackedButtons.count)
            b.frame = CGRect(x: 0,
                             y: CGFloat(i) * heightOfVerticallyStacked,
                             width: parent.width,
                             height: heightOfVerticallyStacked)
        }
        guard let verticallyStackedMaxY = verticallyStackedButtons.last?.frame.maxY else { return }

        let buttonBlocksHeight = (parent.height - verticallyStackedMaxY) / 2
        for (i, b) in modeButtonBlocks.enumerated() {
            b.frame = CGRect(x: CGFloat(i) * parent.width / CGFloat(modeButtonBlocks.count),
                             y: verticallyStackedMaxY,
                             width: parent.width / CGFloat(modeButtonBlocks.count),
                             height: buttonBlocksHeight)
        }

        for (i, b) in signatureButtonBlocks.enumerated() {
            b.frame = CGRect(x: CGFloat(i) * parent.width / CGFloat(signatureButtonBlocks.count),
                             y: verticallyStackedMaxY + buttonBlocksHeight,
                             width: parent.width / CGFloat(signatureButtonBlocks.count),
                             height: buttonBlocksHeight)
        }
        
    }

    func updateUI() {
        editButton.isSelected = store.mode == .edit
        eraseButton.isSelected = store.mode == .erase
        timeSignature.setTitle(store.part.timeSignature.description, for: .normal)
        keySignature.setTitle(store.part.keySignature.description, for: .normal)
    }
    func eraseButtonTapped() {
        store.mode = .erase
        slideMenuController()?.closeRight()
    }

    func editButtonTapped() {
        store.mode = .edit
        slideMenuController()?.closeRight()
    }
    
    func timeSignaturesTapped() {
        let vc = TimeSignatureViewController(store: store)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func keySignaturesTapped() {
        let vc = KeySignatureViewController(store: store)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func playButtonTapped() {
        // Don't play anything if the measure is empty
        if store.part.measures[store.currentMeasure].notes.count > 0 {
            audio?.playFromCurrentMeasure(part: store.part, measure: store.currentMeasure) { currentMeasure in
                self.store.currentMeasure = currentMeasure
            }
        }
        slideMenuController()?.closeRight()
    }

    func exportButtonTapped() {
        let part = PartFileManager.load(filename: filename)
        let xml = MusicXMLParser.generate(part: part).xml

        // set up activity view controller
        let items = [ xml ]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // present the view controller
        present(activityViewController, animated: true, completion: nil)
    }
}

extension SideMenuViewController: PartStoreObserver {
    func partStoreChanged() {
        updateUI()
    }
}

// descriptions for the side menu
private extension Key {
    var description: String {
        switch fifths {
        case 7:
            return "C♯"
        case 6:
            return "F♯"
        case 5:
            return "B Maj"
        case 4:
            return "E Maj"
        case 3:
            return "A Maj"
        case 2:
            return "D Maj"
        case 1:
            return "G Maj"
        case 0:
            return "C Maj"
        case -1:
            return "F Maj"
        case -2:
            return "B♭"
        case -3:
            return "E♭"
        case -4:
            return "A♭"
        case -5:
            return "D♭"
        case -6:
            return "G♭"
        case -7:
            return "C♭"
        default: // Defaults to C Major if invalid fifth used
            return "C"
        }
    }
}

