//
//  RecordCellContentView.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 6/7/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

protocol RecordCellContentViewDelegate: RoundedRectViewDelegate{
    func didSelectCell(index:Int)
}


final class RecordCellContentView: RoundedRectView {
    var index:Int?
    private var cellDelegate:RecordCellContentViewDelegate?
    override var delegate:RoundedRectViewDelegate? {
        get{
            return cellDelegate
        }
        set{
            if newValue is RecordCellContentViewDelegate?{
                cellDelegate = newValue as? RecordCellContentViewDelegate
            }else{
                print("oh no")
            }
        }
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2, animations: {
            for view in self.subviews{
                view.layer.opacity = 1.0
            }
        })
        if cellDelegate != nil && self.index != nil{
            cellDelegate?.didSelectCell(index: self.index!)
        }
    }
}
