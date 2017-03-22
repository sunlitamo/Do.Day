//
//  TodoListHelper.swift
//  TodoList
//
//  Created by Sunlit.Amo on 07/05/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit

class TodoListHelper {
    
    static func customSnapshotFromView(_ inputView:UIView!)->UIView{
        UIGraphicsBeginImageContextWithOptions(inputView.frame.size, false, 0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snapshot = UIImageView(image:image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0
        snapshot.frame = CGRect(x: inputView.frame.origin.x, y: inputView.frame.origin.y, width: inputView.frame.width, height: inputView.frame.height)
        return snapshot
    }
    static func getWeekDays() -> [String]{
        
        var WeekDays = [String]()
        
        if LanguageHelper.isCN() {
            WeekDays.append("日")
            WeekDays.append("一")
            WeekDays.append("二")
            WeekDays.append("三")
            WeekDays.append("四")
            WeekDays.append("五")
            WeekDays.append("六")
        }
        else{
            WeekDays.append("S")
            WeekDays.append("M")
            WeekDays.append("T")
            WeekDays.append("W")
            WeekDays.append("T")
            WeekDays.append("F")
            WeekDays.append("S")
        }
        return WeekDays
    }
}
