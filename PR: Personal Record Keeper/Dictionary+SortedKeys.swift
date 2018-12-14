//
//  Dictionary+SortedKeys.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/5/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import Foundation

extension Dictionary where Value:Comparable{
    func sortedKeys()->[Key]{
        return Array(keys).sorted(){
            guard let obj1 = self[$0] else{return false}
            guard let obj2 = self[$1] else{return false}
            return obj1 < obj2
        }
    }
}
