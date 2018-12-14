//
//  CoreDataManager.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/5/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import MobileCoreServices

final class CoreDataManager: NSObject {
    class func saveRecordToCoreData(_ record:Record, context:NSManagedObjectContext){
        //we need to find other records for the same distance
        
        //create relationships
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Record")
        let predicate = NSPredicate(format: "distance_name == %@", record.distance_name!)
        fetchRequest.predicate = predicate
        
        var fetchedResults:[Record]? = nil
        do{
            fetchedResults = try context.fetch(fetchRequest) as? [Record]
        } catch _{
            print("Something went wrong getting words")
        }
        if var results = fetchedResults, results.count > 1{
            //remove our new record from this list
            for result in results{
                if result.isEqual(record){
                    results.remove(at: results.index(of: result)!)
                }
            }
            print("found \(results.count) old records")
            //sort by time and find our spot
            results = results.sorted() //best to worst
            var worseRecord:Record? = results.first!
            var betterRecord:Record? = nil
            //find spot to insert
            while (record > worseRecord! && worseRecord!.worse != nil){
                betterRecord = worseRecord
                worseRecord = worseRecord!.worse!
            }
            //now we have the right spot
            //check if record is still worse than worst record
            if record > worseRecord!{
                record.better = worseRecord
                worseRecord?.worse = record
            }else{
                record.worse = worseRecord
                worseRecord?.better = record
                record.better = betterRecord
                betterRecord?.worse = record
            }
        }
        
        do{
            try context.save()
            print("Saved record: \(record)")
            if record.better == nil{
                self.createCoreSpotlightItem(record: record)
            }
        }catch let e as NSError{
            print(e)
        }
    }
    
    private class func createCoreSpotlightItem(record:Record){
        let searchableIndex = CSSearchableIndex.default()
        searchableIndex.deleteSearchableItems(withIdentifiers: [record.distance_name!], completionHandler: nil)
        
        let attrSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeCalendarEvent as String)
        attrSet.title = record.distance_name
        let dateString:String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: record.date! as Date)
        }()
        let typeString:String = {
            let type = RecordType(rawValue: Int(record.activity_type))!
            return String(describing: type).capitalized
        }()
        attrSet.contentDescription = "\(typeString)"
        attrSet.namedLocation = "\(record.time_string!) on \(dateString)" //because i can't use two lines otherwise
        attrSet.keywords = {
            var keywords = [typeString]
            if record.location != nil {keywords.append(record.location!)}
            return keywords
        }()
        attrSet.addedDate = record.date as Date?
        let item = CSSearchableItem(uniqueIdentifier: record.distance_name, domainIdentifier: nil, attributeSet: attrSet)
        
        searchableIndex.indexSearchableItems([item], completionHandler: {(error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
}
