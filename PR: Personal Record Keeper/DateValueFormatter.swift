//
//  DateValueFormatter.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/18/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import Charts

final class DateValueFormatter: NSObject, IAxisValueFormatter {
    var dateArray:[Date?] = []
    
    convenience init(dates:[Date?]){
        self.init()
        self.dateArray = dates
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        
        if index >= 0 && index < dateArray.count, let date = dateArray[index]{
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }else{
            return ""
        }
    }
}
