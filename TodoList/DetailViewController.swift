//
//  DetailViewController.swift
//  TodoList
//
//  Created by Sunlit.Amo on 23/04/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet var calendarCollectionView: UICollectionView!
    @IBOutlet var todoItemCollectionView: UICollectionView!
    
    @IBOutlet var todoTxt: UITextField!
    @IBOutlet var currentItemImg: UIImageView!
    @IBOutlet var previousMth: UIButton!
    @IBOutlet var nextMth: UIButton!
    @IBOutlet var dateLbl: UILabel!
    
    private var isInited : Bool?
    
    var selectedCycle = UIImageView()
    private var taskImage:UIImage? = nil
    private var taskDate:(year:Int,month:Int,day:Int)?
    var todoItem:(item:TodoModel?,index:Int?,edit:Bool?)
    var todoItemList = [TodoItemList]()
    
    private var date:(year:Int,month:Int,firstDay:Int,daysCount:Int)?
    
    let moc = DataController().managedObjectContext
    
    override func viewDidLoad() {
        
        todoItemCollectionView.dataSource = self
        todoItemCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        
        prepareUI()
        retrieveItemData(todoItem.item)
        
        isInited = false
        
    }
    
    //FIXME
    func retrieveItemData(model:TodoModel?) {
        if model != nil {
            todoTxt.text = model!.title
            self.currentItemImg.image = UIImage(data: model!.image!)
            
            //FIXME : 获取的day 不对
            self.taskDate = CalendarHelper.dateConverter_Closure(model!.taskDate!)
        }
        else{
            todoItem.edit = false
        }
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
            
            guard indexPath.row > 6 else{return}
            
            self.taskDate = (date!.year, month: date!.month, day: Int(cell.dateText.text!)!)
            
            selectedCycle.removeFromSuperview()
            selectedCycle = UIImageView()
            selectedCycle.backgroundColor = UIColor.lightGrayColor()
            selectedCycle.frame = CGRectMake(0, 0, cell.frame.width, cell.frame.height)
            selectedCycle.transform = CGAffineTransformMakeRotation(CGFloat(90.0*M_PI/180.0))
            selectedCycle.layer.cornerRadius = 20
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
            
            if (cell.dateText.text! == String(taskDate!.day)) {
                
                selectedCycle.removeFromSuperview();
                
                selectedCycle = UIImageView()
                selectedCycle.backgroundColor = UIColor.lightGrayColor()
                selectedCycle.frame = CGRectMake(0, 0, cell.frame.width, cell.frame.height)
                selectedCycle.transform = CGAffineTransformMakeRotation(CGFloat(45.0*M_PI/180.0))
                selectedCycle.layer.cornerRadius = 20
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
        
        
        let logBtn = UIButton(type:.Custom)
        logBtn.setImage(UIImage(named: "edit"), forState: .Normal)
        logBtn.frame = CGRectMake(0, 0, 30, 30)
        //FIXME impl of writting comments
        logBtn.addTarget(self, action: #selector(confirmBtnTapped(_:)), forControlEvents: .TouchUpInside)
        
        let locationBtn = UIButton(type:.Custom)
        locationBtn.setImage(UIImage(named: "location"), forState: .Normal)
        locationBtn.frame = CGRectMake(0, 0, 30, 30)
        //FIXME impl of getting location
        locationBtn.addTarget(self, action: #selector(confirmBtnTapped(_:)), forControlEvents: .TouchUpInside)
        
        
        let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        fixedSpace.width = 30.0
        
        let confirmBtn = UIButton(type:.Custom)
        confirmBtn.setImage(UIImage(named: "confirm"), forState: .Normal)
        confirmBtn.frame = CGRectMake(0, 0, 30, 30)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: confirmBtn),fixedSpace,UIBarButtonItem(customView: logBtn),fixedSpace,UIBarButtonItem(customView: locationBtn)]
        
        todoItemList = TodoItemList.getAllTodoItems()
        
        date = CalendarHelper.getCurrentDate()
        date = CalendarHelper.loadCalendar(date!.year, currentMonth: date!.month)
        dateLbl.text = ("\(CalendarHelper.formatDate(date!.month)) \(String(date!.year))")
        
        
        let currentDay = NSCalendar.currentCalendar().components([.Day], fromDate: NSDate()).day
        
        self.taskDate = (date!.year,date!.month,currentDay)
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
    
}
