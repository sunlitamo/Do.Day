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
    
    var dateSelected = UIImageView()
    private var taskImage:UIImage? = nil
    private var taskDate:(year:Int,month:Int,day:Int)?
    var todoItem:(item:TodoModel?,index:Int?,edit:Bool?)
    var todoItemMenu = [TodoItemMenu]()
    
    @IBOutlet var toDoViewHeight: NSLayoutConstraint!
    
    var managedContext:NSManagedObjectContext!
    var fetchedResultsController:NSFetchedResultsController!
    
    private var date:(year:Int,month:Int,firstDay:Int,daysCount:Int)?
    
    override func viewDidLoad() {
        
        prepareUI()
        retrieveItemData(todoItem.item)
        
    }
    
    /**---------------------------------------
     *--- UICollectionView Delegate Method ---
     *---------------------------------------*/

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.todoItemCollectionView:
            return todoItemMenu.count
            
        case self.calendarCollectionView:
            return date!.daysCount + date!.firstDay - 1 + 7
            
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.todoItemCollectionView:
            let cell = todoItemCollectionView.dequeueReusableCellWithReuseIdentifier(Constants.CELL_TODO_OPTION,forIndexPath: indexPath) as! TodoCollectionCell
            cell.despTxt.text = todoItemMenu[indexPath.row].title
            if (DeviceType.IS_IPHONE_4) {
                cell.despTxt.font = cell.despTxt.font.fontWithSize(7)
            }
            else if (DeviceType.IS_IPHONE_5) {
                cell.despTxt.font = cell.despTxt.font.fontWithSize(8)
            }
            cell.todoImg.image = todoItemMenu[indexPath.row].image
            return cell
            
            
        case self.calendarCollectionView:
            let cell = calendarCollectionView.dequeueReusableCellWithReuseIdentifier(Constants.CELL_CALENDAR,forIndexPath: indexPath) as! CalendarCell
            
            if (DeviceType.IS_IPHONE_4) {
                cell.dateText.font = cell.dateText.font.fontWithSize(7)
            }
            else if (DeviceType.IS_IPHONE_5) {
                cell.dateText.font = cell.dateText.font.fontWithSize(13)
            }
            
            
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
            
           
            if (cell.dateText.text! == String(taskDate!.day)) {
                
                configSelectedCell()
                cell.contentView.addSubview(dateSelected)
                cell.contentView.sendSubviewToBack(dateSelected)
                
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
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
            
            guard indexPath.item >= date!.firstDay - 1 + 7  else{return}
            
            self.taskDate = (date!.year, month: date!.month, day: Int(cell.dateText.text!)!)
            
            configSelectedCell()
            cell.contentView.addSubview(dateSelected)
            cell.contentView.sendSubviewToBack(dateSelected)
            
        default:
            break
        }
    }

    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        switch collectionView {
        case self.todoItemCollectionView:
            var size = CGSizeMake(0, 0);
            
            if(DeviceType.IS_IPHONE_4){size = CGSizeMake(40, 50);}
            else if(DeviceType.IS_IPHONE_5){size = CGSizeMake(40, 50);}
            else if(DeviceType.IS_IPHONE_6){size = CGSizeMake(50, 60);}
            else if(DeviceType.IS_IPHONE_6P){size = CGSizeMake(55, 65);}
            else if(DeviceType.IS_IPAD){size = CGSizeMake(55, 65);}
            
            return size;
            
        case self.calendarCollectionView:
            
            var size = CGSizeMake(0, 0);
            
            if(DeviceType.IS_IPHONE_4){size = CGSizeMake(33, 18);}
            else if(DeviceType.IS_IPHONE_5){size = CGSizeMake(33, 28);}
            else if(DeviceType.IS_IPHONE_6){size = CGSizeMake(38, 33);}
            else  if(DeviceType.IS_IPHONE_6P){size = CGSizeMake(43, 38);}
            else  if(DeviceType.IS_IPAD){size = CGSizeMake(43, 38);}
            
            return size;
            
        default:
            return CGSizeMake(0, 0);
        }
    }
    
    
    /**---------------------------------------
     *--- TextField Delegate Method ----------
     *---------------------------------------*/

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if(!(todoTxt.text!.isEmpty)){
            self.highLight(self.todoTxt, enabled: false)
        }
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        todoTxt.resignFirstResponder()
    }
    
    /**---------------------
     *----- UI Control -----
     *---------------------*/

    @IBAction func prevMth(sender: AnyObject) {
        date!.month-=1
        updateCalendar(date!.year, month: date!.month)
    }
    @IBAction func nextMth(sender: AnyObject) {
        date!.month+=1
        updateCalendar(date!.year, month: date!.month)
    }

    /**---------------------
     *--- Private Method ---
     *---------------------*/
    
    private func retrieveItemData(model:TodoModel?) {
        self.currentItemImg.image = UIImage(named: "general")
        if model != nil {
            
            todoTxt.text = model!.title
            
            self.currentItemImg.image = UIImage(data: model!.image!)
            self.taskImage = self.currentItemImg.image
            self.taskDate = CalendarHelper.dateConverter_Closure(model!.taskDate!)
        }
        else{
            todoTxt.text = nil
            self.currentItemImg.image = UIImage(named: "general")
            self.taskImage = self.currentItemImg.image
            todoItem.edit = false
        }
    }
    
    private func shakeView(){
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.02
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(todoTxt.center.x - 5, todoTxt.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(todoTxt.center.x + 5, todoTxt.center.y))
        todoTxt.layer.addAnimation(animation, forKey: "position")
        
        self.highLight(self.todoTxt, enabled: true)
    }
    
    private func updateCalendar(year:Int,month:Int) {
        
        date!.year = CalendarHelper.updateCalendar(date!.year, month: date!.month).0
        date!.month = CalendarHelper.updateCalendar(date!.year, month: date!.month).1
        
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
        
        //let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        // fixedSpace.width = 30.0
        
        let confirmBtn = UIButton(type:.Custom)
        confirmBtn.setImage(UIImage(named: "confirm"), forState: .Normal)
        confirmBtn.frame = CGRectMake(0, 0, 30, 30)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: confirmBtn)]
        
        todoItemMenu = TodoItemMenu.getAllTodoItems()
        
        date = CalendarHelper.getCurrentDate()
        date = CalendarHelper.loadCalendar(date!.year, currentMonth: date!.month)
        dateLbl.text = ("\(CalendarHelper.formatDate(date!.month)) \(String(date!.year))")
        
        
        let currentDay = NSCalendar.currentCalendar().components([.Day], fromDate: NSDate()).day
        
        self.taskDate = (date!.year,date!.month,currentDay)
        OptimizeUI()
    }
    
    private func OptimizeUI(){
        
        if(DeviceType.IS_IPHONE_4){
            toDoViewHeight.constant = 170
        }
        
        else if(DeviceType.IS_IPHONE_5){
            toDoViewHeight.constant = 190
        }
        else if(DeviceType.IS_IPHONE_6){
            toDoViewHeight.constant = 230
        }
        else if(DeviceType.IS_IPHONE_6P){
            toDoViewHeight.constant = 257
        }
        else if(DeviceType.IS_IPAD){
            toDoViewHeight.constant = 270
        }
    }
    
    @objc private func confirmBtnTapped(sender: UIButton) {
        
        guard !(todoTxt.text!.isEmpty) && self.taskImage != nil && self.taskDate != nil else {
            shakeView()
            return
        }
        
        if todoItem.edit! { updateStorage() }
        else{ addToStorage() }
        
        do{ try managedContext.save() }
        catch{ fatalError() }
        
        dismiss()
    }
    
    private func addToStorage(){
        
        let entity = NSEntityDescription.insertNewObjectForEntityForName(Constants.ENTITY_MODEL_TODO, inManagedObjectContext: managedContext) as! TodoModel
        
        entity.setValue(UIImagePNGRepresentation(taskImage!), forKey: "image")
        entity.setValue(todoTxt.text!, forKey: "title")
        let taskDate = CalendarHelper.dateConverter_NSdate((self.taskDate!.year, month: self.taskDate!.month, day: self.taskDate!.day))
        entity.setValue(taskDate, forKey: "taskDate")
        entity.setValue(NSNumber(bool: false), forKey: "done")
        
        var order:NSNumber = 1
        
        for section in fetchedResultsController.sections! {
            if CalendarHelper.dateConverter_NSDate(section.name) == taskDate {
                order = section.numberOfObjects + 1
                break
            }
        }
        NSLog("title:\(todoTxt.text!),order:\(order)")
        entity.setValue(order, forKey: "order")
        
    }
    
    
    private func updateStorage(){
        
        if ((todoItem.item) != nil) {
            todoItem.item!.setValue(UIImagePNGRepresentation(taskImage!), forKey: "image")
            todoItem.item!.setValue(todoTxt.text!, forKey: "title")
            todoItem.item!.setValue(CalendarHelper.dateConverter_NSdate((self.taskDate!.year, month: self.taskDate!.month, day: self.taskDate!.day)), forKey: "taskDate")
        }
    }
    
    @objc private func dismiss(){
        self.navigationController?.popViewControllerAnimated(true)
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.RELOAD, object: nil)
    }
    
    private func configSelectedCell(){
        dateSelected.removeFromSuperview()
        dateSelected = UIImageView()
        dateSelected.backgroundColor = UIColor.clearColor()
        
        dateSelected.layer.borderColor = UIColor.orangeColor().CGColor
        dateSelected.layer.borderWidth = 0.8
        
        if(DeviceType.IS_IPHONE_4){
            dateSelected.frame = CGRectMake(7.5,0,18, 18)
            dateSelected.layer.cornerRadius = 9
        }
        else if(DeviceType.IS_IPHONE_5){
            dateSelected.frame = CGRectMake(2.5,0,28, 28)
            dateSelected.layer.cornerRadius = 14
        }
        
        else if(DeviceType.IS_IPHONE_6){
            dateSelected.frame = CGRectMake(2.5,0,33, 33)
            dateSelected.layer.cornerRadius = 16.5
        }
        
        else if(DeviceType.IS_IPHONE_6P){
            dateSelected.frame = CGRectMake(2.5,0,38, 38)
            dateSelected.layer.cornerRadius = 19
        }
        
        else if(DeviceType.IS_IPAD){
            dateSelected.frame = CGRectMake(2.5,0,44, 44)
            dateSelected.layer.cornerRadius = 22
        }
        
        dateSelected.transform = CGAffineTransformMakeRotation(CGFloat(90.0*M_PI/180.0))
    }
    
    private func highLight(object:AnyObject,enabled:Bool){
        
        if (enabled) {
            object.layer.borderColor = UIColor.redColor().CGColor
            object.layer.borderWidth = 1
            object.layer.cornerRadius = 8
        }
        else{
            object.layer.borderColor = UIColor.clearColor().CGColor
            object.layer.borderWidth = 0
            object.layer.cornerRadius = 0
        }
        
    }
}
