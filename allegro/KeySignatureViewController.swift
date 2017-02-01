//
//  KeySignatureViewController.swift
//  allegro
//
//  Created by Priyanka Sekhar on 2/1/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class KeySignatureViewController: UIViewController {
    
    private let backButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = UIColor.allegroPurple
        v.setTitle("Key Sig: Back", for: UIControlState.normal)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        view.addSubview(backButton)
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews() // NB: does nothing
        
        let parent = view.bounds
        let centerX = parent.width / 2
        
        
        // FYI: this buttonH value ends up being 60.5 on iPhone 6
        let buttonH: CGFloat = (parent.height / 2 - 3 * DEFAULT_MARGIN_PTS)
        let buttonW = buttonH * 5 // is an educated guess
        
        backButton.frame = CGRect(x: centerX - buttonW / 2,
                                  y: parent.height / 2 + DEFAULT_MARGIN_PTS,
                                  width: buttonW,
                                  height: buttonH)
        
    }
    
    func backButtonTapped() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
}
