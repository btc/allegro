//
//  SideMenuViewController.swift
//  allegro
//
//  Created by Priyanka Sekhar on 1/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {

    private static let leftXMargin: CGFloat = 10
    private static let leftYMargin: CGFloat = 5
    private static let rightXMargin: CGFloat = 10
    private static let rightYMargin: CGFloat = 5
    private static let labelHeight: CGFloat = 40
    private static let labelFontSize: CGFloat = 24

    fileprivate let store: PartStore
    fileprivate var audio: Audio?
    fileprivate let filename: String

    private let exportLabel: UILabel = {
        let v = UILabel()
        v.backgroundColor = .clear
        v.text = "Export"
        v.font = UIFont(name: "Montserrat-ExtraLight", size: SideMenuViewController.labelFontSize)
        v.textAlignment = .center
        return v
    }()

    private let exportButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        v.imageView?.contentMode = .scaleAspectFit
        v.showsTouchWhenHighlighted = true
        return v
    }()

    private let playLabel: UILabel = {
        let v = UILabel()
        v.backgroundColor = .clear
        v.text = "Play"
        v.font = UIFont(name: "Montserrat-ExtraLight", size: SideMenuViewController.labelFontSize)
        v.textAlignment = .center
        return v
    }()

    private let playButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        v.imageView?.contentMode = .scaleAspectFit
        v.showsTouchWhenHighlighted = true
        return v
    }()

    private let helpLabel: UILabel = {
        let v = UILabel()
        v.backgroundColor = .clear
        v.text = "Help"
        v.font = UIFont(name: "Montserrat-ExtraLight", size: SideMenuViewController.labelFontSize)
        v.textAlignment = .center
        return v
    }()

    private let helpButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "help"), for: .normal)
        v.imageView?.contentMode = .scaleAspectFit
        v.showsTouchWhenHighlighted = true
        return v
    }()

    private let keyLabel: UILabel = {
        let v = UILabel()
        v.backgroundColor = .clear
        v.text = "Key"
        v.font = UIFont(name: "Montserrat-ExtraLight", size: SideMenuViewController.labelFontSize)
        v.textAlignment = .center
        return v
    }()

    private let keyButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setTitleColor(.black, for: .normal)
        v.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 28)
        v.showsTouchWhenHighlighted = true
        v.layer.borderColor = UIColor.black.cgColor
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 3
        return v
    }()

    private let timeLabel: UILabel = {
        let v = UILabel()
        v.backgroundColor = .clear
        v.text = "Time"
        v.font = UIFont(name: "Montserrat-ExtraLight", size: SideMenuViewController.labelFontSize)
        v.textAlignment = .center
        return v
    }()
    
    private let timeButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setTitleColor(.black, for: .normal)
        v.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 30)
        v.showsTouchWhenHighlighted = true
        v.layer.borderColor = UIColor.black.cgColor
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 3
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
        view.addSubview(exportLabel)
        view.addSubview(exportButton)

        view.addSubview(playLabel)
        view.addSubview(playButton)

        view.addSubview(helpLabel)
        view.addSubview(helpButton)

        view.addSubview(keyLabel)
        view.addSubview(keyButton)

        view.addSubview(timeLabel)
        view.addSubview(timeButton)

        timeButton.addTarget(self, action: #selector(timeSignaturesTapped), for: .touchUpInside)
        keyButton.addTarget(self, action: #selector(keySignaturesTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self)
        updateUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }

    private func layoutLeftLabelButton(label: UILabel, button: UIButton, lastY: CGFloat) {

        label.frame = CGRect(x: view.bounds.minX + SideMenuViewController.leftXMargin,
                             y: lastY + SideMenuViewController.leftYMargin,
                             width: (view.bounds.width / 2) - (2 * SideMenuViewController.leftXMargin),
                             height: SideMenuViewController.labelHeight)

        button.frame = CGRect(x: view.bounds.minX + SideMenuViewController.leftXMargin,
                              y: lastY + SideMenuViewController.leftYMargin + SideMenuViewController.labelHeight,
                              width: (view.bounds.width / 2) - (2 * SideMenuViewController.leftXMargin),
                              height: (view.bounds.height / 3) - (2 * SideMenuViewController.leftYMargin) - SideMenuViewController.labelHeight )
    }

    private func layoutRightLabelButton(label: UILabel, button: UIButton, lastY: CGFloat) {

        label.frame = CGRect(x: (view.bounds.width / 2) + SideMenuViewController.leftXMargin,
                             y: lastY + SideMenuViewController.rightYMargin,
                             width: (view.bounds.width / 2) - (2 * SideMenuViewController.rightXMargin),
                             height: SideMenuViewController.labelHeight)

        button.frame = CGRect(x: (view.bounds.width / 2) + SideMenuViewController.rightXMargin,
                              y: lastY + SideMenuViewController.rightYMargin + SideMenuViewController.labelHeight,
                              width: (view.bounds.width / 2) - (2 * SideMenuViewController.rightXMargin),
                              height: (view.bounds.height / 2) - (2 * SideMenuViewController.rightYMargin) - SideMenuViewController.labelHeight )
    }

    override func viewDidLayoutSubviews() {

        layoutLeftLabelButton(label: exportLabel, button: exportButton, lastY: view.bounds.minY)
        layoutLeftLabelButton(label: playLabel, button: playButton, lastY: view.bounds.height / 3)
        layoutLeftLabelButton(label: helpLabel, button: helpButton, lastY: view.bounds.height * (2/3))

        layoutRightLabelButton(label: keyLabel, button: keyButton, lastY: view.bounds.minY)
        layoutRightLabelButton(label: timeLabel, button: timeButton, lastY: view.bounds.height / 2)

    }

    func updateUI() {
        timeButton.setTitle(store.part.timeSignature.description, for: .normal)
        keyButton.setTitle(store.part.keySignature.description, for: .normal)
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

    func helpButtonTapped() {
        // TODO
        Log.info?.message("Help Button Tapped. TODO open a help page or tutorial")
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
            return "C♯ Maj"
        case 6:
            return "F♯ Maj"
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
            return "B♭ Maj"
        case -3:
            return "E♭ Maj"
        case -4:
            return "A♭ Maj"
        case -5:
            return "D♭ Maj"
        case -6:
            return "G♭ Maj"
        case -7:
            return "C♭ Maj"
        default: // Defaults to C Major if invalid fifth used
            return "C Maj"
        }
    }
}

