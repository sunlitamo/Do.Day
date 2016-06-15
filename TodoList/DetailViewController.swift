//
//  DetailViewController.swift
//  TodoList
//
//  Created by Sunlit.Amo on 23/04/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{
    
    @IBOutlet var calendarCollectionView: UICollectionView!
    @IBOutlet var todoItemCollectionView: UICollectionView!
    
    @IBOutlet var todoTxt: UITextField!
    @IBOutlet var currentItemImg: UIImageView!
    @IBOutlet var previousMth: UIButton!
    @IBOutlet var nextMth: UIButton!
    @IBOutlet var dateLbl: UILabel!
    
    var selectedCycle = UIImageView()
    private var taskImage:UIImage? = nil
    private var taskDate:(year:Int,month:Int,day:Int)?
    var todoItem:(item:TodoModel?,index:Int?,edit:Bool?)
    var todoItemList = [TodoItemList]()
    
    @IBOutlet var toDoViewHeight: NSLayoutConstraint!
    let moc = DataController().managedObjectContext
    
    private var date:(year:Int,month:Int,firstDay:Int,daysCount:Int)?
    
    override func viewDidLoad() {
        
        todoItemCollectionView.dataSource = self
        todoItemCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        
        prepareUI()
        retrieveItemData(todoItem.item)
        
    }
    
    func retrieveItemData(model:TodoModel?) {
        if model != nil {
            
            todoTxt.text = model!.title
            
            self.currentItemImg.image = UIImage(data: model!.image!)
            self.taskImage = self.currentItemImg.image
            self.taskDate = CalendarHelper.dateConverter_Closure(model!.taskDate!)
        }
        else{
            todoItem.edit = false
        }
    }
    
    //FIXME Modify here
    // 1. selectedCell 位置不对

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        switch collectionView {
        case self.todoItemCollectionView:
            var size = CGSizeMake(0, 0);
           
            if(DeviceType.IS_IPHONE_5){
                size = CGSizeMake(38, 48);
            }
            if(DeviceType.IS_IPHONE_6){
            size = CGSizeMake(45, 55);
            }
            if(DeviceType.IS_IPHONE_6P){
                size = CGSizeMake(50, 60);
            }
            return size;
            
        case self.calendarCollectionView:
        
            var size = CGSizeMake(0, 0);

            if(DeviceType.IS_IPHONE_5){
                size = CGSizeMake(28, 23);
            }

            if(DeviceType.IS_IPHONE_6){
                size = CGSizeMake(35, 30);
            }

            if(DeviceType.IS_IPHONE_6P){
            size = CGSizeMake(40, 35);
            }
            return size;
         
        default:
            return CGSizeMake(0, 0);
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let leftRightInset = self.view.frame.size.width / 14.0
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }
    
    //UICollection delegate method
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch collectionView {
        case self.todoItemCollectionView:
            let cell = todoItemCollectionView.cellForItemAtIndexPath(indexPath) as! TodoCollectionCell
            self.taskImage = cell.todoImg.image
            let snapshot = TodoListHelper.customSnapshotFromView(cell)
            UIView.animateWithDuration(0.5 ,
                                       animations: {
                                        let positionAnimation:CABasicAnimation  = CABasicAnimation(keyPath: "positionAnimation")
                                        positionAnimation.fillMode = kCAFillModeForwards
                                        snapshot.layer.addAnimation(positionAnimation, forKey: "positionAnimation")
                                        snapshot.frame = CGRectMake(self.currentItemImg.frame.origin.x, self.currentItemImg.frame.origin.y, 30, 30)
                                        self.view.addSubview(snapshot)
                                        self.currentItemImg.alpha = 0.5},
                                       completion: {
                                        finish in UIView.animateWithDuration(0.7){
                                            self.view.transform = CGAffineTransformIdentity
                                            self.currentItemImg.image = self.taskImage
                                            self.currentItemImg.alpha = 1
                                            snapshot.removeFromSuperview()
                                        }})
        case self.calendarCollectionView:
            let cell = calendarCollectionView.cellForItemAtIndexPath(indexPath) as! CalendarCell
            
            guard indexPath.item > 6 else{return}
            
            guard indexPath.item >= date!.firstDay - 1 + 7  else{
                return}
            
            self.taskDate = (date!.year, month: date!.month, day: Int(cell.dateText.text!)!)
            
            configSelectedCell()
            
            cell.contentView.addSubview(selectedCycle)
            cell.contentView.sendSubviewToBack(selectedCycle)
            
        default:
            break
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.todoItemCollectionView:
            let cell = todoItemCollectionView.dequeueReusableCellWithReuseIdentifier("todoCollectionCell",forIndexPath: indexPath) as! TodoCollectionCell
            cell.despTxt.text = todoItemList[indexPath.row].title
            if (DeviceType.IS_IPHONE_5) {
                cell.despTxt.font = cell.despTxt.font.fontWithSize(8)
            }
            cell.todoImg.image = todoItemList[indexPath.row].image
            return cell
            
            
        case self.calendarCollectionView:
            let cell = calendarCollectionView.dequeueReusableCellWithReuseIdentifier("calendarCell",forIndexPath: indexPath) as! CalendarCell
            
            if  indexPath.item < 7 && indexPath.item >= 0 {
                cell.dateText.textColor = indexPath.item == 0 ? UIColor.redColor() : UIColor.blackColor()
                cell.dateText.text = TodoListHelper.getWeekDays()[indexPath.item];
            }
            else {
                cell.dateText.text = "";
                cell.dateText.textColor = UIColor(red:0, green: 0.48025, blue:1, alpha:1)
            }
            
            if indexPath.item >= date!.firstDay - 1 + 7 {
                cell.dateText.text = String(indexPath.item + 1 - (date!.firstDay-1) - 7)
            }
            
            if (DeviceType.IS_IPHONE_5) {
                cell.dateText.font = cell.dateText.font.fontWithSize(13)
            }
            
            if (cell.dateText.text! == String(taskDate!.day)) {
                
                configSelectedCell(	)
                
                cell.contentView.addSubview(selectedCycle)
                cell.contentView.sendSubviewToBack(selectedCycle)
            }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.todoItemCollectionView:
            return todoItemList.count
        case self.calendarCollectionView:
            return date!.daysCount + date!.firstDay - 1 + 7
        default:
            return 0
        }
        
    }
    
    
    @IBAction func confirmBtnTapped(sender: UIButton) {
        
        guard todoTxt.text != nil && self.taskImage != nil && self.taskDate != nil else {
            showAlertView()
            return
        }
        
        switch todoItem.edit! {
            
        case true:
            updateStorage()
            
        case false:
            addToStorage()
        }
        do{try moc.save()}
        catch{fatalError()}
        
        dismiss()
        
    }
    func dismiss(){
        self.navigationController?.popViewControllerAnimated(true)
        NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        todoTxt.resignFirstResponder()
    }
    
    func showAlertView(){
        let alertController = UIAlertController(title: "Warning", message: "Task incomplete",  preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func prevMth(sender: AnyObject) {
        date!.month-=1
        updateCalendar(date!.year, month: date!.month)
    }
    @IBAction func nextMth(sender: AnyObject) {
        date!.month+=1
        updateCalendar(date!.year, month: date!.month)
    }
    
    private func updateCalendar(year:Int,month:Int) {
        
        if (month > 12) {
            date!.month=1;
            date!.year+=1;
        }
        
        if(month<1){
            date!.month=12;
            date!.year-=1;
        }
        
        date = CalendarHelper.loadCalendar(date!.year, currentMonth: date!.month)
        dateLbl.text = ("\(CalendarHelper.formatDate(date!.month)) \(String(date!.year))")
        
        calendarCollectionView.reloadData()
    }
    
    private func prepareUI() {
        let backBtn = UIButton(type:.Custom)
        backBtn.setImage(UIImage(named: "back"), forState: .Normal)
        backBtn.frame = CGRectMake(0, 0, 25, 25)
        backBtn.addTarget(self, action: #selector(dismiss), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        
        //TODO impl of writting comments in version 1.1
        
        let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        fixedSpace.width = 30.0
        
        let confirmBtn = UIButton(type:.Custom)
        confirmBtn.setImage(UIImage(named: "confirm"), forState: .Normal)
        confirmBtn.frame = CGRectMake(0, 0, 30, 30)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: confirmBtn)]
        
        todoItemList = TodoItemList.getAllTodoItems()
        
        date = CalendarHelper.getCurrentDate()
        date = CalendarHelper.loadCalendar(date!.year, currentMonth: date!.month)
        dateLbl.text = ("\(CalendarHelper.formatDate(date!.month)) \(String(date!.year))")
        
        
        let currentDay = NSCalendar.currentCalendar().components([.Day], fromDate: NSDate()).day
        
        self.taskDate = (date!.year,date!.month,currentDay)
        OptimizeUI()
    }
    
    private func OptimizeUI(){
    
        if(DeviceType.IS_IPHONE_5){
        
            toDoViewHeight.constant = 210
            
        }
        if(DeviceType.IS_IPHONE_6){
            toDoViewHeight.constant = 230
        }
        if(DeviceType.IS_IPHONE_6P){
        }
        
    }
    
    
    
    
    
    
    
    
    
    private func addToStorage(){
        
        let entity = NSEntityDescription.insertNewObjectForEntityForName("TodoModel", inManagedObjectContext: moc) as! TodoModel
        
        entity .setValue(UIImagePNGRepresentation(taskImage!), forKey: "image")
        entity .setValue(todoTxt.text!, forKey: "title")
        entity .setValue(CalendarHelper.dateConverter_NSdate((self.taskDate!.year, month: self.taskDate!.month, day: self.taskDate!.day)), forKey: "taskDate")
    }
    
    
    private func updateStorage(){
        
        if ((todoItem.item) != nil) {
            todoItem.item!.setValue(UIImagePNGRepresentation(taskImage!), forKey: "image")
            todoItem.item!.setValue(todoTxt.text!, forKey: "title")
            todoItem.item!.setValue(CalendarHelper.dateConverter_NSdate((self.taskDate!.year, month: self.taskDate!.month, day: self.taskDate!.day)), forKey: "taskDate")
        }
    }
    
    private func configSelectedCell(){
        selectedCycle.removeFromSuperview()
        selectedCycle = UIImageView()
        selectedCycle.backgroundColor = UIColor.lightGrayColor()
        if(DeviceType.IS_IPHONE_6P){
            selectedCycle.frame = CGRectMake(0, 0, 40, 40)
            selectedCycle.layer.cornerRadius = 20
        }
        else{
            selectedCycle.frame = CGRectMake(5, 0, 30, 30)
            selectedCycle.layer.cornerRadius = 15
        }
        selectedCycle.transform = CGAffineTransformMakeRotation(CGFloat(90.0*M_PI/180.0))
    }
    
}
