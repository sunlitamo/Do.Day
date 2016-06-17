//
//  Constants.swift
//  TodoList
//
//  Created by Sunlit.Amo on 16/06/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit

struct Constants {

    static let RELOAD = "reload"
    
    static let SEGUE_NEW_ITEM = "addNewItem"
    
    static let CELL_TODO = "todoCell"
    static let CELL_CALENDAR = "calendarCell"
    static let CELL_TODO_OPTION = "todoCollectionCell"

    
    static let ENTITY_MODEL_TODO = "TodoModel"
    
    
    
    
    
    
    
    
    
    
    

    
  
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}
