//
//  TodoModel.swift
//  TodoList
//
//  Created by Sunlit.Amo on 19/04/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit

class TodoModel: NSObject {

    var id : String
    var image : UIImage
    var title : String
    var date : NSDate
    
    init(id: String, image: UIImage, title: String, date: NSDate) {
        self.id = id
        self.image = image
        self.title = title
        self.date = date
    }
    
}
