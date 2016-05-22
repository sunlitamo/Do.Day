//
//  CalendarViewController.swift
//  TodoList
//
//  Created by Sunlit.Amo on 07/05/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit

class CalendarHelper{
    
    static func dateFormatter(date: (year:Int,month:Int,day:Int))->String{
        
        return "\(date.year)-\(date.month)-\(date.day)"
        
    }
    
    static func loadCalendar(currentYear:Int,currentMonth:Int)->(year:Int,month:Int,firstDay:Int,daysCount:Int){
        
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        let components: NSDateComponents = gregorian.components([.Year,.Month,.Weekday],fromDate: NSDate(year: currentYear,month: currentMonth))
        let range = gregorian.rangeOfUnit(.Day, inUnit: .Month, forDate: NSDate(year: currentYear,month: currentMonth))
        return (components.year,components.month,components.weekday,range.length)
    }
    
    static func getCurrentDate()->(year:Int,month:Int,firstDay:Int,daysCount:Int){
        
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        let components: NSDateComponents = gregorian.components([.Year,.Month,.Weekday],fromDate: NSDate())
        let range = gregorian.rangeOfUnit(.Day, inUnit: .Month, forDate: NSDate())
        return (components.year,components.month,components.weekday,range.length)
    }
    static func formatDate(month:Int)->String{
        switch month {
        case 1:
            return "Janurary"
        case 2:
            return "Feburary"
            
        case 3:
            return "March"
            
        case 4:
            return "April"
            
        case 5:
            return "May"
            
        case 6:
            return "June"
            
        case 7:
            return "July"
            
        case 8:
            return "August"
            
        case 9:
            return "September"
            
        case 10:
            return "October"
            
        case 11:
            return "November"
            
        case 12:
            return "December"
            
        default:
            return ""
        }
    }
}
extension NSDate{
    
    convenience
    init(year:Int,month:Int){
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let d = dateStringFormatter.dateFromString("\(year)-\(month)-01")
        self.init(timeInterval:0, sinceDate:d!)
    }
}

