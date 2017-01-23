//
//  HomeMenuViewController.swift
//  allegro
//
//  Created by Brian Tiger Chow on 1/12/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class HomeMenuViewController: UIViewController {
    

    private let logo: UIView = {
        let v = UILabel() // TODO(btc): replace this with the logo image
        v.text = Strings.APP_NAME
        v.textAlignment = .center
        v.font = UIFont(name: DEFAULT_FONT_BOLD, size: 60)
        return v
    }()
    
    private let newCompositionButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = UIColor.gray
        v.setTitle(Strings.NEW, for: .normal)
        return v
    }()

    private let instructionsButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = UIColor.gray
        v.setTitle(Strings.INSTRUCTIONS, for: .normal)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        view.addSubview(logo)
        view.addSubview(newCompositionButton)
        view.addSubview(instructionsButton)
        
        newCompositionButton.addTarget(self, action: #selector(newCompositionTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews() // NB: does nothing

        let parent = view.bounds
        let centerX = parent.width / 2

        let logoH = parent.height / 2 - 2 * DEFAULT_MARGIN_PTS
        let logoW = logoH * THE_GOLDEN_RATIO

        logo.frame = CGRect(x: centerX - logoW / 2,
                            y: DEFAULT_MARGIN_PTS,
                            width: logoW,
                            height: logoH)

        let numButtons = [newCompositionButton, instructionsButton].count
        
        // FYI: this buttonH value ends up being 60.5 on iPhone 6
        let buttonH: CGFloat = (parent.height / 2 - 3 * DEFAULT_MARGIN_PTS) / CGFloat(numButtons)
        let buttonW = buttonH * 5 // is an educated guess

        newCompositionButton.frame = CGRect(x: centerX - buttonW / 2,
                                            y: parent.height / 2 + DEFAULT_MARGIN_PTS,
                                            width: buttonW,
                                            height: buttonH)

        instructionsButton.frame = CGRect(x: centerX - buttonW / 2,
                                          y: newCompositionButton.frame.maxY + DEFAULT_MARGIN_PTS,
                                          width: buttonW,
                                          height: buttonH)
    }
    
    func newCompositionTapped() {
        let p = Part()
        let vc = CompositionViewController.create(part: p)
        navigationController?.pushViewController(vc, animated: true)
    }
}
