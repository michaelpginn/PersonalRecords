//
//  Record+CoreDataProperties.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/5/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//
//

import Foundation
import CoreData


extension Record: Comparable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var activity_type: Int32
    @NSManaged public var date: NSDate?
    @NSManaged public var distance_meters: NSNumber?
    @NSManaged public var distance_name: String?
    @NSManaged public var image: NSData?
    @NSManaged public var location: String?
    @NSManaged public var notes: String?
    @NSManaged public var time_seconds: NSNumber?
    @NSManaged public var time_string: String?
    @NSManaged public var better: Record?
    @NSManaged public var worse: Record?
    
    public static func < (lhs: Record, rhs: Record) -> Bool {
        guard let timeA = lhs.time_seconds, let timeB = rhs.time_seconds else{return false}
        return timeA.compare(timeB) == ComparisonResult.orderedAscending
    }
    
    public static func == (lhs: Record, rhs: Record) -> Bool {
        guard let timeA = lhs.time_seconds, let timeB = rhs.time_seconds else{return false}
        return timeA.isEqual(to: timeB)
    }
}
