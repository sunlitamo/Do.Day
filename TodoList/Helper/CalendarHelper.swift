//
//  CalendarViewController.swift
//  TodoList
//
//  Created by Sunlit.Amo on 07/05/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit

class CalendarHelper{
    
    static func dateFormatter(_ date: (year:Int,month:Int,day:Int))->String{
        
        return "\(date.year)-\(date.month)-\(date.day)"
        
    }
    
    static func loadCalendar(_ currentYear:Int,currentMonth:Int)->(year:Int,month:Int,firstDay:Int,daysCount:Int){
        
        let gregorian: Calendar = Calendar(identifier:Calendar.Identifier.gregorian)
        let components: DateComponents = (gregorian as NSCalendar).components([.year,.month,.weekday],from: dateConverter_NSdate((year:currentYear,month:currentMonth,day:1)))
        let range = (gregorian as NSCalendar).range(of: .day, in: .month, for: Date(year: currentYear,month: currentMonth))
        return (components.year!,components.month!,components.weekday!,range.length)
    }
    
    static func getCurrentDate()->(year:Int,month:Int,firstDay:Int,daysCount:Int){
        
        let gregorian: Calendar = Calendar(identifier:Calendar.Identifier.gregorian)
        let components: DateComponents = (gregorian as NSCalendar).components([.year,.month,.weekday],from: Date())
        let range = (gregorian as NSCalendar).range(of: .day, in: .month, for: Date())
        return (components.year!,components.month!,components.weekday!,range.length)
    }
    
    static func formatDate(_ month:Int)->String{
        return DateFormatter().monthSymbols[month-1]
    }
    static func dateConverter_NSdate(_ date: (year:Int,month:Int,day:Int))->Date{
        
        let strDate = "\(date.year)-\(date.month)-\(date.day)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dt = dateFormatter.date(from: strDate)!
        return dt
    }
    
    static func dateConverter_Closure(_ date:Date)->(Int,Int,Int){
        
        let gregorian: Calendar = Calendar(identifier:Calendar.Identifier.gregorian)
        let components: DateComponents = (gregorian as NSCalendar).components([.year,.month,.day],from: date)
        return (components.year!,components.month!,components.day!)
    }
    
    static func dateConverter_String(_ date:Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dt = dateFormatter.string(from: date)
        return dt
    }

    static func updateCalendar(_ year:Int,month:Int)->(Int,Int) {
        
        var date = (year:year,month:month)
        
        if (month > 12) {
            date.month=1;
            date.year+=1;
        }
        
        if(month<1){
            date.month=12;
            date.year-=1;
        }
        
        return date
    }
    
    static func dateConverter_GMT(_ dateStr:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        
        let date = dateFormatter.date(from: dateStr)
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "EEEE, MMM d, yyyy"
        let dt = dateFormatter1.string(from: date!)
        return dt
    }
    static func dateConverter_NSDate(_ dateStr:String)->Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        
        return dateFormatter.date(from: dateStr)!
    }
}

extension Date{
    
    
    init(year:Int,month:Int){
        
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let d = dateStringFormatter.date(from: "\(year)-\(month)-01")
        self.init(timeInterval:0, since:d!)
    }
}

