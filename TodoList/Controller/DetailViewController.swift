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
    fileprivate var taskImage:UIImage!
    fileprivate var taskDate:(year:Int,month:Int,day:Int)!
    var todoItem:(item:TodoModel?,index:Int?,edit:Bool?)
    var todoItemMenu = [TodoItemMenu]()
    
    @IBOutlet var toDoViewHeight: NSLayoutConstraint!
    
    var managedContext:NSManagedObjectContext!
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>!
    
    fileprivate var date:(year:Int,month:Int,firstDay:Int,daysCount:Int)!
    
    override func viewDidLoad() {
        
        prepareUI()
        retrieveItemData(todoItem.item)
        
    }
    
    /**---------------------------------------
     *--- UICollectionView Delegate Method ---
     *---------------------------------------*/
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.todoItemCollectionView:
            return todoItemMenu.count
            
        case self.calendarCollectionView:
            return date.daysCount + date.firstDay - 1 + 7
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.todoItemCollectionView:
            let cell = todoItemCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.CELL_TODO_OPTION,for: indexPath) as! TodoCollectionCell
            cell.despTxt.text = todoItemMenu[(indexPath as NSIndexPath).row].title
            if (DeviceType.IS_IPHONE_4) {
                cell.despTxt.font = cell.despTxt.font.withSize(7)
            }
            else if (DeviceType.IS_IPHONE_5) {
                cell.despTxt.font = cell.despTxt.font.withSize(8)
            }
            cell.todoImg.image = todoItemMenu[(indexPath as NSIndexPath).row].image
            return cell
            
            
        case self.calendarCollectionView:
            let cell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.CELL_CALENDAR,for: indexPath) as! CalendarCell
            
            if (DeviceType.IS_IPHONE_4) {
                cell.dateText.font = cell.dateText.font.withSize(7)
            }
            else if (DeviceType.IS_IPHONE_5) {
                cell.dateText.font = cell.dateText.font.withSize(13)
            }
            
            
            if  (indexPath as NSIndexPath).item < 7 && (indexPath as NSIndexPath).item >= 0 {
                cell.dateText.textColor = (indexPath as NSIndexPath).item == 0 ? UIColor.red : UIColor.black
                cell.dateText.text = TodoListHelper.getWeekDays()[(indexPath as NSIndexPath).item];
            }
            else {
                cell.dateText.text = "";
                cell.dateText.textColor = UIColor(red:0, green: 0.48025, blue:1, alpha:1)
            }
            
            if (indexPath as NSIndexPath).item >= date.firstDay - 1 + 7 {
                cell.dateText.text = String((indexPath as NSIndexPath).item + 1 - (date.firstDay-1) - 7)
            }
            
            
            if (cell.dateText.text! == String(taskDate.day)) {
                
                configSelectedCell()
                cell.contentView.addSubview(dateSelected)
                cell.contentView.sendSubview(toBack: dateSelected)
                
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.todoItemCollectionView:
            let cell = todoItemCollectionView.cellForItem(at: indexPath) as! TodoCollectionCell
            self.taskImage = cell.todoImg.image
            let snapshot = TodoListHelper.customSnapshotFromView(cell)
            UIView.animate(withDuration: 0.5 ,
                                       animations: {
                                        let positionAnimation:CABasicAnimation  = CABasicAnimation(keyPath: "positionAnimation")
                                        positionAnimation.fillMode = kCAFillModeForwards
                                        snapshot.layer.add(positionAnimation, forKey: "positionAnimation")
                                        snapshot.frame = CGRect(x: self.currentItemImg.frame.origin.x, y: self.currentItemImg.frame.origin.y, width: 30, height: 30)
                                        self.view.addSubview(snapshot)
                                        self.currentItemImg.alpha = 0.5},
                                       completion: {
                                        finish in UIView.animate(withDuration: 0.7, animations: {
                                            self.view.transform = CGAffineTransform.identity
                                            self.currentItemImg.image = self.taskImage
                                            self.currentItemImg.alpha = 1
                                            snapshot.removeFromSuperview()
                                        })})
        case self.calendarCollectionView:
            let cell = calendarCollectionView.cellForItem(at: indexPath) as! CalendarCell
            
            guard (indexPath as NSIndexPath).item > 6 else{return}
            
            guard (indexPath as NSIndexPath).item >= date.firstDay - 1 + 7  else{return}
            
            self.taskDate = (date.year, month: date.month, day: Int(cell.dateText.text!)!)
            
            configSelectedCell()
            cell.contentView.addSubview(dateSelected)
            cell.contentView.sendSubview(toBack: dateSelected)
            
        default:
            break
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: 0, height: 0);
        switch collectionView {
            
        case self.todoItemCollectionView:
            if      (DeviceType.IS_IPHONE_4)    {size = CGSize(width: 40, height: 50);}
            else if (DeviceType.IS_IPHONE_5)    {size = CGSize(width: 40, height: 50);}
            else if (DeviceType.IS_IPHONE_6)    {size = CGSize(width: 50, height: 60);}
            else if (DeviceType.IS_IPHONE_6P)   {size = CGSize(width: 55, height: 65);}
            else if (DeviceType.IS_IPAD)        {size = CGSize(width: 55, height: 65);}
            
            return size;
            
        case self.calendarCollectionView:
            if      (DeviceType.IS_IPHONE_4)    {size = CGSize(width: 33, height: 18);}
            else if (DeviceType.IS_IPHONE_5)    {size = CGSize(width: 33, height: 28);}
            else if (DeviceType.IS_IPHONE_6)    {size = CGSize(width: 38, height: 33);}
            else if (DeviceType.IS_IPHONE_6P)   {size = CGSize(width: 43, height: 38);}
            else if (DeviceType.IS_IPAD)        {size = CGSize(width: 43, height: 38);}
            
            return size;
            
        default:
            return CGSize(width: 0, height: 0);
        }
    }
    
    
    /**---------------------------------------
     *--- TextField Delegate Method ----------
     *---------------------------------------*/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if(!(todoTxt.text!.isEmpty)){
            self.highLight(self.todoTxt, enabled: false)
        }
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        todoTxt.resignFirstResponder()
    }
    
    /**---------------------
     *----- UI Control -----
     *---------------------*/
    
    @IBAction func prevMth(_ sender: AnyObject) {
        date.month-=1
        updateCalendar(date.year, month: date.month)
    }
    @IBAction func nextMth(_ sender: AnyObject) {
        date.month+=1
        updateCalendar(date.year, month: date.month)
    }
    
    /**---------------------
     *--- Private Method ---
     *---------------------*/
    
    fileprivate func retrieveItemData(_ model:TodoModel?) {
        self.currentItemImg.image = UIImage(named: "general")
        if model != nil {
            
            todoTxt.text = model!.title
            
            self.currentItemImg.image = UIImage(data: model!.image! as Data)
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
    
    fileprivate func shakeView(){
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.02
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: todoTxt.center.x - 5, y: todoTxt.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: todoTxt.center.x + 5, y: todoTxt.center.y))
        todoTxt.layer.add(animation, forKey: "position")
        
        self.highLight(self.todoTxt, enabled: true)
    }
    
    fileprivate func updateCalendar(_ year:Int,month:Int) {
        
        date.year = CalendarHelper.updateCalendar(date.year, month: date.month).0
        date.month = CalendarHelper.updateCalendar(date.year, month: date.month).1
        
        date = CalendarHelper.loadCalendar(date.year, currentMonth: date.month)
        dateLbl.text = ("\(CalendarHelper.formatDate(date.month)) \(String(date.year))")
        
        calendarCollectionView.reloadData()
    }
    
    fileprivate func prepareUI() {
        let backBtn = UIButton(type:.custom)
        backBtn.setImage(UIImage(named: "back"), for: UIControlState())
        backBtn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        backBtn.addTarget(self, action: #selector(pDismiss), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        
        //TODO impl of writting comments in version 1.1
        
        //let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        // fixedSpace.width = 30.0
        
        let confirmBtn = UIButton(type:.custom)
        confirmBtn.setImage(UIImage(named: "confirm"), for: UIControlState())
        confirmBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: confirmBtn)]
        
        todoItemMenu = TodoItemMenu.getAllTodoItems()
        
        date = CalendarHelper.getCurrentDate()
        date = CalendarHelper.loadCalendar(date.year, currentMonth: date.month)
        dateLbl.text = ("\(CalendarHelper.formatDate(date.month)) \(String(date.year))")
        
        
        let currentDay = (Calendar.current as NSCalendar).components([.day], from: Date()).day
        
        self.taskDate = (date.year,date.month,currentDay!)
        OptimizeUI()
    }
    
    fileprivate func OptimizeUI(){
        
        if     (DeviceType.IS_IPHONE_4){
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
    
    @objc fileprivate func confirmBtnTapped(_ sender: UIButton) {
        
        guard !(todoTxt.text!.isEmpty) && self.taskImage != nil && self.taskDate != nil else {
            shakeView()
            return
        }
        
        if todoItem.edit! { updateStorage()}
        else              { addToStorage() }
        
        do{ try managedContext.save() }
        catch{ fatalError() }
        
        show()
        
        dismiss()
    }
    
    fileprivate func show(){
        //        var fetchResult = self.fetchedResultsController.fetchedObjects
        //
        //        NSLog("-----------------------------")
        //        for i in 1...fetchResult!.count {
        //
        //            let model = fetchResult![i - 1] as! TodoModel
        //            NSLog("show name:\(model.title!)")
        //            NSLog("show order:\(model.order!)")
        //        }
        //         NSLog("-----------------------------")
    }
    
    fileprivate func addToStorage(){
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: Constants.ENTITY_MODEL_TODO, into: managedContext) as! TodoModel
        
        NSLog("entity:\(entity)");
        NSLog("taskData:\(self.taskDate)")
        entity.setValue(UIImagePNGRepresentation(taskImage!), forKey: "image")
        entity.setValue(todoTxt.text!, forKey: "title")
        let taskDate = CalendarHelper.dateConverter_NSdate((self.taskDate.year, month: self.taskDate.month, day: self.taskDate.day))
        entity.setValue(taskDate, forKey: "taskDate")
        entity.setValue(NSNumber(value: false as Bool), forKey: "done")
        
        var order:NSNumber = 1
        
        for section in fetchedResultsController.sections! {
            if CalendarHelper.dateConverter_NSDate(section.name) == taskDate {
                order = (section.numberOfObjects + 1) as NSNumber
                break
            }
        }
        NSLog("title:\(todoTxt.text!),order:\(order)")
        entity.setValue(order, forKey: "order")
        
    }
    
    fileprivate func updateStorage(){
        let taskDate_orin = todoItem.item?.taskDate
        let taskDate = CalendarHelper.dateConverter_NSdate((self.taskDate.year, month: self.taskDate.month, day: self.taskDate.day))
        if ((todoItem.item) != nil) {
            todoItem.item!.setValue(UIImagePNGRepresentation(taskImage!), forKey: "image")
            todoItem.item!.setValue(todoTxt.text!, forKey: "title")
        }
        if  taskDate != taskDate_orin {
            var order:NSNumber = 1
            
            for section in fetchedResultsController.sections! {
                if CalendarHelper.dateConverter_NSDate(section.name) == taskDate_orin {
                    for i in 1...section.numberOfObjects {
                        if i > Int(todoItem.item!.order!.int32Value)  {
                            let model = section.objects![i - 1] as! TodoModel
                            NSLog("update:orin :\(model.title!)")
                            NSLog("update:orin order:\(model.order)")
                            model.order = Int(model.order!.int32Value - 1) as NSNumber?
                            NSLog("update:new order:\(model.order)")
                        }
                    }
                }
                if CalendarHelper.dateConverter_NSDate(section.name) == taskDate {
                    order = (section.numberOfObjects + 1) as NSNumber
                }
            }
            todoItem.item!.setValue(order, forKey: "order")
            todoItem.item!.setValue(taskDate, forKey: "taskDate")
        }
    }
    
    @objc fileprivate func dismiss(){
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.RELOAD), object: nil)
    }
    
    fileprivate func configSelectedCell(){
        dateSelected.removeFromSuperview()
        dateSelected = UIImageView()
        dateSelected.backgroundColor = UIColor.clear
        
        dateSelected.layer.borderColor = UIColor.orange.cgColor
        dateSelected.layer.borderWidth = 0.8
        
        if(DeviceType.IS_IPHONE_4){
            dateSelected.frame = CGRect(x: 7.5,y: 0,width: 18, height: 18)
            dateSelected.layer.cornerRadius = 9
        }
        else if(DeviceType.IS_IPHONE_5){
            dateSelected.frame = CGRect(x: 2.5,y: 0,width: 28, height: 28)
            dateSelected.layer.cornerRadius = 14
        }
            
        else if(DeviceType.IS_IPHONE_6){
            dateSelected.frame = CGRect(x: 2.5,y: 0,width: 33, height: 33)
            dateSelected.layer.cornerRadius = 16.5
        }
            
        else if(DeviceType.IS_IPHONE_6P){
            dateSelected.frame = CGRect(x: 2.5,y: 0,width: 38, height: 38)
            dateSelected.layer.cornerRadius = 19
        }
            
        else if(DeviceType.IS_IPAD){
            dateSelected.frame = CGRect(x: 2.5,y: 0,width: 44, height: 44)
            dateSelected.layer.cornerRadius = 22
        }
        
        dateSelected.transform = CGAffineTransform(rotationAngle: CGFloat(90.0*M_PI/180.0))
    }
    
    fileprivate func highLight(_ object:AnyObject,enabled:Bool){
        
        if (enabled) {
            object.layer.borderColor = UIColor.red.cgColor
            object.layer.borderWidth = 1
            object.layer.cornerRadius = 8
        }
        else{
            object.layer.borderColor = UIColor.clear.cgColor
            object.layer.borderWidth = 0
            object.layer.cornerRadius = 0
        }
        
    }
    @objc fileprivate func pDismiss() {
        self.dismiss(animated:true)
    }
}
