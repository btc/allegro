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

    init(store: PartStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        view.addSubview(backButton)
        view.addSubview(sharpButton)
        view.addSubview(flatButton)
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
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
        
    }
    
    func backButtonTapped() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func sharpButtonTapped() {
        print("sharp button tapped")
        let curSig = store.part.keySignature
        if curSig.fifths < Key.maxFifth {
            let newKeySig = Key(mode: .major, fifths: curSig.fifths + 1)
            store.part.setKeySignature(keySignature: newKeySig)
        }
    }
    
}
