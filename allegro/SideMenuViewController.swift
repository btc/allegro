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

    private let NewButton: UIView = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "new-page"), for: UIControlState.normal)
        v.imageView?.contentMode = .scaleAspectFit
        return v
    }()
    
    private let instructionsButton: UIView = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "question"), for: UIControlState.normal)
        v.imageView?.contentMode = .scaleAspectFit
        return v
    }()
    
    //Change to dynamically set time Signature based on user selection: ppsekhar
    private let timeSignature: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setTitleColor(.black, for: .normal)
        v.titleLabel?.font = UIFont(name: DEFAULT_FONT, size: DEFAULT_TAP_TARGET_SIZE)
        return v
    }()
    
    //Change to dynamically set key signature based on user selection: ppsekhar
    private let keySignature: UIButton = {
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
        v.showsTouchWhenHighlighted = true
        v.imageView?.contentMode = .scaleAspectFit
        return v
    }()

    private let eraseButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .clear
        v.setImage(#imageLiteral(resourceName: "eraser"), for: UIControlState.normal)
        v.showsTouchWhenHighlighted = true
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
        
        view.backgroundColor = UIColor.allegroPurple
        view.addSubview(NewButton)
        view.addSubview(Export)
        view.addSubview(instructionsButton)
        view.addSubview(eraseButton)
        view.addSubview(editButton)
        view.addSubview(timeSignature)
        view.addSubview(keySignature)
        
        eraseButton.addTarget(self, action: #selector(eraseButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        timeSignature.addTarget(self, action: #selector(timeSignaturesTapped), for: .touchUpInside)
        keySignature.addTarget(self, action: #selector(keySignaturesTapped), for: .touchUpInside)

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

        let verticallyStackedButtons = [NewButton, Export, instructionsButton]
        let modeButtonBlocks = [editButton, eraseButton]
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
        
        timeSignature.setTitle(store.part.getTimeSignature().description, for: .normal)
    }

    func updateUI() {
        editButton.isSelected = store.mode == .edit
        eraseButton.isSelected = store.mode == .erase
        timeSignature.setTitle(store.part.getTimeSignature().description, for: .normal)
    }
    func eraseButtonTapped() {
        store.mode = .erase
        slideMenuController()?.closeRight()
    }

    func editButtonTapped() {
        store.mode = .edit
        slideMenuController()?.closeRight()
    }
    
    func timeSignaturesTapped() {
        let vc = TimeSignatureViewController(store: store)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func keySignaturesTapped() {
        let vc = KeySignatureViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SideMenuViewController: PartStoreObserver {
    func partStoreChanged() {
        updateUI()
    }
}
