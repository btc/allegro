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
        
        tempoSlider.addTarget(self, action: #selector(tempoDidChange), for: .valueChanged)
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
        
        
        tempoLabel.frame = CGRect(x: parent.minX + DEFAULT_MARGIN_PTS,
                                  y: parent.minY + DEFAULT_MARGIN_PTS,
                                  width: parent.width - 2 * DEFAULT_MARGIN_PTS,
                                  height: DEFAULT_TAP_TARGET_SIZE)
        
        tempoSlider.frame = CGRect(x: parent.minX + DEFAULT_MARGIN_PTS,
                                   y: parent.height / 2,
                                   width: parent.width - 2 * DEFAULT_MARGIN_PTS,
                                   height: DEFAULT_TAP_TARGET_SIZE)

    }
    
    // can we remove the @objc?
    @objc private func tempoDidChange() {
        tempoLabel.text = "\(tempoSlider.value)"
    }
    
    private func storeSetTempo() {
        let tempo = Int(tempoSlider.value)
        store.tempo = tempo
    }
    
}
