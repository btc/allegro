//
//  HelpViewController.swift
//  allegro
//
//  Created by Nikhil Lele on 3/18/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//
import UIKit
import Pages

class HelpViewController: PagesController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "Help"
        navigationController?.navigationBar.backgroundColor = .white
        
        let page1 = PageController()
        page1.title = "Help Page 1"
        page1.imageView.image = #imageLiteral(resourceName: "help_p1")
        
        let page2 = PageController()
        page2.title = "Help Page 2"
        page2.imageView.image = #imageLiteral(resourceName: "help_p2")
        
        add([page1, page2])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

fileprivate class PageController: UIViewController {
    lazy var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        
        let parent = view.bounds
        let navbarHeight = navigationController?.navigationBar.frame.height ?? DEFAULT_MARGIN_PTS
        
        imageView.frame = CGRect(x: parent.minX,
                                 y: parent.minY + navbarHeight,
                                 width: parent.width,
                                 height: parent.height - (parent.minY + navbarHeight))
    }
}
