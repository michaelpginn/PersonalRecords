//
//  NewRecordViewController.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 6/14/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import MobileCoreServices

enum RecordType:Int{
    case run
    case swim
    case triathlon
    case none
}
enum NewRecordMode{
    case newRecord
    case betterTime
}

final class NewRecordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var cellDescriptors:NSMutableArray!
    var visibleRowsPerSection = [[Int]]()
    var mode:NewRecordMode = .newRecord
    var currentEditingCell:CustomCell? = nil
    
    var type:RecordType?
    var distanceName:String?
    var distanceLength:Double?
    var timeIntervalTotal:TimeInterval?
    var timeIntervalComps:[Int] = [0,0] //hr, min
    var timeIntervalSeconds:Double = 0.0
    var date:Date?
    var location:String?
    var notes:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !UIAccessibility.isReduceTransparencyEnabled{
            view.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.frame
            self.view.insertSubview(blurEffectView, at: 0)
        }else{
            view.backgroundColor = .white
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }

        self.tableView.keyboardDismissMode = .onDrag
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tableView.register(UINib(nibName: "Normal", bundle: nil), forCellReuseIdentifier: "idCellNormal")
        tableView.register(UINib(nibName: "TextField", bundle: nil), forCellReuseIdentifier: "idCellTextField")
        tableView.register(UINib(nibName: "DatePicker", bundle: nil), forCellReuseIdentifier: "idCellDatePicker")
        tableView.register(UINib(nibName: "ValuePicker", bundle: nil), forCellReuseIdentifier: "idCellValuePicker")
        tableView.register(UINib(nibName: "TimeComponent", bundle: nil), forCellReuseIdentifier: "idCellTimeComp")
        tableView.register(UINib(nibName: "BigTextView", bundle: nil), forCellReuseIdentifier: "idCellBigTextView")
        
        self.date = Date()
        self.saveButton.setTitleColor(UIColor.gray, for: .disabled)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadCellDescriptors()
        
        //set current date
        guard let section2 = cellDescriptors[2] as? NSMutableArray else{return}
        guard var row = section2[0] as? [String : AnyObject] else{return}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        let dateString = dateFormatter.string(from: self.date!)
        
        row["primaryTitle"] = dateString as AnyObject
        section2[0] = row
        cellDescriptors[2] = section2
        
        if self.mode == .betterTime{
            //lets load up stuff we know
            titleLabel.text = "Better time"
            guard let section0 = cellDescriptors[0] as? NSMutableArray else{return}
            if var row0_0 = section0[0] as? [String : AnyObject] {
                row0_0["primaryTitle"] = String(describing: self.type!).capitalized as AnyObject
                row0_0["isExpandable"] = false as AnyObject
                section0[0] = row0_0
            }
            if var row0_2 = section0[2] as? [String : AnyObject] {
                row0_2["primaryTitle"] = self.distanceName as AnyObject
                row0_2["isExpandable"] = false as AnyObject
                section0[2] = row0_2
            }
            cellDescriptors[0] = section0
        }
        tableView.reloadData()
    }
    
    @IBAction func saveRecord(sender:UIButton){
        self.view.endEditing(true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let newRecord = Record(context: managedContext)
        newRecord.activity_type = Int32(self.type!.rawValue)
        newRecord.distance_name = self.distanceName
        newRecord.distance_meters = NSNumber(value: self.distanceLength!)
        newRecord.time_seconds = NSNumber(value: self.timeIntervalTotal!)
        newRecord.time_string = self.getTimeString()
        newRecord.date = self.date as NSDate?
        newRecord.location = self.location
        newRecord.notes = self.notes
        CoreDataManager.saveRecordToCoreData(newRecord, context: managedContext)
        
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: .RefreshRecords, object: nil)
            NotificationCenter.default.post(name: .RefreshRecordDetail, object: nil)
        })
    }
    
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkEnableSaveButton(){
        let enabled = self.type != nil && self.distanceName != nil && self.distanceLength != nil && self.timeIntervalTotal != nil
        self.saveButton.isEnabled = enabled
    }
    
    
    // MARK: CustomCell Delegate
    func dateWasSelected(selectedDateString: String, rawDate: Date) {
        self.date = rawDate
        
        guard let section = cellDescriptors[2] as? NSMutableArray else{return}
        guard var row = section[0] as? [String : AnyObject] else{return}
        
        row["primaryTitle"] = selectedDateString as AnyObject
        section[0] = row
        self.collapseRow(0, sectionIndex: 2)
        cellDescriptors[2] = section
        
        getIndicesOfVisibleRows()
        tableView.reloadSections(IndexSet(integer: 2), with: .fade)
    }
    
    func valuePickerChoiceSelected(selectedIndex: Int, valuePickerType: ValuePickerSourceType) {
        guard let section = cellDescriptors[0] as? NSMutableArray else{return}
        //var rowToReload = 0
        if valuePickerType == .types{
            self.type = RecordType(rawValue: selectedIndex)
            guard var row = section[0] as? [String : AnyObject] else{return}
            row["primaryTitle"] = String(describing: self.type!).capitalized as AnyObject
            section[0] = row
            self.collapseRow(0, sectionIndex: 0)
        }else{
            if valuePickerType == .runs{
                self.distanceName = (Distances.runs.sortedKeys())[selectedIndex]
                self.distanceLength = Distances.runs[self.distanceName!]
            }else if valuePickerType == .swims{
                self.distanceName = (Distances.swims.sortedKeys())[selectedIndex]
                self.distanceLength = Distances.swims[self.distanceName!]
            }else if valuePickerType == .triathlons{
                self.distanceName = (Distances.triathlons.sortedKeys())[selectedIndex]
                self.distanceLength = Distances.triathlons[self.distanceName!]
            }
            guard var row = section[2] as? [String : AnyObject] else{return}
            row["primaryTitle"] = self.distanceName as AnyObject
            section[2] = row
            self.collapseRow(2, sectionIndex: 0)
        }
        cellDescriptors[0] = section
        
        getIndicesOfVisibleRows()
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        self.checkEnableSaveButton()
    }
    
    func textfieldTextWasChanged(newText: String, parentCell: CustomCell) {
        guard let parentCellIndexPath = tableView.indexPath(for: parentCell) else{return}
        if parentCellIndexPath.section == 1{
            //one of the time cells
            if parentCellIndexPath.row - 1 == 2{
                //seconds
                let rawNumber = Double(newText) ?? 0
                self.timeIntervalSeconds = rawNumber
            }else{
                //hours or mins
                let rawNumber = Int(newText) ?? 0
                self.timeIntervalComps[parentCellIndexPath.row - 1] = rawNumber
            }
            
            //recalc time interval
            timeIntervalTotal = Double(timeIntervalComps[0] * 3600) + Double(timeIntervalComps[1] * 60) + (timeIntervalSeconds)
            
            guard let section = cellDescriptors[1] as? NSMutableArray else{return}
            guard var currentRow = section[parentCellIndexPath.row] as? [String : AnyObject] else{return}
            currentRow["value"] = newText as AnyObject
            
            guard var parentRow = section[0] as? [String : AnyObject] else{return}
            parentRow["primaryTitle"] = self.getTimeString() as AnyObject
            
            section[parentCellIndexPath.row] = currentRow
            section[0] = parentRow
            
            getIndicesOfVisibleRows()
            tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
        }else if parentCellIndexPath.section == 2{
            //location
            location = newText
            
            guard let section = cellDescriptors[2] as? NSMutableArray else{return}
            guard var currentRow = section[parentCellIndexPath.row] as? [String : AnyObject] else{return}
            currentRow["value"] = newText as AnyObject
            
            guard var parentRow = section[2] as? [String : AnyObject] else{return}
            parentRow["primaryTitle"] = newText as AnyObject
            
            section[parentCellIndexPath.row] = currentRow
            section[2] = parentRow
            
            getIndicesOfVisibleRows()
            if visibleRowsPerSection[2][1] == 2{
                tableView.reloadRows(at: [IndexPath(row: 1, section: 2)], with: .fade)
            }else{
                tableView.reloadRows(at: [IndexPath(row: 2, section: 2)], with: .fade)
            }
            
        }
        self.checkEnableSaveButton()
    }
    
    func getTimeString()->String{
        var secondsPart:String
        if timeIntervalSeconds.truncatingRemainder(dividingBy: 1) == 0{
            //no fraction
            secondsPart = "\(Int(timeIntervalSeconds))"
        }else{
            secondsPart = "\(timeIntervalSeconds)"
        }
        
        if timeIntervalComps[0]==0 && timeIntervalComps[1]==0{
            return "\(secondsPart) s"
        }else{
            //Could be mm:ss or hh:mm:ss
            var returnString = ""
            if timeIntervalSeconds < 10.0{
                returnString = "\(timeIntervalComps[1]):0\(secondsPart)"
            }else{
                returnString = "\(timeIntervalComps[1]):\(secondsPart)"
            }
            
            if timeIntervalComps[0] != 0{
                //hh:mm:ss
                if timeIntervalComps[1] < 10{
                    returnString = "\(timeIntervalComps[0]):0" + returnString
                }else{
                    returnString = "\(timeIntervalComps[0]):" + returnString
                }
            }
            return returnString
        }
        
    }
    
    func notesTextEntered(newText: String) {
        notes = newText
        
        guard let section = cellDescriptors[2] as? NSMutableArray else{return}
        guard var parentRow = section[4] as? [String : AnyObject] else{return}
        
        if newText.count > 10{
            parentRow["primaryTitle"] = String(newText.prefix(10)) + "..." as AnyObject
        }else{
            parentRow["primaryTitle"] = newText as AnyObject
        }
        section[4] = parentRow
        
        self.collapseRow(4, sectionIndex: 2)
        getIndicesOfVisibleRows()
        tableView.reloadSections(IndexSet(integer: 2), with: .fade)
    }
    
    // Keyboard management
    func textfieldBeganEditing(parentCell: CustomCell) {
        self.currentEditingCell = parentCell
    }
    
    @objc func keyboardShown(_ notification: Notification) {
        guard let cell = currentEditingCell else{return}
        let rectInWindow = tableView.convert(cell.frame, to: nil)
        let bottomY = rectInWindow.maxY
        
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else{return}
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        guard keyboardHeight > 0 else{return}
        let windowHeight = self.view.frame.height
        
        if bottomY > windowHeight - keyboardHeight{
            //somethings covered up
            print("cell covered")
            let offset = bottomY - (windowHeight - keyboardHeight)
            let currentOffset = tableView.contentOffset.y
            let totalOffset:CGFloat = { //check to see if top of cell is visible?
                if currentOffset + offset > cell.frame.minY{
                    return cell.frame.minY
                }else{
                    return currentOffset + offset
                }
            }()
            let offsetPoint = CGPoint(x: 0, y: totalOffset)
            tableView.setContentOffset(offsetPoint, animated: true)
            
            
        }

    }
    
    @objc func keyboardHidden(_ notification: Notification) {
        currentEditingCell = nil
    }
    
    // MARK: Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        if cellDescriptors != nil {
            return cellDescriptors.count
        }
        else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleRowsPerSection[section].count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath: indexPath)
        
        let id = currentCellDescriptor["cellIdentifier"] as! String
        return heightForId(id)
    }

    private func heightForId(_ id:String) -> CGFloat{
        switch id{
        case "idCellNormal":
            return 60.0
        case "idCellDatePicker", "idCellValuePicker", "idCellBigTextView":
            return 270.0
        default:
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: currentCellDescriptor["cellIdentifier"] as! String, for: indexPath) as! CustomCell
        
        if currentCellDescriptor["cellIdentifier"] as! String == "idCellNormal" {
            if let primaryTitle = currentCellDescriptor["primaryTitle"] {
                cell.textLabel?.text = primaryTitle as? String
            }
            
            if let secondaryTitle = currentCellDescriptor["secondaryTitle"] {
                cell.detailTextLabel?.text = secondaryTitle as? String
            }
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellTextField" {
            cell.textField.placeholder = currentCellDescriptor["primaryTitle"] as? String
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellValuePicker" {
            cell.textLabel?.text = currentCellDescriptor["primaryTitle"] as? String
            
            if currentCellDescriptor["secondaryTitle"] as? String == "type"{
                cell.valuePickerSourceType = ValuePickerSourceType.types
            }else if self.type == nil{
                cell.valuePickerSourceType = ValuePickerSourceType.none
            }else{
                cell.valuePickerSourceType = ValuePickerSourceType(rawValue: self.type!.rawValue + 1)
            }
            cell.valuePicker.reloadAllComponents()
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellTimeComp" {
            if let unitLabel = cell.viewWithTag(1) as? UILabel{
                unitLabel.text = currentCellDescriptor["primaryTitle"] as? String
            }
            if let value = currentCellDescriptor["value"] as? String{
                cell.textField.text = value
            }
        }
        
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexOfTappedRow = visibleRowsPerSection[indexPath.section][indexPath.row]

        guard let section = cellDescriptors[indexPath.section] as? NSMutableArray else{return}
        guard var cellRow = section[indexOfTappedRow] as? [String:AnyObject] else{return}
        var offset:CGFloat? = nil
        var shouldExpandAndShowSubRows = false
        
        if cellRow["isExpandable"] as! Bool == true {
            if cellRow["isExpanded"] as! Bool == false {
                // In this case the cell should expand.
                shouldExpandAndShowSubRows = true
                print("Expanding")
            }
            cellRow["isExpanded"] = shouldExpandAndShowSubRows as AnyObject
            
            // change the visibility of the subcells
            var totalHeight = heightForId(cellRow["cellIdentifier"] as! String)
            for i in (indexOfTappedRow + 1)...(indexOfTappedRow + (cellRow["additionalRows"] as! Int)) {
                guard var currentRow = section[i] as? [String:AnyObject] else{break}
                totalHeight += heightForId(currentRow["cellIdentifier"] as! String)
                currentRow["isVisible"] = shouldExpandAndShowSubRows as AnyObject
                section[i] = currentRow
            }
            // scroll if cells are offscreen
            let rectInTableView = tableView.rectForRow(at: indexPath)
            let rectInWindow = tableView.convert(rectInTableView, to: nil)
            let startingY = rectInWindow.origin.y
            let tableViewBottomY = tableView.frame.maxY
            if startingY + totalHeight > tableViewBottomY{
                offset = (startingY + totalHeight) - tableViewBottomY
            }
            
            //apply changes
            section[indexOfTappedRow] = cellRow
            cellDescriptors[indexPath.section] = section
        }
        getIndicesOfVisibleRows()
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
        tableView.layoutIfNeeded()
        
        if offset != nil && shouldExpandAndShowSubRows == true{
            let offsetPoint = CGPoint(x: 0, y: offset! + 12)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute:{
                tableView.setContentOffset(offsetPoint, animated: true)
            })
            
        }
        print(tableView.contentOffset)
    }
    
    
    
    // MARK: Expandable cell management
    
    private func collapseRow(_ rowIndex:Int, sectionIndex:Int){
        guard let section = cellDescriptors[sectionIndex] as? NSMutableArray else{return}
        guard var row = section[rowIndex] as? [String:AnyObject] else{return}
        
        if row["isExpandable"] as! Bool == true{
            row["isExpanded"] = false as AnyObject
            
            guard var nextRow = section[rowIndex + 1] as? [String:AnyObject] else{return}
            nextRow["isVisible"] = false as AnyObject
            section[rowIndex + 1] = nextRow
        }
        section[rowIndex] = row
        cellDescriptors[sectionIndex] = section
    }
    
    func loadCellDescriptors() {
        if let path = Bundle.main.path(forResource: "CellDescriptor", ofType: "plist") {
            cellDescriptors = NSMutableArray(contentsOfFile: path)
            getIndicesOfVisibleRows()
            tableView.reloadData()
        }
    }
    
    func getIndicesOfVisibleRows() {
        visibleRowsPerSection.removeAll()
        
        for case let currentSectionCells as NSMutableArray in cellDescriptors{
            var visibleRows = [Int]()
            
            for row in 0...((currentSectionCells as! [[String: AnyObject]]).count - 1) {
                if let currentCell = currentSectionCells[row] as? NSDictionary{
                    if currentCell["isVisible"] as! Bool == true {
                        visibleRows.append(row)
                    }
                }
            }
            
            visibleRowsPerSection.append(visibleRows)
        }
    }
    
    func getCellDescriptorForIndexPath(indexPath: IndexPath) -> [String: AnyObject] {
        let indexOfVisibleRow = visibleRowsPerSection[indexPath.section][indexPath.row]
        guard let currentSection = cellDescriptors[indexPath.section] as? NSMutableArray else{return [:]}
        guard let cellDescriptor = currentSection[indexOfVisibleRow] as? [String: AnyObject] else{return [:]}
        return cellDescriptor
    }
}


