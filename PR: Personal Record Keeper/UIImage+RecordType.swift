//
//  UIImage+RecordType.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/25/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    convenience init(recordType:RecordType) {
        let images = ["Type_run", "Type_swim", "Type_triathlon"]
        if recordType != .none{
            self.init(named: images[recordType.rawValue])!
        }else{
            self.init()
        }
    }
}
