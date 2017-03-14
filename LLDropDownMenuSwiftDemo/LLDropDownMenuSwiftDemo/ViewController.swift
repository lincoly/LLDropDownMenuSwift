//
//  ViewController.swift
//  LLDropDownMenuSwiftDemo
//
//  Created by lin on 2017/3/13.
//  Copyright © 2017年 lin. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor(colorLiteralRed: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
        let menu = LLDropDownMenu(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 38))
        
        var arr1 = [LLOptionItem]()
        
        for index in 0...8 {
            
            let item0 = LLOptionItem()
            item0.title = "标题三级\(index)"
            item0.items = nil
            
            arr1.append(item0)
        }
        
        var arr = [LLOptionItem]()
        
        for index in 0...5 {
            
            let item0 = LLOptionItem()
            item0.title = "标题--\(index)"
            
            if index == 3 || index == 2 || index == 4 {
                item0.items = arr1
            }
            
            
            arr.append(item0)
        }
        
        
        
        let item = LLOptionItem()
        item.title = "标题"
        item.items = arr
        menu.itemsData = [[item,item,item,item,item], [item,item,item,item], [item,item,item]]
        menu.delegate = self
        
        view.addSubview(menu)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ViewController: LLDropDownMenuDelegate {
    
    func menu(_ menu: LLDropDownMenu, didSelectIndexPath: LLIndexPath) {
        print(didSelectIndexPath.selectedText)
    }
}
