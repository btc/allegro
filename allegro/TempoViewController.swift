//
//  TempoViewController.swift
//  allegro
//
//  Created by Nikhil Lele on 3/24/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class TempoViewController: UIViewController {
    
    private static let BPM_MIN: Float = 60
    private static let BPM_MAX: Float = 160
    
    private let store: PartStore
    
    private var tempoLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "Montserrat-Light", size: 48)
        v.textAlignment = .center
        return v
    }()
    
    private var minTempoLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "Montserrat-ExtraLight", size: 28)
        v.textAlignment = .right
        v.text = "\(Int(TempoViewController.BPM_MIN))"
        return v
    }()
    
    private var maxTempoLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont(name: "Montserrat-ExtraLight", size: 28)
        v.textAlignment = .left
        v.text = "\(Int(TempoViewController.BPM_MAX))"
        return v
    }()
    
    private var tempoSlider: UISlider = {
        let v = UISlider()
        v.isContinuous = false
        v.isUserInteractionEnabled = true
        v.minimumValue = TempoViewController.BPM_MIN
        v.maximumValue = TempoViewController.BPM_MAX
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
        view.backgroundColor = .white
        view.addSubview(tempoLabel)
        view.addSubview(tempoSlider)
        view.addSubview(minTempoLabel)
        view.addSubview(maxTempoLabel)
        
        tempoSlider.addTarget(self, action: #selector(tempoDidChange), for: .touchDragInside)
        navigationController?.navigationBar.topItem?.title = "Tempo"
        
        tempoSlider.value = Float(store.tempo)
        tempoDidChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        storeSetTempo()
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let parent = view.bounds
        let navbarHeight = navigationController?.navigationBar.frame.height ?? DEFAULT_MARGIN_PTS
        
        let labelWidth: CGFloat = 60
        
        tempoLabel.frame = CGRect(x: parent.minX + DEFAULT_MARGIN_PTS,
                                  y: navbarHeight + DEFAULT_MARGIN_PTS,
                                  width: parent.width - 2 * DEFAULT_MARGIN_PTS,
                                  height: DEFAULT_TAP_TARGET_SIZE)
        
        minTempoLabel.frame = CGRect(x: parent.minX + DEFAULT_MARGIN_PTS,
                                     y: tempoLabel.frame.maxY + DEFAULT_MARGIN_PTS,
                                     width: labelWidth,
                                     height: DEFAULT_TAP_TARGET_SIZE)
        
        maxTempoLabel.frame = CGRect(x: parent.maxX - DEFAULT_MARGIN_PTS - labelWidth,
                                     y: tempoLabel.frame.maxY + DEFAULT_MARGIN_PTS,
                                     width: labelWidth,
                                     height: DEFAULT_TAP_TARGET_SIZE)
        
        tempoSlider.frame = CGRect(x: minTempoLabel.frame.maxX + DEFAULT_MARGIN_PTS,
                                   y: tempoLabel.frame.maxY + DEFAULT_MARGIN_PTS,
                                   width: parent.width - (4 * DEFAULT_MARGIN_PTS + 2 * labelWidth),
                                   height: DEFAULT_TAP_TARGET_SIZE)
        

    }
    
    // can we remove the @objc?
    @objc private func tempoDidChange() {
        let tempo = Int(tempoSlider.value)
        tempoLabel.text = "\(tempo) BPM"
    }
    
    private func storeSetTempo() {
        let tempo = Int(tempoSlider.value)
        store.tempo = tempo
    }
    
}
