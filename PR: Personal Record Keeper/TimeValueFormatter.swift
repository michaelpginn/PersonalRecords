//
//  TimeValueFormatter.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/17/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import Charts

final class TimeValueFormatter: NSObject, IAxisValueFormatter, IValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let fracPart = value.truncatingRemainder(dividingBy: 1.0)
        var remainingSecs = Int(value - fracPart)
        var hours = 0
        var minutes = 0
        
        if remainingSecs > 3600{
            hours = remainingSecs / 3600
            remainingSecs %= 3600
        }
        if remainingSecs > 60{
            minutes = remainingSecs / 60
            remainingSecs %= 60
        }
        
        let secondsPart = fracPart == 0 ? "\(remainingSecs)" : "\(Double(remainingSecs) + fracPart)"
        
        if hours == 0 && minutes == 0{
            return "\(value) s"
        }else{
            //could be mm:ss or hh:mm:ss
            var returnString = ""
            if remainingSecs < 10{
                returnString = "\(minutes):0\(secondsPart)"
            }else{
                returnString = "\(minutes):\(secondsPart)"
            }
            
            if hours != 0{
                //hh:mm:ss
                if minutes < 10{
                    returnString = "\(hours):0" + returnString
                }else{
                    returnString = "\(hours):" + returnString
                }
            }
            return returnString
        }
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return self.stringForValue(entry.y, axis: nil)
    }
}
