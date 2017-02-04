//
//  TimeSignatureViewController.swift
//  allegro
//
//  Created by Priyanka Sekhar on 2/1/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import UIKit

class TimeSignatureViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
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
    
    private var timeSigPickerView: UIPickerView = UIPickerView()
    private let toolBar = UIToolbar()
    private let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(backButtonTapped))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(timeSigTitle)
        
        view.addSubview(timeSigPickerView)
        timeSigPickerView.delegate = self
        timeSigPickerView.dataSource = self
        
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolBar.tintColor = UIColor.allegroPurple
        toolBar.sizeToFit()
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        view.addSubview(toolBar)
        
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
        
        timeSigPickerView.frame = CGRect(x:self.view.frame.size.width * 0.1,
                                         y:self.view.frame.size.height * 0.1,
                                         width: self.view.frame.size.width * 0.8,
                                         height: self.view.frame.size.height * 0.8)

    }
    
    func backButtonTapped() {
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
