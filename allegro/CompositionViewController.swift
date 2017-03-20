//
//  CompositionViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit
import Rational
import SlideMenuControllerSwift

class CompositionViewController: UIViewController {

    fileprivate let noteSelectorMenu: NoteSelectorMenu = {
        let v = NoteSelectorMenu()
        return v
    }()
    
    fileprivate let screenCover: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.isHidden = true
        return v
    }()

    fileprivate let modeToggle: CompositionModeToggleButton = {
        let v = CompositionModeToggleButton()
        return v
    }()
    
    private let menuIndicator: UIView = {
        let v = UIButton()
        v.setImage(#imageLiteral(resourceName: "arrow"), for: UIControlState.normal)
        v.imageView?.contentMode = .scaleAspectFit
        v.backgroundColor = .clear
        return v
    }()

    fileprivate let measureNumberLabel: UILabel = {
        let v = UILabel()
        v.textColor = .allegroGray
        v.font = UIFont(name: DEFAULT_FONT, size: 14) // TODO standardize size
        return v
    }()

    fileprivate let store: PartStore

    fileprivate let measureViewCollection: MeasureCollectionViewController

    fileprivate let overviewView: UIView

    fileprivate let pinchRecognizer: UIPinchGestureRecognizer = {
        let gr = UIPinchGestureRecognizer()
        return gr
    }()

    fileprivate let audio: Audio?

    // observer that saves the part to disk after every change
    private let partSaver: PartSaver

    //RHSide menu disabled for alpha
    static func create(store: PartStore, audio: Audio?, filename: String) -> UIViewController {
        let vc = CompositionViewController(store: store, audio: audio, filename: filename)
        let sideMenuVC = SideMenuViewController(store: store, audio: audio, filename: filename)

        // NB(btc): The way the library provides customization (static options) makes it so that it's only feasible to have
        // one sidemenu controller in the project. If we decide we need another, with different options, fork the repo
        // and move the options to the instance of the SideMenuViewController.
        SlideMenuOptions.animationDuration = 0.07 // seconds

        let container = SlideMenuController(mainViewController: vc, rightMenuViewController: sideMenuVC)
        return container
    }

    private init(store: PartStore, audio: Audio?, filename: String) {
        self.store = store
        self.audio = audio
        self.partSaver = PartSaver(partStore: store, filename: filename)

        measureViewCollection = MeasureCollectionViewController(store: store)
        overviewView = OverviewView(store: store)

        super.init(nibName: nil, bundle: nil)

        view.addGestureRecognizer(pinchRecognizer)
        pinchRecognizer.addTarget(self, action: #selector(pinched))

        modeToggle.store = store
        noteSelectorMenu.store = store

        store.subscribe(self)
        audio?.subscribe(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        addChildViewController(measureViewCollection)

        view.addSubview(measureViewCollection.view)
        view.addSubview(noteSelectorMenu)
        view.addSubview(modeToggle)
        view.addSubview(measureNumberLabel)
        //view.addSubview(menuIndicator) Not being used in Alpha
        view.addSubview(overviewView)
        view.addSubview(screenCover)
        
        screenCover.addTarget(self, action: #selector(screenCoverTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        audio?.start()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        let leftMenuWidth = DEFAULT_TAP_TARGET_SIZE
        let toggleHeight = DEFAULT_TAP_TARGET_SIZE
        // occupies (most of) the left side of the screen
        noteSelectorMenu.frame = CGRect(x: 0,
                                        y: 0,
                                        width: leftMenuWidth,
                                        height: view.bounds.height - toggleHeight)

        modeToggle.frame = CGRect(x: 0,
                                  y: noteSelectorMenu.frame.maxY,
                                  width: leftMenuWidth,
                                  height: toggleHeight)
                // occupies space to the right of the menu
        
        measureViewCollection.view.frame = CGRect(x: noteSelectorMenu.frame.maxX,
                                                  y: 0,
                                                  width: view.bounds.width - noteSelectorMenu.frame.width,
                                                  height: view.bounds.height)
        
        let buttonW = view.bounds.width/30
        
        //y value non zero to shift arrow off center and prevent overlap with center staff line
        //TODO: Potentially find a better way of shifting
        menuIndicator.frame = CGRect(x: view.bounds.width - buttonW,
                                     y: -DEFAULT_MARGIN_PTS/2,
                                     width: buttonW,
                                     height: view.bounds.height)

        overviewView.frame = view.bounds

        measureNumberLabel.frame.origin = CGPoint(x: view.bounds.width - measureNumberLabel.bounds.width - DEFAULT_MARGIN_PTS,
                                                  y: view.bounds.height - DEFAULT_MARGIN_PTS - measureNumberLabel.bounds.height)
        
        screenCover.frame = view.bounds
    }
    
    func screenCoverTapped() {
        audio?.stop()
    }

    func pinched() {
        store.view = .overview
    }
}

extension CompositionViewController: PartStoreObserver {
    func partStoreChanged() {
        overviewView.isHidden = store.view != .overview

        measureNumberLabel.text = "\(store.currentMeasure + 1)/\(store.measureCount)"
        measureNumberLabel.sizeToFit()
    }

    func noteAdded(in measure: Int, at position: Rational) {
        audio?.playNote(part: store.part, measure: measure, position: position)
    }

    func noteModified(in measure: Int, at position: Rational) {
        audio?.playNote(part: store.part, measure: measure, position: position)
    }
}

extension CompositionViewController: AudioObserver {
    func audioChanged() {
        guard audio?.isPlaying() == true else {
            screenCover.isHidden = true
            return
        }
        screenCover.isHidden = false
    }
    
}
