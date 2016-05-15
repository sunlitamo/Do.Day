//
//  TodoModel.swift
//  TodoList
//
//  Created by Sunlit.Amo on 19/04/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit

class TodoItemList: NSObject {
    
    var image : UIImage
    var title : String
    
    init(title: String, image: UIImage) {
        self.title = title
        self.image = image
    }
    
    static func getAllTodoItems() -> [TodoItemList]{
    
        var TodoItemArray = [TodoItemList]()

        TodoItemArray.append(TodoItemList(title: "General",image: UIImage(named: "general")!))
        TodoItemArray.append(TodoItemList(title: "Meal",image: UIImage(named: "meal")!))
        TodoItemArray.append(TodoItemList(title: "Travel",image: UIImage(named: "travel")!))
        TodoItemArray.append(TodoItemList(title: "Childcare",image: UIImage(named: "kids")!))
        TodoItemArray.append(TodoItemList(title: "Business",image: UIImage(named: "business")!))
        TodoItemArray.append(TodoItemList(title: "Gym",image: UIImage(named: "gym")!))
        TodoItemArray.append(TodoItemList(title: "Shopping",image: UIImage(named: "shopping")!))
        TodoItemArray.append(TodoItemList(title: "Study",image: UIImage(named: "study")!))
        TodoItemArray.append(TodoItemList(title: "Laundry",image: UIImage(named: "wash")!))
        TodoItemArray.append(TodoItemList(title: "Date",image: UIImage(named: "date")!))
        TodoItemArray.append(TodoItemList(title: "Swimming",image: UIImage(named: "swim")!))
        TodoItemArray.append(TodoItemList(title: "Bill",image: UIImage(named: "salary")!))
        TodoItemArray.append(TodoItemList(title: "Meditation",image: UIImage(named: "calm")!))
        TodoItemArray.append(TodoItemList(title: "Tea Break",image: UIImage(named: "tea")!))
        TodoItemArray.append(TodoItemList(title: "Relax",image: UIImage(named: "relax")!))
        
        return TodoItemArray
    }
    
}