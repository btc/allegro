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
    
    private let NavigationLabel: UIView = {
        let v = UILabel() // TODO: ppsekhar make this a button
        v.text = "Navigation"
        v.textAlignment = .left
        v.textColor = .black
        v.font = UIFont(name: DEFAULT_FONT, size: 20)
        return v
    }()

    private let MenuOptions: UIView = {
        let v = UILabel()
        v.text = "Placeholder menu"
        v.textAlignment = .center
        v.textColor = .white
        v.font = UIFont(name: DEFAULT_FONT_BOLD, size: 20)
        return v
    }()
    
    private let Home: UIView = {
        let v = UILabel() // TODO: ppsekhar make this a button
        v.text = "Home"
        v.textAlignment = .center
        v.textColor = .white
        v.font = UIFont(name: DEFAULT_FONT_BOLD, size: 20)
        return v
    }()
    
    private let Export: UIView = {
        let v = UILabel() // TODO: ppsekhar make this a button
        v.text = "Export"
        v.textAlignment = .center
        v.textColor = .white
        v.font = UIFont(name: DEFAULT_FONT_BOLD, size: 20)
        return v
    }()

    private let editButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .lightGray
        v.setTitle("Edit", for: .normal)
        v.titleLabel?.textColor = .black
        return v
    }()

    private let eraseButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .lightGray
        v.titleLabel?.textAlignment = .center
        v.setTitle("Erase", for: .normal)
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
        
        view.backgroundColor = UIColor.allegroPurple
        view.addSubview(MenuOptions)
        view.addSubview(Home)
        view.addSubview(Export)
        view.addSubview(eraseButton)
        view.addSubview(editButton)
        
        eraseButton.addTarget(self, action: #selector(eraseButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)

    }

    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }

    override func viewDidLayoutSubviews() {
        let parent = view.bounds
        let centerX = parent.width / 2
        let centerY = parent.height / 2
        
        let titleH = parent.height / 2 - 2 * DEFAULT_MARGIN_PTS
        let titleW = titleH * THE_GOLDEN_RATIO
        
        MenuOptions.frame = CGRect(x: centerX - titleW / 2,
                            y: DEFAULT_MARGIN_PTS,
                            width: titleW,
                            height: titleH)

        editButton.frame = CGRect(x: 0,
                                   y: centerY,
                                   width: parent.width / 2,
                                   height: DEFAULT_TAP_TARGET_SIZE)

        eraseButton.frame = CGRect(x: parent.width / 2,
                            y: centerY,
                            width: parent.width / 2,
                            height: DEFAULT_TAP_TARGET_SIZE)
    }
    
    func eraseButtonTapped() {
        store.mode = .erase
    }

    func editButtonTapped() {
        store.mode = .edit
    }
}

extension SideMenuViewController: PartStoreObserver {
    func partStoreChanged() {
        // TODO: update the button states to reflect the selected mode
        // NB: By convention, don't change the toggle view until updated state information is received from the source of truth.
        // switch store.mode { ...
    }
}
