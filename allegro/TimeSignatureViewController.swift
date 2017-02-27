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
        ["2","3","4","6","8"],
        ["2","3","4","6","8"]
    ]
    
    private let timeSigTitle: UIView = {
        let v = UILabel()
        v.text = "Select Time Signature"
        v.textAlignment = .center
        v.textColor = .white
        v.backgroundColor = UIColor.allegroPurple
        v.font = UIFont(name: DEFAULT_FONT, size: 20)
        return v
    }()
    
    
    private var timeSigPickerView: UIPickerView = {
        var v = UIPickerView()
        return v
    } ()
    
    private let doneButton:UIBarButtonItem =  {
        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(backButtonTapped))
        return b
    }()
    
    private let toolBar:UIToolbar =  {
        let tb = UIToolbar()
        tb.barStyle = UIBarStyle.default
        tb.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        tb.setShadowImage(UIImage(), forToolbarPosition: .any)
        tb.tintColor = UIColor.allegroPurple
        tb.sizeToFit()
        tb.isUserInteractionEnabled = true
        return tb
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
        view.backgroundColor = UIColor.white
        view.addSubview(timeSigTitle)
        
        view.addSubview(timeSigPickerView)
        timeSigPickerView.delegate = self
        timeSigPickerView.dataSource = self
        timeSigPickerView.selectRow(2, inComponent: 0, animated: false)
        timeSigPickerView.selectRow(2, inComponent: 1, animated: false)
        
        view.addSubview(toolBar)
        toolBar.setItems([doneButton], animated: false)
        
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let parent = view.bounds
        let buttonH: CGFloat = (parent.height / 3 - 3 * DEFAULT_MARGIN_PTS)
        let buttonW = buttonH * THE_GOLDEN_RATIO // is an educated guess
        
        timeSigTitle.frame = CGRect(x: 0,
                                    y: 0,
                                    width: parent.width,
                                    height: buttonH)
        
        toolBar.frame = CGRect(x: parent.width - buttonW - DEFAULT_MARGIN_PTS,
                              y: parent.height - buttonH - DEFAULT_MARGIN_PTS,
                              width: buttonW,
                              height: buttonH)
        
        timeSigPickerView.frame = CGRect(x:parent.width * 0.1,
                                         y:parent.height * 0.1,
                                         width: parent.width * 0.8,
                                         height: parent.height * 0.8)

    }
    
    
    func backButtonTapped() {
        guard let numerator = Int(pickerData[0][timeSigPickerView.selectedRow(inComponent: 0)]) else {return}
        guard let denominator = Int(pickerData[1][timeSigPickerView.selectedRow(inComponent: 1)]) else {return}
        if let curTime = Rational(numerator, denominator) {
            store.setTimeSignature(timeSignature: curTime)
        }
        
        let _ = navigationController?.popViewController(animated: true)
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
