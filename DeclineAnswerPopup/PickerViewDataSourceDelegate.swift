//
//  PickerViewDataSourceDelegate.swift
//  DeclineAnswerPopup
//
//  Created by Артем Труханов on 21.05.15.
//  Copyright (c) 2015 TRUe_ART. All rights reserved.
//

import Foundation
import UIKit

protocol PickerViewDelegate:NSObjectProtocol
{
    func updatedValue(object: AnyObject)
}

class PickerViewDataSourceDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource
{
    var pickerDataSource = ["first", "second", "third"]
    
    weak var delegate: PickerViewDelegate!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate.updatedValue(pickerDataSource[row])
    }
}