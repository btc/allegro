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
    
    //TODO: Fix button sizing to make each one consistent
    private let NavigationLabel: UIView = {
        let v = UILabel()
        v.text = "Navigation"
        v.textAlignment = .left
        v.textColor = .black
        v.font = UIFont(name: DEFAULT_FONT, size: 20)
        return v
    }()
    
    private let modeLabel: UIView = {
        let v = UILabel()
        v.text = "Mode"
        v.textAlignment = .left
        v.textColor = .black
        v.font = UIFont(name: DEFAULT_FONT, size: 20)
        return v
    }()
    
    private let signaturesLabel: UIView = {
        let v = UILabel()
        v.text = "Signatures"
        v.textAlignment = .left
        v.textColor = .black
        v.font = UIFont(name: DEFAULT_FONT, size: 20)
        return v
    }()


    private let NewButton: UIView = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "new-page"), for: UIControlState.normal)
        return v
    }()
    
    private let saveButton: UIView = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "save"), for: UIControlState.normal)
        return v
    }()
    
    private let instructionsButton: UIView = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "question"), for: UIControlState.normal)
        return v
    }()
    
    private let timeSignature: UIView = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "timesig34"), for: UIControlState.normal)
        return v
    }()
    
    private let keySignature: UIView = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "C# major"), for: UIControlState.normal)
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

    //TODO: ppsekhar make these highlight upon selection/toggle
    private let editButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "note mode"), for: UIControlState.normal)
        v.imageView?.layer.minificationFilter = kCAFilterTrilinear
        return v
    }()

    private let eraseButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "eraser"), for: UIControlState.normal)
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
        view.addSubview(NavigationLabel)
        view.addSubview(NewButton)
        view.addSubview(Export)
        view.addSubview(eraseButton)
        view.addSubview(editButton)
        view.addSubview(saveButton)
        view.addSubview(instructionsButton)
        //Hiding subviews until behavior is defined: ppsekhar
        //view.addSubview(timeSignature)
        //view.addSubview(keySignature)
        view.addSubview(modeLabel)
        view.addSubview(signaturesLabel)

        // TODO(btc): configure these in their respective closure-initializers
        eraseButton.showsTouchWhenHighlighted = true
        editButton.showsTouchWhenHighlighted = true
        
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
        let centerX = parent.width/2
        let centerY = parent.height/2
        
        let titleH = parent.height / 2 - 2 * DEFAULT_MARGIN_PTS
        let titleW = titleH * THE_GOLDEN_RATIO
        
        //Button size chosed based on screen size
        let buttonSize = parent.width / 6
        
        //TODO: ppsekhar fix sizing, looks off on iphone 7
        let labelX = DEFAULT_MARGIN_PTS/2

        /* firstButtonX is the X location of the first menu item. This setup assumes 3 buttons per row and 3 rows. The buttons are centered with a slight margin of size buttonSize/2 between edges
        */
        let firstButtonX = centerX - buttonSize*2
        let secondButtonX = firstButtonX + 1.5*buttonSize
        let thirdButtonX = secondButtonX + 1.5*buttonSize
        
        let firstButtonY = 1.5*buttonSize
        let secondButtonY = centerY + 0.25*buttonSize
        let thirdButtonY = centerY + 2.25*buttonSize
        
        
        NavigationLabel.frame = CGRect(x: labelX,
                            y: -50,
                            width: titleW,
                            height: titleH)
        
        modeLabel.frame = CGRect(x: labelX,
                                 y: secondButtonY - 2*buttonSize,
                                 width: titleW,
                                 height: titleH)
        
        signaturesLabel.frame = CGRect(x: labelX,
                                 y: thirdButtonY - 1.75*buttonSize,
                                 width: titleW,
                                 height: titleH)

        NewButton.frame = CGRect(x: firstButtonX,
                                y: firstButtonY,
                                width: buttonSize,
                                height: buttonSize)
        
        editButton.frame = CGRect(x: firstButtonX,
                                   y: secondButtonY,
                                   width: buttonSize,
                                   height: buttonSize)

        eraseButton.frame = CGRect(x: secondButtonX,
                            y: secondButtonY,
                            width: buttonSize,
                            height: buttonSize)
        
        saveButton.frame = CGRect(x: secondButtonX,
                                  y: firstButtonY,
                                  width: buttonSize,
                                  height: buttonSize)
        
        instructionsButton.frame = CGRect(x:thirdButtonX,
                                          y: firstButtonY,
                                          width: buttonSize,
                                          height: buttonSize)
        
        timeSignature.frame = CGRect(x:firstButtonX,
                                   y: thirdButtonY,
                                   width: buttonSize,
                                   height: buttonSize)
        
        keySignature.frame = CGRect(x:secondButtonX,
                                   y: thirdButtonY,
                                   width: buttonSize,
                                   height: buttonSize)
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
