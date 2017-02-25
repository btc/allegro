//
//  KeySignatureViewController.swift
//  allegro
//
//  Created by Priyanka Sekhar on 2/1/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class KeySignatureViewController: UIViewController {
    
    fileprivate let store: PartStore
    
    private let backButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setTitleColor(.allegroPurple, for: .normal)
        v.setTitle("Key Sig: Back", for: UIControlState.normal)
        return v
    }()
    
    private let sharpButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "sharp"), for: .normal)
        v.imageView?.contentMode = .scaleAspectFit
        return v
    }()
    
    private let flatButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "flat"), for: .normal)
        v.imageView?.contentMode = .scaleAspectFit
        return v
    }()
    
    // This is a placeholder for the functionality in the demo where sharps are added to the screen as needed
    private let keySigLabel: UILabel = {
        let v = UILabel()
        v.textColor = .gray
        v.adjustsFontSizeToFitWidth = true
        return v
    }()

    init(store: PartStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self)
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        view.addSubview(backButton)
        view.addSubview(sharpButton)
        view.addSubview(flatButton)
        view.addSubview(keySigLabel)
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        sharpButton.addTarget(self, action: #selector(sharpButtonTapped), for: .touchUpInside)
        flatButton.addTarget(self, action: #selector(flatButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews() // NB: does nothing
        
        let parent = view.bounds
        
        let buttonH: CGFloat = DEFAULT_TAP_TARGET_SIZE
        let buttonW = buttonH * 3 // is an educated guess
        
        // All placeholder locations
        // TODO: Make visually pleasing 
        backButton.frame = CGRect(x: parent.width - buttonW,
                                  y: parent.height - buttonH,
                                  width: buttonW,
                                  height: buttonH)
        
        sharpButton.frame = CGRect(x: DEFAULT_MARGIN_PTS,
                                   y: DEFAULT_MARGIN_PTS,
                                   width: DEFAULT_TAP_TARGET_SIZE,
                                   height: DEFAULT_TAP_TARGET_SIZE)
        
        flatButton.frame = CGRect(x: DEFAULT_MARGIN_PTS,
                                   y: parent.height - DEFAULT_TAP_TARGET_SIZE - DEFAULT_MARGIN_PTS,
                                   width: DEFAULT_TAP_TARGET_SIZE,
                                   height: DEFAULT_TAP_TARGET_SIZE)
        
        keySigLabel.frame = CGRect(x: parent.width/2,
                                   y: parent.height/2,
                                   width: DEFAULT_TAP_TARGET_SIZE,
                                   height: DEFAULT_TAP_TARGET_SIZE)
        
    }
    
    func updateUI() {
        // TODO: Modify to reveal sharps and flat on screen as appropriate
        keySigLabel.text = store.part.keySignature.keySigString
    }
    
    func backButtonTapped() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func sharpButtonTapped() {
        let curSig = store.part.keySignature
        if curSig.fifths < Key.maxFifth {
            let newKeySig = Key(mode: .major, fifths: curSig.fifths + 1)
            store.part.setKeySignature(keySignature: newKeySig)
        }
        updateUI()
    }
    
    func flatButtonTapped() {
        let curSig = store.part.keySignature
        if curSig.fifths > Key.minFifth {
            let newKeySig = Key(mode: .major, fifths: curSig.fifths - 1)
            store.part.setKeySignature(keySignature: newKeySig)
        }
        updateUI()
    }
    
}

extension KeySignatureViewController: PartStoreObserver {
    func partStoreChanged() {
        updateUI()
    }
}
