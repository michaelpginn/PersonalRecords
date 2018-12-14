//
//  RoundedRectView.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/13/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

protocol RoundedRectViewDelegate: AnyObject{
    func didTriggerAction(sender:RoundedRectView)
}

extension RoundedRectViewDelegate{
    func didTriggerAction(sender:RoundedRectView){
        
    }
}

class RoundedRectView: UIView {
    var shouldAnimate:Bool = false
    var delegate: RoundedRectViewDelegate?
    
    /**
     Initializes a RoundedRectView with a background color and height/width constraints (height optional)
     
     - parameter size: (width, height) of the view. Height is optional.
     */
    convenience init(size:(CGFloat, CGFloat?), color:UIColor){
        self.init()
        self.backgroundColor = color
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.0))
        if size.1 != nil{
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.1!))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }

    private func setup(){
        //Custom setup
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.layer.shadowOpacity = 0.3
        self.layer.allowsGroupOpacity = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //Animation stuff
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if shouldAnimate{
            UIView.animate(withDuration: 0.01, delay: 0.0, options: .curveEaseOut, animations: {
                for view in self.subviews{
                    view.layer.opacity = 0.5
                }
            }, completion: nil)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if shouldAnimate{
            UIView.animate(withDuration: 0.2, animations: {
                for view in self.subviews{
                    view.layer.opacity = 1.0
                }
            })
            if delegate != nil{
                delegate?.didTriggerAction(sender: self)
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if shouldAnimate{
            UIView.animate(withDuration: 0.2, animations: {
                for view in self.subviews{
                    view.layer.opacity = 1.0
                }
            })
        }
    }
}
