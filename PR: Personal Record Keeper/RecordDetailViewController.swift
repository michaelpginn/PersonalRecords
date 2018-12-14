//
//  RecordDetailViewController.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/12/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import Charts

final class RecordDetailViewController: UIViewController, ChartViewDelegate, RoundedRectViewDelegate {
    
    var record:Record?
    var oldRecords:[Record] = []
    var dataSet:LineChartDataSet? = nil
    var datesArray:[Date?] = []
    
    var isOldRecord:Bool = false
    
    @IBOutlet weak var scrollView: RecordDetailScrollView!
    @IBOutlet weak var addTimeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        scrollView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        
        loadViews()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadViews), name: .RefreshRecordDetail, object: nil)
        
        scrollView.row_viewOld.delegate = self
        if isOldRecord{
            scrollView.row_viewOld.isHidden = true
            addTimeButton.isEnabled = false
            addTimeButton.title = ""
        }
    }
    
    @objc func reloadViews(){
        while record?.better != nil{
            record = record?.better
        }
        UIView.transition(with: self.view, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            self.loadViews()
            }, completion: nil)
    }
    
    private func loadViews(){
        if record != nil{
            scrollView.distanceLabel.text = record!.distance_name
            if let recordType = RecordType(rawValue: Int(record!.activity_type)){
                scrollView.setTypeImage(type: recordType)
            }
            scrollView.timeValueLabel.text = record?.time_string
            
            if let recordDate = record!.date as Date?{
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                scrollView.dateValueLabel.text = formatter.string(from: recordDate)
            }else{
                scrollView.dateValueLabel.text = "---"
            }
            
            if record!.location != nil && record!.location!.count > 0{
                scrollView.locationValueLabel.text = record!.location
            }else{
                scrollView.locationValueLabel.text = "---"
            }
            
            if record!.notes != nil && record!.notes!.count > 0{
                let notes = record!.notes?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                scrollView.notesValueLabel.text = notes
            }else{
                //we need to remove the notes view
                scrollView.row_notes.removeFromSuperview()
                scrollView.row_basicInfo.bottomAnchor.constraint(equalTo: scrollView.row_graph.topAnchor, constant: -8.0).isActive = true
            }
            
            oldRecords = []
            datesArray = []
            loadPreviousRecords()
            
            let lineChart = scrollView.lineChartView
            lineChart.data = LineChartData(dataSet: self.dataSet)
            lineChart.xAxis.axisMinimum = -0.8
            lineChart.xAxis.axisMaximum = lineChart.data!.xMax + 0.45
            lineChart.delegate = self
        }
    }
    
    
    private func loadPreviousRecords(){
        var currentRecord = record!
        oldRecords.append(currentRecord)
        while currentRecord.worse != nil {
            currentRecord = currentRecord.worse!
            oldRecords.append(currentRecord)
        }
        
        let values = (0..<oldRecords.count).map { (i) -> ChartDataEntry in
            let index = Double(i)
            let val = oldRecords[oldRecords.count - i - 1].time_seconds as! Double
            let date = oldRecords[oldRecords.count - i - 1].date as Date?
            datesArray.append(date)
            return ChartDataEntry(x: index, y: val, data: date as AnyObject)
            
        }
        self.dataSet = {
            let set = LineChartDataSet(values: values, label: "hello blop")
            set.setCircleColor(UIColor.PRColors.prGreen)
            set.circleRadius = 6.0
            set.drawCircleHoleEnabled = false
            set.valueFormatter = TimeValueFormatter()
            set.setColor(UIColor.lightGray)
            set.drawValuesEnabled = false
            return set
        }()
    }

    //For rounded rect
    func didTriggerAction(sender: RoundedRectView) {
        if sender == scrollView.row_viewOld{
            self.performSegue(withIdentifier: "showOldRecords", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBetterTime"{
            let dest = segue.destination as! NewRecordViewController
            dest.mode = .betterTime
            dest.type = RecordType(rawValue: Int(record!.activity_type))
            dest.distanceName = self.record?.distance_name
            dest.distanceLength = self.record?.distance_meters as! Double?
        }else if segue.identifier == "showOldRecords"{
            let dest = segue.destination as! OldRecordsTableViewController
            dest.firstRecord = self.record
        }
    }
    @IBAction func deleteRecord(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        guard let recordToDelete = self.record else{return}
        
        let alert = UIAlertController(title: "Delete record?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Just this record", style: .destructive, handler: { (action) in
            
            recordToDelete.worse!.better = recordToDelete.better
            if recordToDelete.better != nil{
                recordToDelete.better!.worse = recordToDelete.worse
            }
            
            do{
                managedContext.delete(recordToDelete)
                try managedContext.save()
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: .RefreshRecords, object: nil)

            }catch _{
                print("uh oh")
            }
            
        }))
        alert.addAction(UIAlertAction(title: "This and all older records", style: .destructive, handler: { (action) in
            //Cycle through each worse record and delete it
            var currentRecord = recordToDelete.worse
            var worseRecord:Record?
            managedContext.delete(recordToDelete)
            while currentRecord != nil{
                worseRecord = currentRecord?.worse
                managedContext.delete(currentRecord!)
                currentRecord = worseRecord
            }
            do{
                try managedContext.save()
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: .RefreshRecords, object: nil)
            }catch _{
                print("uh oh")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
