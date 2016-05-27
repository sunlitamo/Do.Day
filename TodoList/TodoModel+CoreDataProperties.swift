//
//  TodoModel+CoreDataProperties.swift
//  TodoList
//
//  Created by Sunlit.Amo on 26/05/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import UIKit
extension TodoModel {

    @NSManaged var image: NSData?
    @NSManaged var taskDate: NSDate?
    @NSManaged var title: String?

    convenience init(image:UIImage?,title:String,date: (year:Int,month:Int,day:Int)){
    
        self.image = UIImagePNGRepresentation(image!)
        self.taskDate = CalendarHelper.dateConverter_NSdate(date)
        self.title = title
    }
    
}
