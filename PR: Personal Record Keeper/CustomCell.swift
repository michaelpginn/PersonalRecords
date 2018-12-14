//
//  CustomCell.swift
//  Expandable
//
//  Created by Gabriel Theodoropoulos on 28/10/15.
//  Copyright © 2015 Appcoda. All rights reserved.
//

import UIKit

enum ValuePickerSourceType:Int{
    case types
    case runs
    case swims
    case triathlons
    case none
}

protocol CustomCellDelegate {
    func dateWasSelected(selectedDateString: String, rawDate:Date)
    func textfieldTextWasChanged(newText: String, parentCell: CustomCell)
    func valuePickerChoiceSelected(selectedIndex:Int, valuePickerType: ValuePickerSourceType)
    func notesTextEntered(newText:String)
    func textfieldBeganEditing(parentCell: CustomCell)
}

class CustomCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {

    // MARK: IBOutlet Properties
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var valuePicker: UIPickerView!
    @IBOutlet weak var bigTextView: UITextView!
    
    // MARK: Constants
    
    let bigFont = UIFont(name: "Avenir-Book", size: 17.0)
    let smallFont = UIFont(name: "Avenir-Light", size: 17.0)
    let primaryColor = UIColor.black
    let secondaryColor = UIColor.lightGray
    
    // MARK: Variables
    
    var delegate: CustomCellDelegate!
    var valuePickerSourceType:ValuePickerSourceType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if textLabel != nil {
            textLabel?.font = bigFont
            textLabel?.textColor = primaryColor
        }
        
        if detailTextLabel != nil {
            detailTextLabel?.font = smallFont
            detailTextLabel?.textColor = secondaryColor
        }
        
        if textField != nil {
            textField.font = bigFont
            textField.delegate = self
        }
        
        if valuePicker != nil{
            valuePicker.delegate = self
            valuePicker.dataSource = self
            valuePicker.reloadAllComponents()
        }
        
        if bigTextView != nil{
            bigTextView.font = bigFont
            bigTextView.delegate = self
            bigTextView.layer.cornerRadius = 3.0
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    // MARK: IBAction Functions
    
    @IBAction func setDate(sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        let dateString = dateFormatter.string(from: datePicker.date)
        
        if delegate != nil {
            delegate.dateWasSelected(selectedDateString: dateString, rawDate: datePicker.date)
        }
    }
    
    @IBAction func setValue(sender: UIButton) {
        print("Value picked!")
        if delegate != nil{
            let selectedRow = valuePicker.selectedRow(inComponent: 0)
            delegate.valuePickerChoiceSelected(selectedIndex: selectedRow, valuePickerType: valuePickerSourceType!)
        }
    }
    
    @IBAction func setNoteText(sender: UIButton){
        print("Text entered")
        if delegate != nil{
            delegate.notesTextEntered(newText: bigTextView.text)
        }
    }

    
    // MARK: UITextFieldDelegate Function
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("began editing")
        if delegate != nil {
            delegate.textfieldBeganEditing(parentCell: self)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("text changed")
        if delegate != nil {
            delegate.textfieldTextWasChanged(newText: textField.text!, parentCell: self)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("text changed")
        if delegate != nil {
            delegate.textfieldTextWasChanged(newText: textField.text!, parentCell: self)
        }
    }
    
    // MARK: UITextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("began editing")
        if delegate != nil {
            delegate.textfieldBeganEditing(parentCell: self)
        }
        return true
    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if valuePickerSourceType == .types{
            return 3
        }else if valuePickerSourceType == .runs{
            return 14
        }else if valuePickerSourceType == .swims{
            return 15
        }else if valuePickerSourceType == .triathlons{
            return 3
        }else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if valuePickerSourceType == .types{
            let types = ["Run", "Swim", "Triathlon"]
            return types[row]
        }else if valuePickerSourceType == .runs{
            let runs = Distances.runs.sortedKeys()
            if row != 14{
                return runs[row]
            }else{
                return "Custom"
            }
        }else if valuePickerSourceType == .swims{
            let swims = Distances.swims.sortedKeys()
            if row != 15{
                return swims[row]
            }else{
                return "Custom"
            }
        }else if valuePickerSourceType == .triathlons{
            let tris = Distances.triathlons.sortedKeys()
            if row != 3{
                return tris[row]
            }else{
                return "Custom"
            }
        }else{
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
}

