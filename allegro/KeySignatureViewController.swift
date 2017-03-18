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
        v.backgroundColor = .clear
        v.setTitleColor(.black, for: .normal)
        v.setTitle("♯", for: UIControlState.normal)
        v.titleLabel?.font = UIFont(name: "DejaVuSans", size: 60)
        return v
    }()
    
    private let flatButton: UIButton = {
        let v = UIButton()
        v.setTitleColor(.black, for: .normal)
        v.setTitle("♭", for: UIControlState.normal)
        v.titleLabel?.font = UIFont(name: "DejaVuSans", size: 60)
        return v
    }()
    
    // This is a placeholder for the functionality in the demo where sharps are added to the screen as needed
    private let keySigLabel: UILabel = {
        let v = UILabel()
        v.textColor = .gray
        v.adjustsFontSizeToFitWidth = true
        return v
    }()
    
    private let keySignatureView: KeySignatureView = {
        let v = KeySignatureView()
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
        navigationController?.navigationBar.topItem?.title = "Key Signature: \(keySig.description)"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews() // NB: does nothing
        let navbarHeight = navigationController?.navigationBar.frame.height ?? DEFAULT_MARGIN_PTS
        let parent = view.bounds
        
        // All placeholder locations
        // TODO: Make visually pleasing
        
        sharpButton.frame = CGRect(x: parent.width - DEFAULT_TAP_TARGET_SIZE - DEFAULT_MARGIN_PTS,
                                   y: parent.minY + navbarHeight + DEFAULT_MARGIN_PTS,
                                   width: DEFAULT_TAP_TARGET_SIZE,
                                   height: DEFAULT_TAP_TARGET_SIZE)
        
        flatButton.frame = CGRect(x: parent.width - DEFAULT_TAP_TARGET_SIZE - DEFAULT_MARGIN_PTS,
                                  y: parent.height - DEFAULT_TAP_TARGET_SIZE - DEFAULT_MARGIN_PTS,
                                  width: DEFAULT_TAP_TARGET_SIZE,
                                  height: DEFAULT_TAP_TARGET_SIZE)
        
        keySignatureView.frame = CGRect(x: parent.minX + DEFAULT_MARGIN_PTS,
                                        y: parent.minY + navbarHeight + DEFAULT_MARGIN_PTS,
                                        width: parent.width / 2,
                                        height: parent.height - navbarHeight - (2 * DEFAULT_MARGIN_PTS))
        
    }
    
    func updateUI() {
        // TODO: Modify to reveal sharps and flat on screen as appropriate
        let keySig = store.part.keySignature
        keySignatureView.key = keySig
        keySigLabel.text = keySig.description
        navigationItem.title = "Key Signature: \(keySig.description)"
    }
    
    func sharpButtonTapped() {
        store.setKeySignature(keySignature: store.part.keySignature.successor)
    }
    
    func flatButtonTapped() {
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
