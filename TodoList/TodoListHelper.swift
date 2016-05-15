//
//  TodoListHelper.swift
//  TodoList
//
//  Created by Sunlit.Amo on 07/05/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit

class TodoListHelper {
    
    static func customSnapshotFromView(inputView:UIView!)->UIView{
        UIGraphicsBeginImageContextWithOptions(inputView.frame.size, false, 0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snapshot = UIImageView(image:image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0
        snapshot.frame = CGRectMake(inputView.frame.origin.x, inputView.frame.origin.y, inputView.frame.width, inputView.frame.height)
        return snapshot
    }
    static func getWeekDays() -> [String]{
        
        var WeekDays = [String]()
        
        WeekDays.append("S")
        WeekDays.append("M")
        WeekDays.append("T")
        WeekDays.append("W")
        WeekDays.append("T")
        WeekDays.append("F")
        WeekDays.append("S")
        
        return WeekDays
    }
}
