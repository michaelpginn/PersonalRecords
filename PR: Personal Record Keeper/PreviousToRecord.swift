//
//  PreviousToRecord.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 6/1/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData

class PreviousToRecord: CurrentToRecord {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        //Shouldn't matter what type the old thing is
        let newRecord = CurrentToRecord.createRecord(fromInstance: sInstance, manager: manager)
        
        newRecord.setValue(sInstance.value(forKey: "activity"), forKey: "activity_type")
        manager.associate(sourceInstance: sInstance, withDestinationInstance: newRecord, for: mapping)
        print("Created dest instance from previous")
    }
    
    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        let instance = dInstance as! Record
        guard let instanceName = instance.distance_name else{return}
        
        //Get all records with same name
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:"Record") //get the list of records
        let predicate = NSPredicate(format: "distance_name == %@", instanceName)
        fetchRequest.predicate = predicate
        
        var fetchedResults:[Record]? = nil
        do{
            fetchedResults = try managedContext.fetch(fetchRequest) as? [Record]
        } catch _{
            print("Something went wrong getting words")
        }
        if (fetchedResults != nil){
            //Sort by date and then find the first record
            fetchedResults = fetchedResults?.sorted()
            
            //hopefully now the dates are in ascending order but who even knows
            var currentRecord = fetchedResults!.last!
            while currentRecord.better != nil && currentRecord.better! > instance{
                currentRecord = currentRecord.better!
            }
            //now we should have the right place
            currentRecord.better = instance
            instance.worse = currentRecord
        }
  
    }
}
