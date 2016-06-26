//
//  LanguageHelper.swift
//  Do.Day
//
//  Created by Sunlit.Amo on 26/06/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import Foundation


class LanguageHelper {
    
    static func isCN()->Bool{
        
        switch(NSLocale.preferredLanguages()[0]){
            
        case "zh-Hans-CN","zh-Hant-CN","zh-HK":
            return true
        default:
            return false
        }
    }
}