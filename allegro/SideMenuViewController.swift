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
    
    private let instructionsButton: UIView = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "help"), for: .normal)
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
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        v.showsTouchWhenHighlighted = true
        return v
    }()

    private let playButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "play"), for: .normal)
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
        view.addSubview(exportButton)
        view.addSubview(instructionsButton)
        view.addSubview(timeSignature)
        view.addSubview(keySignature)
        view.addSubview(playButton)

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

        let verticallyStackedButtons = [exportButton, instructionsButton]
        let modeButtonBlocks = [playButton]
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
        timeSignature.setTitle(store.part.timeSignature.description, for: .normal)
        keySignature.setTitle(store.part.keySignature.description, for: .normal)
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
        audio?.playMeasure(part: store.part, measure: store.currentMeasure)
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

