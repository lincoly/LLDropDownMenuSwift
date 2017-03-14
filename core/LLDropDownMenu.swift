//
//  LLDropDownMenu.swift
//  LLDropDownMenuViewSwift
//
//  Created by lin on 2017/3/7.
//  Copyright © 2017年 lin. All rights reserved.
//

import UIKit

struct LLIndexPath {
    var corlumn : Int!
    var row : Int?
    var item : Int?
    var index : Int?
    var selectedText = ""
}

protocol LLDropDownMenuDelegate {
    
    
    
    // 选中
    func menu(_ menu:LLDropDownMenu, didSelectIndexPath:LLIndexPath)
}

class LLDropDownMenu: UIView {

    var indicatorColor = LL_HexRGB(0xC8C8C8)    // 三角指示器颜色
    var textColor = LL_HexRGB(0x071D41)     // 正常title颜色
    var textSelectedColor = LL_HexRGB(0xFF7F0C)     // 选中title颜色
    var titleFont = UIFont.systemFont(ofSize: 14)   //title字体
    var textFont = UIFont.systemFont(ofSize: 14)    //选项字体
    
    var delegate: LLDropDownMenuDelegate?   // 代理
    
    var isShow = false
    
    
    // 数据数组
    var itemsData: [[LLOptionItem]]! {
        didSet {
            didSetItemData()
        }
    }
    var selectedIndexPaths : [LLIndexPath]! // 选中选项
    
    // 展示的IndexPath
    fileprivate var showIndexPath: LLIndexPath?
    
    // 列数
    fileprivate var numOfColumn: Int {
        return selectedIndexPaths.count
    }
    
    private let backGroundView = UIView()
    fileprivate let firstTalbeView = UITableView()
    fileprivate let secondTableView = UITableView()
    fileprivate let thirdTabelView = UITableView()
    fileprivate let bottomImageView = UIImageView()
    
    fileprivate var titleLayers: [CATextLayer]?
    fileprivate var indicatiorLayers : [CAShapeLayer]?
    fileprivate var bgLayers : [CALayer]?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configUI()
    }
    
    init() {
        super.init(frame: MenuDefaultFrame)
        
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func configUI() {
        
        let tableviewWidth = bounds.size.width / 3
     
        // 一级列表
        firstTalbeView.frame = CGRect(x: 0, y: frame.origin.y + frame.size.height, width: tableviewWidth, height: 0)
        firstTalbeView.rowHeight = MenuCellHeight
        firstTalbeView.dataSource = self
        firstTalbeView.delegate = self
        firstTalbeView.separatorColor = MenuSepartorColor
        firstTalbeView.separatorInset = .zero
        firstTalbeView.tableFooterView = UIView()
        
        // 二级列表
        secondTableView.frame = CGRect(x: tableviewWidth, y: frame.origin.y + frame.size.height, width: tableviewWidth, height: 0)
        secondTableView.rowHeight = MenuCellHeight
        secondTableView.dataSource = self
        secondTableView.delegate = self
        secondTableView.separatorColor = MenuSepartorColor
        secondTableView.separatorInset = .zero
        secondTableView.tableFooterView = UIView()
        
        // 三级列表
        thirdTabelView.frame = CGRect(x: tableviewWidth * 2, y: frame.origin.y + frame.size.height, width: tableviewWidth, height: 0)
        thirdTabelView.rowHeight = MenuCellHeight
        thirdTabelView.dataSource = self
        thirdTabelView.delegate = self
        thirdTabelView.separatorColor = MenuSepartorColor
        thirdTabelView.separatorInset = .zero
        thirdTabelView.tableFooterView = UIView()
        
        // 底部装饰条
        bottomImageView.frame = CGRect(x: frame.origin.x, y: frame.origin.y + frame.size.height, width: frame.size.width, height: MenuBottomImageHeight)

        bottomImageView.image = UIImage(named: "icon_chose_bottom")
        
        // 阴影
        backGroundView.frame = CGRect(x: frame.origin.x, y: frame.origin.y + frame.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        backGroundView.backgroundColor = UIColor(white: 0, alpha: 0)
        backGroundView.isOpaque = false
        let backTap = UITapGestureRecognizer(target: self, action: #selector(self.backTapAction))
        backGroundView.addGestureRecognizer(backTap)
        
        // 底部分隔线
        let bottomSeparator = UIView(frame: CGRect(x: 0, y: frame.size.height - 0.5, width: frame.size.width, height: 0.5))
        bottomSeparator.backgroundColor = MenuSepartorColor
        self.addSubview(bottomSeparator)
        
        // 添加菜单点击手势
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(self.menuTapAction))
        self.addGestureRecognizer(menuTap)
    }
    
    // 监听设置ItemData
    fileprivate func didSetItemData() {
        
        if itemsData == nil {
            return
        }
        
        // 设置初始选中
        selectedIndexPaths = []
        var index = 0
        
        for colItems in itemsData! {
            
            var selectedIndexPath = LLIndexPath(corlumn: index, row: nil, item: nil, index: nil, selectedText:"")
            index += 1
            
            if let firstRow = colItems.first {
                
                selectedIndexPath.row = 0
                
                if let firstItem = firstRow.items?.first {
                    
                    selectedIndexPath.item = 0
                    
                    if let firstIndex = firstItem.items?.first {
                        selectedIndexPath.index = 0
                        selectedIndexPath.selectedText = firstIndex.title
                    } else {
                        selectedIndexPath.selectedText = firstItem.title
                    }
                    
                } else {
                    
                    selectedIndexPath.selectedText = firstRow.title
                }
                
            } else {
                selectedIndexPath.selectedText = "no data"
            }
            
            selectedIndexPaths.append(selectedIndexPath)
        }
        
        // 设置菜单条
        let buttomWidth = frame.size.width / CGFloat(numOfColumn)
        let buttomHeight = frame.size.height
        
        var tempTitles = [CATextLayer]()
        var tempIndicators = [CAShapeLayer]()
        var tempBgLayers = [CALayer]()
        
        for index in 0..<numOfColumn {
            
            //bgLayer
            let bgLayerPosition = CGPoint(x: (CGFloat(index) + 0.5) * buttomWidth, y: buttomHeight * 0.5)
            let bgLayer = createBgLayer(color: UIColor.white, position: bgLayerPosition, bounds: CGRect(x: 0, y: 0, width: buttomWidth, height: buttomHeight - 0.5))
            self.layer.addSublayer(bgLayer)
            tempBgLayers.append(bgLayer)
            
            // titleLayer
            let titlePosition = CGPoint(x: (CGFloat(index) + 0.5) * buttomWidth, y: buttomHeight * 0.5)
            let title = selectedIndexPaths[index].selectedText
            let titleLayer = createTextLayer(string: title, color: textColor, font: titleFont, position: titlePosition, maxWidth: buttomWidth)
            self.layer.addSublayer(titleLayer)
            tempTitles.append(titleLayer)
            
            // indicator
            let indicatorPosition = CGPoint(x: CGFloat(index + 1) * buttomWidth - 10, y: buttomHeight * 0.5)
            let indicatorLayer = createInicator(color: indicatorColor, position: indicatorPosition)
            self.layer.addSublayer(indicatorLayer)
            tempIndicators.append(indicatorLayer)
            
            //separator
            if index != numOfColumn - 1 {
                let separatorPosition = CGPoint(x: ceil(CGFloat(index + 1) * buttomWidth - 1.0), y: buttomHeight * 0.5)
                let separator = createSeparatorLine(color: MenuSepartorColor, position: separatorPosition)
                self.layer.addSublayer(separator)
            }
            
            titleLayers = tempTitles
            indicatiorLayers = tempIndicators
            bgLayers = tempBgLayers
        }
        
    }
    
    
    // 菜单点击
    @objc fileprivate func menuTapAction(tapSender:UITapGestureRecognizer) {
        
        let touchPoint = tapSender.location(in: self)
       
        let tapIndex = Int(touchPoint.x / (frame.width / CGFloat(numOfColumn)))
        
        if isShow && showIndexPath?.corlumn == tapIndex { // 收起菜单
            hiddenMenu()
        } else { // 展开菜单
            showMenu(column: tapIndex)
        }
    }
    
    // 展开菜单
    fileprivate func showMenu(column:Int) {
        
        if isShow { // 切换
            
            // old
            animateIndicator(indicator: (indicatiorLayers?[showIndexPath!.corlumn])!, isShow: false, complete: {
                animateTitleLayer(titleLayer: (titleLayers?[showIndexPath!.corlumn])!, isShow: false, complete: {
                    
                })
            })
            
            showIndexPath = selectedIndexPaths[column]
            reloadMenu()
            
            // new
            animateIndicator(indicator: (indicatiorLayers?[column])!, isShow: true, complete: {
                animateTitleLayer(titleLayer: (titleLayers?[column])!, isShow: true, complete: {
                    animateTableView(show: true, complete: {
                        self.isShow = true
                    })
                })
            })
            
        } else { // 展开
            showIndexPath = selectedIndexPaths[column]
            reloadMenu()
            
            animateBackBroundView(view: backGroundView, isShow: true, complete: { 
                animateIndicator(indicator: (indicatiorLayers?[column])!, isShow: true, complete: {
                    animateTitleLayer(titleLayer: (titleLayers?[column])!, isShow: true, complete: { 
                        animateTableView(show: true, complete: { 
                            self.isShow = true
                        })
                    })
                })
            })
        }
    }
    
    // 收起菜单
    open func hiddenMenu() {
        
        animateBackBroundView(view: backGroundView, isShow: false, complete: {
            animateIndicator(indicator: (indicatiorLayers?[showIndexPath!.corlumn])!, isShow: false, complete: {
                animateTitleLayer(titleLayer: (titleLayers?[showIndexPath!.corlumn])!, isShow: false, complete: {
                    
                    animateTableView(show: false, complete: {
                        self.isShow = false
                        self.showIndexPath = nil
                    })
                })
            })
        })
    }
    
    // 点击阴影
    @objc fileprivate func backTapAction() {
        hiddenMenu()
    }
    
    // 刷新列表
    fileprivate func reloadMenu() {
        
        firstTalbeView.reloadData()
        secondTableView.reloadData()
        thirdTabelView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LLDropDownMenu: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard showIndexPath != nil else {
            return 0
        }
        
        if firstTalbeView == tableView {
            
            return itemsData[showIndexPath!.corlumn].count
            
        } else if secondTableView == tableView {
            
            if let row = showIndexPath!.row, let items = itemsData[showIndexPath!.corlumn][row].items  {
                
                return items.count
            }
            
        } else if thirdTabelView == tableView {
            
            if let row = showIndexPath!.row, let item = showIndexPath!.item, let indexs = itemsData[showIndexPath!.corlumn][row].items?[item].items {
                return indexs.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "DropDownMenuCell"
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            
            let bg = UIView()
            let selectline = UIView(frame: CGRect(x: 0, y: 0, width: 0.5, height: MenuCellHeight))
            selectline.backgroundColor = MenuSepartorColor
            bg.addSubview(selectline)
            bg.backgroundColor = MenuCellBgColor
            
            cell?.selectedBackgroundView = bg
            cell?.textLabel?.highlightedTextColor = textSelectedColor
            cell?.textLabel?.textColor = textColor
            cell?.textLabel?.font = textFont
            
            let rightLine = UIView(frame: CGRect(x: 0, y: 0, width: 0.5, height: MenuCellHeight))
            rightLine.backgroundColor = MenuSepartorColor
            cell?.contentView.addSubview(rightLine)
        }
        
        let selectedIndexPath = selectedIndexPaths[showIndexPath!.corlumn]
        
        if firstTalbeView == tableView {
            
            // 设置Text
            let rowEntity = itemsData[showIndexPath!.corlumn][indexPath.row]
            cell?.textLabel?.text = rowEntity.title
            
            // 设置选中
            if selectedIndexPath.row == indexPath.row {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            
            // 设置箭头
            if let items = rowEntity.items , items.count > 0 {
                let image = UIImage(named: "icon_chose_arrow_nor@2x")
                let highlightImage = UIImage(named: "icon_chose_arrow_sel@2x")
                
                cell?.accessoryView = UIImageView(image: image , highlightedImage: highlightImage)
            } else {
                cell?.accessoryView = nil
            }
            
        } else if secondTableView == tableView {
            
            // 设置Text
            let itemEntity = itemsData[showIndexPath!.corlumn][showIndexPath!.row!].items![indexPath.row]
            cell?.textLabel?.text = itemEntity.title
            
            // 设置选中
            if selectedIndexPath.row == showIndexPath?.row && selectedIndexPath.item == indexPath.row {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            
            // 设置箭头
            if let indexs = itemEntity.items, indexs.count > 0 {
                let image = UIImage(named: "icon_chose_arrow_nor@2x")
                let highlightImage = UIImage(named: "icon_chose_arrow_sel@2x")
                
                cell?.accessoryView = UIImageView(image: image , highlightedImage: highlightImage)
            } else {
                cell?.accessoryView = nil
            }
            
        } else if thirdTabelView == tableView {
            
            // 设置Text
            let indexEntity = itemsData[showIndexPath!.corlumn][showIndexPath!.row!].items![showIndexPath!.item!].items![indexPath.row]
            cell?.textLabel?.text = indexEntity.title
            
            // 设置选中
            if selectedIndexPath.row == showIndexPath?.row && selectedIndexPath.item == showIndexPath?.item && selectedIndexPath.index == indexPath.row {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            
            // 设置箭头
            cell?.accessoryView = nil
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == firstTalbeView {
            
            showIndexPath = LLIndexPath(corlumn: showIndexPath!.corlumn, row: indexPath.row, item: nil, index: nil, selectedText: "")
            
            let rowEntity = itemsData![showIndexPath!.corlumn][indexPath.row]
            if rowEntity.items == nil {
                var selectedIndexPath = showIndexPath!
                selectedIndexPath.selectedText = rowEntity.title
                
                updateDidSelect(indexPath: selectedIndexPath)
                updateTitleText(selected: selectedIndexPath)
            } else {
                self.secondTableView.reloadData()
                self.thirdTabelView.reloadData()
                animateUpateLayoutTableView(indexPath: showIndexPath!, complete: { 
                    
                })
            }
            
        } else if tableView == secondTableView {
            
            showIndexPath = LLIndexPath(corlumn: showIndexPath!.corlumn, row: showIndexPath?.row, item: indexPath.row, index: nil, selectedText: "")
            
            let itemEntity = itemsData![showIndexPath!.corlumn][showIndexPath!.row!].items![indexPath.row]
            
            if itemEntity.items == nil {
                var selectedIndexPath = showIndexPath!
                selectedIndexPath.selectedText = itemEntity.title
                
                updateDidSelect(indexPath: selectedIndexPath)
                updateTitleText(selected: selectedIndexPath)
            } else {
                thirdTabelView.reloadData()
                animateUpateLayoutTableView(indexPath: showIndexPath!, complete: {
                    
                })
            }
            
        } else if tableView == thirdTabelView {
            
            showIndexPath = LLIndexPath(corlumn: showIndexPath!.corlumn, row: showIndexPath!.row, item: showIndexPath!.item, index: indexPath.row, selectedText: "")
            
            let indexEntity = itemsData![showIndexPath!.corlumn][showIndexPath!.row!].items![showIndexPath!.item!].items![indexPath.row]
            var selectedIndexPath = showIndexPath!
            selectedIndexPath.selectedText = indexEntity.title
            
            updateDidSelect(indexPath: selectedIndexPath)
            updateTitleText(selected: selectedIndexPath)
        }
    }
    
    func updateDidSelect(indexPath:LLIndexPath) {
        
        let rang:Range = indexPath.corlumn ..< indexPath.corlumn + 1
        
        selectedIndexPaths.replaceSubrange(rang, with: [indexPath])
        
        delegate?.menu(self, didSelectIndexPath: indexPath)
    }
    
    func updateTitleText(selected:LLIndexPath) {
        
        let titleLayer = titleLayers![selected.corlumn]
        titleLayer.string = selected.selectedText
        
        hiddenMenu()
    }
}

// MARK: - animation method
extension LLDropDownMenu {
    
    fileprivate func animateTableView(show:Bool, complete:@escaping () -> Void) {
        
        if show {
            
            self.superview?.clipsToBounds = true
            
            firstTalbeView.frame = CGRect(x: self.frame.minX, y: self.frame.maxY, width: self.frame.width, height: 0)
            secondTableView.frame = CGRect(x: self.frame.maxY, y: self.frame.maxY, width: self.frame.width, height: 0)
            thirdTabelView.frame = CGRect(x: self.frame.maxY, y: self.frame.maxY, width: self.frame.width, height: 0)
            if firstTalbeView.superview == nil {
                self.superview?.addSubview(firstTalbeView)
            } else {
                self.superview?.bringSubview(toFront: firstTalbeView)
            }
            
            if secondTableView.superview == nil {
                self.superview?.addSubview(secondTableView)
            } else {
                self.superview?.bringSubview(toFront: secondTableView)
            }
            
            if thirdTabelView.superview == nil {
                self.superview?.addSubview(thirdTabelView)
            } else {
                self.superview?.bringSubview(toFront: thirdTabelView)
            }
            
            bottomImageView.frame = CGRect(x: self.frame.minX, y: self.frame.maxY, width: self.frame.width, height: MenuBottomImageHeight)
            self.superview?.addSubview(bottomImageView)
            self.superview?.addSubview(self)
            
            var columnCount = 1
            let slectedIndexPath = selectedIndexPaths[showIndexPath!.corlumn]
            if slectedIndexPath.index != nil {
                columnCount = 3
            } else if slectedIndexPath.item != nil {
                columnCount = 2
            }
            
            let tableviewWidth = self.frame.width / CGFloat(columnCount)
            
            var firstFrame = firstTalbeView.frame
            firstFrame.size.width = tableviewWidth
            firstTalbeView.frame = firstFrame
            
            var secondFrame = secondTableView.frame
            secondFrame.size.width = tableviewWidth
            secondFrame.origin.x = firstTalbeView.frame.maxX
            secondTableView.frame = secondFrame
            
            var thirdFrame = thirdTabelView.frame
            thirdFrame.size.width = tableviewWidth
            thirdFrame.origin.x = secondTableView.frame.maxX
            thirdTabelView.frame = thirdFrame
            
            let numRows = firstTalbeView.numberOfRows(inSection: 0)
            let numItems = secondTableView.numberOfRows(inSection: 0)
            let numIndexs = thirdTabelView.numberOfRows(inSection: 0)
            var num = numRows
            if columnCount == 2 {
                num = max(numRows, numItems)
            } else if columnCount == 3 {
                
                num = max(max(numRows, numItems), numIndexs)
            }
            
            let maxNum = 9
            
            var tableviewHeight = CGFloat(num > maxNum ? maxNum : num) * MenuCellHeight
            tableviewHeight += CGFloat(num > maxNum ? 10 : 0)
            
            UIView.animate(withDuration: 0.2, animations: { 
                
                var firstFrame = self.firstTalbeView.frame
                firstFrame.size.height = tableviewHeight
                self.firstTalbeView.frame = firstFrame
                
                var secondFrame = self.secondTableView.frame
                secondFrame.size.height = tableviewHeight
                self.secondTableView.frame = secondFrame
                
                var thirdFrame = self.thirdTabelView.frame
                thirdFrame.size.height = tableviewHeight
                self.thirdTabelView.frame = thirdFrame
                
                var imageFrame = self.bottomImageView.frame
                imageFrame.origin.y += tableviewHeight - 1
                self.bottomImageView.frame = imageFrame
                
            }, completion: { (_) in
                
                complete()
            })
            
            
            
            
        } else {
            
            UIView.animate(withDuration: 0.2, animations: {
                
                var firstFrame = self.firstTalbeView.frame
                firstFrame.size.height = 0
                self.firstTalbeView.frame = firstFrame
                
                var secondFrame = self.secondTableView.frame
                secondFrame.size.height = 0
                self.secondTableView.frame = secondFrame
                
                var thirdFrame = self.thirdTabelView.frame
                thirdFrame.size.height = 0
                self.thirdTabelView.frame = thirdFrame
                
                var imageFrame = self.bottomImageView.frame
                imageFrame.origin.y = self.frame.maxY
                self.bottomImageView.frame = imageFrame
                
            }, completion: { (_) in
                
                if let _ = self.firstTalbeView.superview {
                    self.firstTalbeView.removeFromSuperview()
                }
                
                if let _ = self.secondTableView.superview {
                    self.secondTableView.removeFromSuperview()
                }
                
                if let _ = self.thirdTabelView.superview {
                    self.thirdTabelView.removeFromSuperview()
                }
                
                self.bottomImageView.removeFromSuperview()
                
                complete()
            })
        }
    }
    
    fileprivate func animateUpateLayoutTableView(indexPath:LLIndexPath, complete:@escaping () -> Void) {

        let numRows = self.tableView(firstTalbeView, numberOfRowsInSection: 0)
        let numItems = self.tableView(secondTableView, numberOfRowsInSection: 0)
        let numIndexs = self.tableView(thirdTabelView, numberOfRowsInSection: 0)
        
        var columnCount = 1
        if indexPath.item == nil && numItems > 0 { // 点击了第一列

            columnCount = 2
           
        } else if numIndexs > 0 { // 点击了第二列

            columnCount = 3
        }
        
        let tableviewWidth = self.frame.width / CGFloat(columnCount)
        
        var num = numRows
        if columnCount == 2 {
            num = max(numRows, numItems)
        } else if columnCount == 3 {
            
            num = max(max(numRows, numItems), numIndexs)
        }
        
        let maxNum = 9
        
        var tableviewHeight = CGFloat(num > maxNum ? maxNum : num) * MenuCellHeight
        tableviewHeight += CGFloat(num > maxNum ? 10 : 0)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            var firstFrame = self.firstTalbeView.frame
            firstFrame.size.height = tableviewHeight
            firstFrame.size.width = tableviewWidth
            self.firstTalbeView.frame = firstFrame
            
            var secondFrame = self.secondTableView.frame
            secondFrame.size.height = tableviewHeight
            secondFrame.size.width = tableviewWidth
            secondFrame.origin.x = self.firstTalbeView.frame.maxX
            self.secondTableView.frame = secondFrame
            
            var thirdFrame = self.thirdTabelView.frame
            thirdFrame.size.height = tableviewHeight
            thirdFrame.size.width = tableviewWidth
            thirdFrame.origin.x = self.secondTableView.frame.maxX
            self.thirdTabelView.frame = thirdFrame
            
            var imageFrame = self.bottomImageView.frame
            imageFrame.origin.y = self.frame.maxY + tableviewHeight - 1
            self.bottomImageView.frame = imageFrame
            
        }, completion: { (_) in
            
            complete()
        })
    }
    
    fileprivate func animateIndicator(indicator:CAShapeLayer, isShow:Bool, complete: () -> Void) {
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0))
        
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = isShow ? [0, M_PI] : [M_PI, 0]
        
        if !animation.isRemovedOnCompletion {
            indicator.add(animation, forKey: animation.keyPath)
        } else {
            indicator.add(animation, forKey: animation.keyPath)
            indicator.setValue(animation.values?.last, forKeyPath: animation.keyPath!)
        }
        
        CATransaction.commit()
        
        if isShow {
            indicator.fillColor = textSelectedColor.cgColor
        } else {
            indicator.fillColor = indicatorColor.cgColor
        }
        
        complete()
    }
    
    fileprivate func animateBackBroundView(view:UIView, isShow:Bool, complete:() -> Void) {
        
        if isShow {
            self.superview?.addSubview(view)
            view.superview?.addSubview(self)
            UIView.animate(withDuration: 0.2, animations: { 
                view.backgroundColor = UIColor(white: 0, alpha: 0.3)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: { 
                view.backgroundColor = UIColor(white: 0, alpha: 0)
            }, completion: { (_) in
                view.removeFromSuperview()
            })
        }
        
        complete()
    }
    
    fileprivate func animateTitleLayer(titleLayer: CATextLayer, isShow: Bool, complete:() -> Void) {
        
        let maxWidth = frame.size.width / CGFloat(numOfColumn)
        let size = calculateTitleSize(string: titleLayer.string as! String, font: titleFont)
        let width  = size.width < (maxWidth - 25) ? size.width : maxWidth - 25
        titleLayer.bounds = CGRect(x: 0, y: 0, width: width, height: size.height)
        
        if isShow {
            titleLayer.foregroundColor = textSelectedColor.cgColor
        } else {
            titleLayer.foregroundColor = textColor.cgColor
        }
        
        complete()
    }
}

// MARK: - Layer Tool
extension LLDropDownMenu {
    
    fileprivate func createBgLayer(color:UIColor, position:CGPoint, bounds:CGRect) -> CALayer {
        
        let layer = CALayer()
        
        layer.position = position
        layer.bounds = bounds
        layer.backgroundColor = color.cgColor
        
        return layer
    }
    
    fileprivate func createInicator(color:UIColor, position:CGPoint) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: 4, y: 5))
        path.close()
        
        layer.path = path.cgPath
        layer.lineWidth = 0.8
        layer.fillColor = color.cgColor
        
        let pathCopy = layer.path?.copy(strokingWithWidth: layer.lineWidth, lineCap: .butt, lineJoin: .miter, miterLimit: layer.miterLimit)
        layer.bounds = (pathCopy?.boundingBoxOfPath)!
        layer.position = position
        
        return layer
    }
    
    fileprivate func createSeparatorLine(color:UIColor, position:CGPoint) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 20))
        
        layer.path = path.cgPath
        layer.lineWidth = 1
        layer.strokeColor = color.cgColor
        
        let pathCopy = layer.path?.copy(strokingWithWidth: layer.lineWidth, lineCap: .butt, lineJoin: .miter, miterLimit: layer.miterLimit)
        layer.bounds = (pathCopy?.boundingBoxOfPath)!
        layer.position = position
        
        return layer
    }
    
    fileprivate func createTextLayer(string:String, color:UIColor, font:UIFont, position:CGPoint, maxWidth:CGFloat) -> CATextLayer {
        
        let size = calculateTitleSize(string: string, font:font)
        
        let layer = CATextLayer()
        let width  = size.width < (maxWidth - 25) ? size.width : maxWidth - 25
        layer.bounds = CGRect(x: 0, y: 0, width: width, height: size.height)
        layer.string = string
        layer.fontSize = font.pointSize
        layer.alignmentMode = kCAAlignmentCenter
        layer.truncationMode = kCATruncationEnd
        layer.foregroundColor = color.cgColor
        layer.contentsScale = UIScreen.main.scale
        layer.position = position
        
        return layer
    }
    
    fileprivate func calculateTitleSize(string:String, font:UIFont) -> CGSize {
        
        let dict = [NSFontAttributeName:font]
        
        let size = (string as NSString).boundingRect(with: bounds.size, options: [.truncatesLastVisibleLine, .usesFontLeading, .usesLineFragmentOrigin], attributes: dict, context: nil).size
        
        return CGSize(width: ceil(size.width) + 2, height: size.height)
    }
}
