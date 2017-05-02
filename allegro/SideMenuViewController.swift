//
//  SideMenuViewController.swift
//  allegro
//
//  Created by Priyanka Sekhar on 1/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit
import Rational

class SideMenuViewController: UIViewController {

    private static let labelHeight: CGFloat = 40
    private static let labelFontSize: CGFloat = 24
    private static let xmargin: CGFloat = 10
    private static let ymargin: CGFloat = 10
    private static let midmargin: CGFloat = 14
    private static let padding: CGFloat = 2

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
    
    private let keyButton: KeySignatureButton = {
        let v = KeySignatureButton()
        v.backgroundColor = .clear
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
    
    private let tempoLabel: UILabel = {
        let v = UILabel()
        v.backgroundColor = .clear
        v.text = "Tempo"
        v.font = UIFont(name: "Montserrat-ExtraLight", size: SideMenuViewController.labelFontSize)
        v.textAlignment = .center
        return v
    }()

    private let tempoButton: UIButton = {
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
        
        view.addSubview(tempoLabel)
        view.addSubview(tempoButton)


        timeButton.addTarget(self, action: #selector(timeSignaturesTapped), for: .touchUpInside)
        keyButton.addTarget(self, action: #selector(keySignaturesTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        tempoButton.addTarget(self, action: #selector(tempoButtonTapped), for: .touchUpInside)

    }

    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self)
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func layoutLabelsButtons(label: UILabel, button: UIButton, lastY: CGFloat, lastX: CGFloat) {
        
        label.frame = CGRect(x: lastX,
                             y: lastY + SideMenuViewController.padding,
                             width: (view.bounds.width / 2) - (SideMenuViewController.midmargin / 2) - SideMenuViewController.xmargin -
                                (SideMenuViewController.padding / 2),
                             height: SideMenuViewController.labelHeight
        )
        
        button.frame = CGRect(x: lastX,
                              y: lastY + SideMenuViewController.padding + SideMenuViewController.labelHeight,
                              width: (view.bounds.width / 2) - (SideMenuViewController.midmargin / 2) - SideMenuViewController.xmargin -
                                (SideMenuViewController.padding / 2),
                              height: ((view.bounds.height - (SideMenuViewController.ymargin * 2)) / 3) - (SideMenuViewController.padding * 2) -
                                SideMenuViewController.labelHeight
        )
    }

    override func viewDidLayoutSubviews() {

        let height = (view.bounds.height - (SideMenuViewController.ymargin * 2)) / 3
        let start = view.bounds.minY + SideMenuViewController.ymargin
        let leftX = view.bounds.minX + SideMenuViewController.xmargin + SideMenuViewController.padding
        let rightX = (view.bounds.width / 2) + (SideMenuViewController.midmargin / 2)
        
        // left side
        layoutLabelsButtons(label: exportLabel, button: exportButton, lastY: start, lastX: leftX)
        layoutLabelsButtons(label: playLabel, button: playButton, lastY: start + height, lastX: leftX)
        layoutLabelsButtons(label: helpLabel, button: helpButton, lastY: start + height * 2, lastX: leftX)
        
        // right side
        layoutLabelsButtons(label: keyLabel, button: keyButton, lastY: start, lastX: rightX)
        layoutLabelsButtons(label: tempoLabel, button: tempoButton, lastY: start + height, lastX: rightX)
        layoutLabelsButtons(label: timeLabel, button: timeButton, lastY: start + height * 2, lastX: rightX)
    }

    func updateUI() {
        timeButton.setTitle(store.part.timeSignature.description, for: .normal)
        tempoButton.setTitle(store.part.tempo.description, for: .normal)
        keyButton.keySigView.key = store.part.keySignature
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
        audio?.playFromCurrentMeasure(part: store.part, beat: store.part.timeSignature.denominator, measure: store.currentMeasure) {
            (currentMeasure: Int, currentNotePosition: Rational) in
            self.store.currentMeasure = currentMeasure
            self.store.currentNotePosition = currentNotePosition
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

    func helpButtonTapped() {
        let vc = HelpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tempoButtonTapped() {
        let vc = TempoViewController(store: store)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SideMenuViewController: PartStoreObserver {
    func partStoreChanged() {
        updateUI()
    }
}

// adds KeySignatureView subview to display image of Key
fileprivate class KeySignatureButton: UIButton {
    var keySigView: KeySignatureView = {
        let v = KeySignatureView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(keySigView)
        keySigView.frame = bounds
    }
}

