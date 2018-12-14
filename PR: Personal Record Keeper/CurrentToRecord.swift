//
//  CurrentToRecord.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 5/12/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData

class CurrentToRecord: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        //Shouldn't matter what type the old thing is
        let newRecord = CurrentToRecord.createRecord(fromInstance: sInstance, manager: manager)
        
        newRecord.setValue(sInstance.entity.name, forKey: "activity_type")
        manager.associate(sourceInstance: sInstance, withDestinationInstance: newRecord, for: mapping)
        print("Created dest instance from current")
    }
    
    class func createRecord(fromInstance sInstance:NSManagedObject, manager:NSMigrationManager)->NSManagedObject{
        let newRecord = NSEntityDescription.insertNewObject(forEntityName: "Record", into: manager.destinationContext)
        
        newRecord.setValue(sInstance.value(forKey: "image"), forKey: "image")
        newRecord.setValue(sInstance.value(forKey: "date"), forKey: "date")
        
        newRecord.setValue(sInstance.value(forKey: "time"), forKey: "time_string")
        if let timeString = sInstance.value(forKey: "time") as? String{
            let seconds = CurrentToRecord.convertTimeStringToDouble(timeString)
            newRecord.setValue(seconds, forKey: "time_seconds")
        }
        
        if let distanceName = sInstance.value(forKey: "name") as? String
        {
            newRecord.setValue(distanceName, forKey: "distance_name")
            //TODO: Determine distance based on name
            var allDistances = Distances.runs + Distances.swims + Distances.triathlons
            
            if allDistances.keys.contains(distanceName){
                newRecord.setValue(allDistances[distanceName], forKey: "distance_meters")
            }
        }
        
        return newRecord
    }
    
    class func convertTimeStringToDouble(_ timeString:String)->Double{
        //Convert the time string to seconds
        var totalSeconds = 0.0
        
        //convert to seconds
        var comps = timeString.components(separatedBy: ":")
        var mult = 1.0
        while comps.last != nil{
            if let num = Double(comps.last!){
                totalSeconds += num * mult
            }
            comps.removeLast()
            mult *= 60.0
        }
        return totalSeconds
    }
}

extension Dictionary{
    static func + (left:[Key:Value], right:[Key:Value])->[Key:Value]{
        var newDict:[Key:Value] = [:]
        for (k,v) in left{
            newDict[k] = v
        }
        for (k,v) in right{
            newDict[k] = v
        }
        
        return newDict
    }
}
