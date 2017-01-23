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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
        view.addSubview(MenuOptions)
        view.addSubview(Home)
        view.addSubview(Export)
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
        
        let homeH = parent.height / 2 - 2 * DEFAULT_MARGIN_PTS
        let homeW = homeH * THE_GOLDEN_RATIO
        Home.frame = CGRect(x: centerX - homeW / 2,
                                   y: centerY - 3 * DEFAULT_MARGIN_PTS,
                                   width: homeW,
                                   height: homeH)
        
        let exportH = parent.height / 2 - 2 * DEFAULT_MARGIN_PTS
        let exportW = exportH * THE_GOLDEN_RATIO
        Export.frame = CGRect(x: centerX - homeW / 2,
                            y: centerY,
                            width: exportW,
                            height: exportH)
    }
}
