//
//  PersonalRecordKeeperTests.swift
//  PR: Personal Record KeeperTests
//
//  Created by Michael Ginn on 7/17/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import XCTest
@testable import PR__Personal_Record_Keeper

class PersonalRecordKeeperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTimeFormatter(){
        let formatter = TimeValueFormatter()
        let times = [80, 4000, 33.0, 2, 38, 61]
        for time in times{
            print("lalalalalaal")
            print(formatter.stringForValue(time, axis: nil))
        }
    }
}
