//
//  TimeSignatureViewController.swift
//  allegro
//
//  Created by Priyanka Sekhar on 2/1/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit
import Rational

class TimeSignatureViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    fileprivate let store: PartStore
    
    private let pickerData = [
        ["2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19"],
        ["2","4","8"]
    ]
    
    private var timeSigPickerView: UIPickerView = {
        var v = UIPickerView()
        return v
    } ()
    
    init(store: PartStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        view.addSubview(timeSigPickerView)
        timeSigPickerView.delegate = self
        timeSigPickerView.dataSource = self
        
        navigationController?.navigationBar.topItem?.title = "Time Signature"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        storeSetTimeSignature()
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let parent = view.bounds
        
        timeSigPickerView.frame = CGRect(x:parent.width * 0.1,
                                         y:parent.height * 0.1,
                                         width: parent.width * 0.8,
                                         height: parent.height * 0.8)
        setTimeSigPickerValues()
        

    }
    
    private func setTimeSigPickerValues() {
        let numerator = store.part.timeSignature.numerator
        let denominator = store.part.timeSignature.denominator
        if let numIndex = pickerData[0].index(of: String(numerator)) {
            timeSigPickerView.selectRow(numIndex, inComponent: 0, animated: false)
        }
        if let denomIndex = pickerData[1].index(of: String(denominator)) {
            timeSigPickerView.selectRow(denomIndex, inComponent: 1, animated: false)
        }
    }
    
    private func storeSetTimeSignature() {
        guard let numerator = Int(pickerData[0][timeSigPickerView.selectedRow(inComponent: 0)]) else {return}
        guard let denominator = Int(pickerData[1][timeSigPickerView.selectedRow(inComponent: 1)]) else {return}
        if let curTime = Rational(numerator, denominator) {
            store.setTimeSignature(timeSignature: curTime)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int
        ) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        return pickerData[component][row]
    }
    


}
