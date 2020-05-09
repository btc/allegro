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
    
    private let sharpButton: UIButton = {
        let v = UIButton()
        v.setTitleColor(.black, for: .normal)
        v.setTitleColor(.lightGray, for: .disabled)
        v.setTitle("♯", for: UIControl.State.normal)
        v.titleLabel?.font = UIFont(name: "DejaVuSans", size: 64)
        v.layer.borderColor = UIColor.black.cgColor
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 5
        v.showsTouchWhenHighlighted = true
        return v
    }()
    
    private let flatButton: UIButton = {
        let v = UIButton()
        v.setTitleColor(.black, for: .normal)
        v.setTitleColor(.lightGray, for: .disabled)
        v.setTitle("♭", for: UIControl.State.normal)
        v.titleLabel?.font = UIFont(name: "DejaVuSans", size: 64)
        v.layer.borderColor = UIColor.black.cgColor
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 5
        v.showsTouchWhenHighlighted = true
        return v
    }()
    
    // subclass of UIImageView that handles which image to set based on Key Signature
    private let keySignatureView: KeySignatureView = {
        let v = KeySignatureView()
        v.contentMode = .scaleAspectFit
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
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        view.addSubview(sharpButton)
        view.addSubview(flatButton)
        view.addSubview(keySignatureView)
        
        sharpButton.addTarget(self, action: #selector(sharpButtonTapped), for: .touchUpInside)
        flatButton.addTarget(self, action: #selector(flatButtonTapped), for: .touchUpInside)
        
        let keySig = store.part.keySignature
        keySignatureView.key = keySig
        navigationController?.navigationBar.topItem?.title = "Key Signature: \(keySig.description)"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews() // NB: does nothing
        let navbarHeight = navigationController?.navigationBar.frame.height ?? DEFAULT_MARGIN_PTS
        let parent = view.bounds
        
        sharpButton.frame = CGRect(x: (3/4) * parent.width + DEFAULT_MARGIN_PTS,
                                   y: parent.minY + navbarHeight + DEFAULT_MARGIN_PTS,
                                   width: parent.width / 4 - (2 * DEFAULT_MARGIN_PTS),
                                   height: (parent.height - navbarHeight - 3 * DEFAULT_MARGIN_PTS) / 2)
        
        flatButton.frame = CGRect(x: (3/4) * parent.width + DEFAULT_MARGIN_PTS,
                                  y: sharpButton.frame.maxY + DEFAULT_MARGIN_PTS,
                                  width: parent.width / 4 - (2 * DEFAULT_MARGIN_PTS),
                                  height: (parent.height - navbarHeight - 3 * DEFAULT_MARGIN_PTS) / 2)
        
        keySignatureView.frame = CGRect(x: parent.minX + DEFAULT_MARGIN_PTS,
                                        y: parent.minY + navbarHeight + DEFAULT_MARGIN_PTS,
                                        width: (3/4) * parent.width,
                                        height: parent.height - navbarHeight - (2 * DEFAULT_MARGIN_PTS))
        
    }
    
    private func enableButton(button: UIButton) {
        button.isEnabled = true
        button.showsTouchWhenHighlighted = true
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    private func disableButton(button: UIButton) {
        button.isEnabled = false
        button.showsTouchWhenHighlighted = false
        button.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    fileprivate func updateUI() {
        let keySig = store.part.keySignature
        keySignatureView.key = keySig
        navigationItem.title = "Key Signature: \(keySig.description)"
        
        if keySig.fifths >= Key.maxFifth {
            disableButton(button: sharpButton)
        } else {
            enableButton(button: sharpButton)
        }
        
        if keySig.fifths <= Key.minFifth {
            disableButton(button: flatButton)
        } else {
            enableButton(button: flatButton)
        }
    }
    
    @objc func sharpButtonTapped() {
        store.setKeySignature(keySignature: store.part.keySignature.successor)
    }
    
    @objc func flatButtonTapped() {
        store.setKeySignature(keySignature: store.part.keySignature.predecessor)
    }
    
}

extension KeySignatureViewController: PartStoreObserver {
    func partStoreChanged() {
        updateUI()
    }
}

// Will be changed to properly arranged labels 
private extension Key {
    var description: String {
        switch fifths {
        case 7:
            return "C♯ Major"
        case 6:
            return "F♯ Major"
        case 5:
            return "B Major"
        case 4:
            return "E Major"
        case 3:
            return "A Major"
        case 2:
            return "D Major"
        case 1:
            return "G Major"
        case 0:
            return "C Major"
        case -1:
            return "F Major"
        case -2:
            return "B♭ Major"
        case -3:
            return "E♭ Major"
        case -4:
            return "A♭ Major"
        case -5:
            return "D♭ Major"
        case -6:
            return "G♭ Major"
        case -7:
            return "C♭ Major"
        default: // Defaults to C Major if invalid fifth used
            return "C Major"
        }
    }
}
