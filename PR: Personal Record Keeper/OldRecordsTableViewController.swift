//
//  OldRecordsTableViewController.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/25/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

final class OldRecordsTableViewController: UITableViewController, RecordCellContentViewDelegate {
    var records:[Record] = []
    var firstRecord:Record?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = records.first?.distance_name ?? ""
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadRecords), name: .RefreshRecords, object: nil)
        loadRecords()
    }
    
    @objc private func loadRecords(){
        records = []
        if var currentRecord = firstRecord{
            records.append(currentRecord)
            while currentRecord.worse != nil {
                currentRecord = currentRecord.worse!
                records.append(currentRecord)
            }
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "oldRecordCell", for: indexPath) as! OldRecordCell
        let record = records[indexPath.row]
        
        let contentView = cell.customContentView
        if indexPath.row != 0{
            contentView?.index = indexPath.row
            contentView?.delegate = self
            contentView?.shouldAnimate = true
        }else{
            contentView?.layer.borderColor = UIColor.PRColors.prBlue.cgColor
            contentView?.layer.borderWidth = 1.5
        }
        
        cell.distanceTimeLabel.text = record.time_string
        cell.dateLabel.text = DateFormatter.localizedString(from: record.date! as Date, dateStyle: .medium, timeStyle: .none)
        
        
        return cell
    }
    
    func didSelectCell(index: Int) {
        self.performSegue(withIdentifier: "showOldRecordDetail", sender: index)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOldRecordDetail"{
            guard let destVC = segue.destination as? RecordDetailViewController else{return}
            if let index = sender as? Int{
                destVC.record = self.records[index]
            }else if let cell = sender as? OldRecordCell{
                //For 3D touch
                destVC.record = self.records[tableView.indexPath(for: cell)!.row]
            }
            destVC.isOldRecord = true
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showOldRecordDetail", let cell = sender as? OldRecordCell{
            if tableView.indexPath(for: cell)?.row == 0{
                return false //don't want the first cell seguing
            }else{
                return true
            }
        }else{
            return true
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
