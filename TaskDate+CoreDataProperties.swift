//
//  TaskDate+CoreDataProperties.swift
//  TodoList
//
//  Created by Sunlit.Amo on 05/06/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TaskDate {

    @NSManaged var taskDate: NSDate?
    @NSManaged var todoModel: TodoModel?

}
