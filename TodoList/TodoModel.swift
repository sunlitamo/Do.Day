//
//  TodoModel.swift
//  TodoList
//
//  Created by Sunlit.Amo on 19/04/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit

class TodoModel: NSObject {

    
    var image : UIImage
    var title : String
    var date : (year:Int,month:Int,day:Int)
    
    init(image: UIImage, title: String, date: (year:Int,month:Int,day:Int)) {
        self.image = image
        self.title = title
        self.date = date
    }
    
}
