//
//  LLConfig.swift
//  LLDropDownMenuViewSwift
//
//  Created by lin on 2017/3/7.
//  Copyright © 2017年 lin. All rights reserved.
//

import UIKit

let MenuCellHeight : CGFloat = 43
let MenuBottomImageHeight : CGFloat = 21
let MenuDefaultFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 38)

let MenuSepartorColor = LL_HexRGB(0xDBDBDB)
let MenuCellBgColor = LL_HexRGB(0xF5F5F5)


func LL_HexRGB(_ hexColor:UInt32 , _ alpha:CGFloat) -> UIColor {
    
    let r = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((hexColor & 0x00FF00) >> 8) / 255.0
    let b = CGFloat(hexColor & 0x0000FF) / 255.0
    
    if #available(iOS 10.0, *) {
        return UIColor(displayP3Red: r, green: g, blue: b, alpha: alpha)
    } else {
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}

func LL_HexRGB(_ color:UInt32 ) -> UIColor {
    return LL_HexRGB(color, 1.0)
}
