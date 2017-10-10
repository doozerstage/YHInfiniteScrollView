//
//  Helper.swift
//  YHInfiniteScrollView_Example
//
//  Created by DEV_TEAM1_IOS on 10/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

func YHLayoutConstraint(_ view1: UIView, _ attr1: NSLayoutAttribute, _ relatedBy: NSLayoutRelation, _ view2: UIView?, _ attr2: NSLayoutAttribute, _ multiplier: CGFloat, _ constant: CGFloat) -> NSLayoutConstraint {
    
    var result: NSLayoutConstraint
    
    view1.translatesAutoresizingMaskIntoConstraints = false
    
    if view2 != nil {
        view2?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    
    result = NSLayoutConstraint.init(item: view1, attribute: attr1, relatedBy: relatedBy, toItem: view2, attribute: attr2, multiplier: multiplier, constant: constant)
    
    if view1.superview != nil{
        view1.superview?.addConstraint(result)
    } else {
        
        view2?.superview?.addConstraint(result)
    }
    
    return result
}
