//
//  TodoModel.swift
//  TodoList
//
//  Created by Sunlit.Amo on 19/04/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit

class TodoItemMenu: NSObject {
    
    var image : UIImage
    var title : String
    
    init(title: String, image: UIImage) {
        self.title = title
        self.image = image
    }
    
    static func getAllTodoItems() -> [TodoItemMenu]{
        
        var TodoItemArray = [TodoItemMenu]()
        
        if LanguageHelper.isCN() {
            TodoItemArray.append(TodoItemMenu(title: "一般",image: UIImage(named: "general")!))
            TodoItemArray.append(TodoItemMenu(title: "餐饮",image: UIImage(named: "meal")!))
            TodoItemArray.append(TodoItemMenu(title: "旅行",image: UIImage(named: "travel")!))
            TodoItemArray.append(TodoItemMenu(title: "孩童",image: UIImage(named: "kids")!))
            TodoItemArray.append(TodoItemMenu(title: "公务",image: UIImage(named: "business")!))
            TodoItemArray.append(TodoItemMenu(title: "健身",image: UIImage(named: "gym")!))
            TodoItemArray.append(TodoItemMenu(title: "购物",image: UIImage(named: "shopping")!))
            TodoItemArray.append(TodoItemMenu(title: "学习",image: UIImage(named: "study")!))
            TodoItemArray.append(TodoItemMenu(title: "干洗",image: UIImage(named: "wash")!))
            TodoItemArray.append(TodoItemMenu(title: "约会",image: UIImage(named: "date")!))
            TodoItemArray.append(TodoItemMenu(title: "冥想",image: UIImage(named: "calm")!))
            TodoItemArray.append(TodoItemMenu(title: "账单",image: UIImage(named: "salary")!))
            TodoItemArray.append(TodoItemMenu(title: "游泳",image: UIImage(named: "swim")!))
            TodoItemArray.append(TodoItemMenu(title: "茶歇",image: UIImage(named: "tea")!))
            TodoItemArray.append(TodoItemMenu(title: "轻松",image: UIImage(named: "relax")!))      }
        else{
            TodoItemArray.append(TodoItemMenu(title: "General",image: UIImage(named: "general")!))
            TodoItemArray.append(TodoItemMenu(title: "Meal",image: UIImage(named: "meal")!))
            TodoItemArray.append(TodoItemMenu(title: "Travel",image: UIImage(named: "travel")!))
            TodoItemArray.append(TodoItemMenu(title: "Childcare",image: UIImage(named: "kids")!))
            TodoItemArray.append(TodoItemMenu(title: "Business",image: UIImage(named: "business")!))
            TodoItemArray.append(TodoItemMenu(title: "Gym",image: UIImage(named: "gym")!))
            TodoItemArray.append(TodoItemMenu(title: "Shopping",image: UIImage(named: "shopping")!))
            TodoItemArray.append(TodoItemMenu(title: "Study",image: UIImage(named: "study")!))
            TodoItemArray.append(TodoItemMenu(title: "Laundry",image: UIImage(named: "wash")!))
            TodoItemArray.append(TodoItemMenu(title: "Date",image: UIImage(named: "date")!))
            TodoItemArray.append(TodoItemMenu(title: "Meditation",image: UIImage(named: "calm")!))
            TodoItemArray.append(TodoItemMenu(title: "Bill",image: UIImage(named: "salary")!))
            TodoItemArray.append(TodoItemMenu(title: "Swimming",image: UIImage(named: "swim")!))
            TodoItemArray.append(TodoItemMenu(title: "Tea Break",image: UIImage(named: "tea")!))
            TodoItemArray.append(TodoItemMenu(title: "Relax",image: UIImage(named: "relax")!))

        }
        return TodoItemArray
    }
    
}
struct menu {
    
}