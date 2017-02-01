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

    private let backButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = UIColor.allegroPurple
        v.setTitle("Time Sig: Back", for: UIControlState.normal)
        return v
    }()
    
    var timeSigPickerView: UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        //view.addSubview(backButton)
        view.addSubview(timeSigPickerView)
        timeSigPickerView.delegate = self
        timeSigPickerView.dataSource = self
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let parent = view.bounds
        let centerX = parent.width / 2
        
        
        // FYI: this buttonH value ends up being 60.5 on iPhone 6
        let buttonH: CGFloat = (parent.height / 2 - 3 * DEFAULT_MARGIN_PTS)
        let buttonW = buttonH * 5 // is an educated guess
        
        backButton.frame = CGRect(x: centerX - buttonW / 2,
                                            y: parent.height / 2 + DEFAULT_MARGIN_PTS,
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
