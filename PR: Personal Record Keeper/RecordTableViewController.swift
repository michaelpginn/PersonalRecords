//
//  RecordTableViewController.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 6/1/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData

typealias SortPredicate = (Record, Record) -> Bool

final class RecordTableViewController: UITableViewController, RecordCellContentViewDelegate {
    private var records:[Record] = []
    private var recordsToDisplay:[Record]? = nil
    private var firstTimeAppearing = true
    
    private var sortPredicates:[String:SortPredicate] = [:]
    private var currentSort:String?
    private var currentFilter:RecordType = .none
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    var noRecordsLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Add a record using the button on the bottom right."
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 33.0) as Any]
        } 
        
        
        fetchRecordsFromCoreData()
        reloadRecordsToDisplay()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTableView), name: .RefreshRecords, object: nil)
        
        sortPredicates["Date (newest)"] = { (recordA, recordB) -> Bool in
            let dateA = recordA.date as Date? ?? Date()
            let dateB = recordB.date as Date? ?? Date()
            return dateA.compare(dateB) == ComparisonResult.orderedDescending
        }
        sortPredicates["Date (oldest)"] = { (recordA, recordB) -> Bool in
            let dateA = recordA.date as Date? ?? Date()
            let dateB = recordB.date as Date? ?? Date()
            return dateA.compare(dateB) == ComparisonResult.orderedAscending
        }
        sortPredicates["Type"] = {(recordA, recordB) -> Bool in
            if recordA.activity_type == recordB.activity_type{
                return recordA.distance_meters?.compare(recordB.distance_meters!) == .orderedAscending
            }else{
                return recordA.activity_type < recordB.activity_type
            }
        }
        
        view.addSubview(noRecordsLabel)
        noRecordsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noRecordsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -1 *  self.navigationController!.navigationBar.frame.height).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if firstTimeAppearing{
            animateTable()
            firstTimeAppearing = false
        }
    }
        
    private func fetchRecordsFromCoreData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:"Record") //get the list of records
        let predicate = NSPredicate(format: "better == nil")
        fetchRequest.predicate = predicate
        var fetchedResults:[Record]? = nil
        do{
            fetchedResults = try managedContext.fetch(fetchRequest) as? [Record]
        } catch _{
            print("Something went wrong getting words")
        }
        if (fetchedResults != nil){
            records = fetchedResults!
        }
    }

    // MARK: - Tableview editing/display methods
    func reloadRecordsToDisplay(){
        //Sort first
        let sortedRecords:[Record]
        if currentSort != nil{
            sortedRecords = records.sorted(by: sortPredicates[currentSort!]!)
        }else{
            sortedRecords = records
        }
        
        //now filter
        if currentFilter == .none{
            recordsToDisplay = sortedRecords
            filterButton.image = #imageLiteral(resourceName: "Filter icon outline")
            self.navigationItem.title = "Personal Records"
        }else{
            self.recordsToDisplay = []
            for record in sortedRecords{
                if RecordType(rawValue: Int(record.activity_type)) == currentFilter{
                    self.recordsToDisplay?.append(record)
                }
            }
            filterButton.image = #imageLiteral(resourceName: "Filter icon filled")
            self.navigationItem.title = "\(String(describing: currentFilter).capitalized)s"
        }
        let indices: IndexSet = [0]
        tableView.reloadSections(indices, with: .fade)
    }
    
    
    @IBAction func filterRecords(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Filter records by:", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Runs", style: .default, handler: { (action) in
            self.currentFilter = .run
            self.reloadRecordsToDisplay()
        }))
        actionSheet.addAction(UIAlertAction(title: "Swims", style: .default, handler: { (action) in
            self.currentFilter = .swim
            self.reloadRecordsToDisplay()
        }))
        actionSheet.addAction(UIAlertAction(title: "Triathlons", style: .default, handler: { (action) in
            self.currentFilter = .triathlon
            self.reloadRecordsToDisplay()
        }))
        actionSheet.addAction(UIAlertAction(title: "All", style: .cancel, handler: { (action) in
            self.currentFilter = .none
            self.reloadRecordsToDisplay()
        }))
        actionSheet.view.tintColor = self.view.tintColor
        
        if let popover = actionSheet.popoverPresentationController{
            popover.barButtonItem = sender as? UIBarButtonItem
            actionSheet.addAction(UIAlertAction(title: "All", style: .default, handler: { (action) in
                self.currentFilter = .none
                self.reloadRecordsToDisplay()
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func sortRecords(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Sort records by:", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Date (newest)", style: .default, handler: { (action) in
            self.currentSort = "Date (newest)"
            self.reloadRecordsToDisplay()
        }))
        actionSheet.addAction(UIAlertAction(title: "Date (oldest)", style: .default, handler: { (action) in
            self.currentSort = "Date (oldest)"
            self.reloadRecordsToDisplay()
        }))
        actionSheet.addAction(UIAlertAction(title: "Type", style: .default, handler: { (action) in
            self.currentSort = "Type"
            self.reloadRecordsToDisplay()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.view.tintColor = self.view.tintColor
        
        if let popover = actionSheet.popoverPresentationController{
            popover.barButtonItem = sender as? UIBarButtonItem
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let record = recordsToDisplay![indexPath.row]
        let indexInRecords = self.records.index(of: record)!
        
        if editingStyle == .delete{
            let alert = UIAlertController(title: "Delete record?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Just this record", style: .destructive, handler: { (action) in
                let worse = record.worse
                if worse != nil{
                    worse!.better = nil
                    //Replace the record in the records array and reload
                    self.records[indexInRecords] = worse!
                }else{
                    self.records.remove(at: indexInRecords)
                }
                self.reloadRecordsToDisplay()
                
                do{
                    managedContext.delete(record)
                    try managedContext.save()
                }catch _{
                    print("uh oh")
                }
                
            }))
            alert.addAction(UIAlertAction(title: "All records for this distance", style: .destructive, handler: { (action) in
                self.records.remove(at: indexInRecords)
                //Cycle through each worse record and delete it
                var currentRecord = record.worse
                var worseRecord:Record?
                managedContext.delete(record)
                while currentRecord != nil{
                    worseRecord = currentRecord?.worse
                    managedContext.delete(currentRecord!)
                    currentRecord = worseRecord
                }
                do{
                    try managedContext.save()
                }catch _{
                    print("uh oh")
                }
                self.reloadRecordsToDisplay()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recordsToDisplay?.count == 0{
            noRecordsLabel.isHidden = false
        }else{
            noRecordsLabel.isHidden = true
        }
        return recordsToDisplay!.count
    }

    @objc func refreshTableView(){
        self.fetchRecordsFromCoreData()
        reloadRecordsToDisplay()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Cell is normal
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordCell
        let record = recordsToDisplay![indexPath.row]
        let contentView = cell.customContentView
        contentView?.index = indexPath.row
        contentView?.delegate = self
        contentView?.shouldAnimate = true
        cell.distanceNameLabel.text = record.distance_name
        cell.distanceTimeLabel.text = record.time_string
        let date = record.date as Date?
        if date != nil{
            cell.dateLabel.text = DateFormatter.localizedString(from: date!, dateStyle: .medium, timeStyle: .none)
        }else{
            cell.dateLabel.text = ""
        }
        cell.activityTypeImageView.image = UIImage(recordType: RecordType(rawValue: Int(record.activity_type))!)
        
        return cell
        
    }
    
    func animateTable(){
        let cells = tableView.visibleCells
        let tableHeight = tableView.bounds.size.height
        
        for cell in cells{
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        for cell in cells{
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransform.identity
                }, completion: nil)
            index += 1
        }
    }

    //MARK: Segue and RecordCellContentViewDelegate
    func didSelectCell(index: Int) {
        self.performSegue(withIdentifier: "showRecordDetail", sender: index)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecordDetail"{
            guard let destVC = segue.destination as? RecordDetailViewController else{return}
            if let index = sender as? Int{
                destVC.record = self.recordsToDisplay![index]
            }else if let cell = sender as? RecordCell{
                //For 3D touch
                destVC.record = self.records[tableView.indexPath(for: cell)!.row]
            }
        }
    }
 
}

extension Notification.Name{
    static let RefreshRecords = NSNotification.Name("RefreshRecords")
    static let RefreshRecordDetail = NSNotification.Name("RefreshRecordDetail")
    static let ViewRecord = NSNotification.Name("ViewRecord")
}
