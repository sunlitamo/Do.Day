//
//  TodoCell.swift
//  TodoList
//
//  Created by Sunlit.Amo on 20/04/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit


class CalendarCell: UICollectionViewCell {

    @IBOutlet var dateText: UILabel!
    var isCellSelected:Bool?

    override func layoutSubviews() {
       
        var contentViewFrame = self.contentView.frame
        
        if(DeviceType.IS_IPHONE_5){
            contentViewFrame.size.width = 33
            contentViewFrame.size.height = 28
        }
        
        if(DeviceType.IS_IPHONE_6){
            contentViewFrame.size.width = 38
            contentViewFrame.size.height = 33
        }
        
        if(DeviceType.IS_IPHONE_6P){
            contentViewFrame.size.width = 43
            contentViewFrame.size.height = 38
        }
        self.contentView.frame = contentViewFrame
    }
    
}