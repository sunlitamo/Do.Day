//
//  DetailViewController.swift
//  TodoList
//
//  Created by Sunlit.Amo on 23/04/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet var calendarCollectionView: UICollectionView!
    
    @IBOutlet var todoItemCollectionView: UICollectionView!
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var logBtn: UIButton!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var calendarBtn: UIButton!
    @IBOutlet var todoTxt: UITextField!
    @IBOutlet var currentItemImg: UIImageView!
    @IBOutlet var previousMth: UIButton!
    @IBOutlet var nextMth: UIButton!
    @IBOutlet var dateLbl: UILabel!
    
    private var taskImage:UIImage? = nil
    private var taskDate:(year:Int,month:Int,day:Int)?
    private var isInited : Bool?
    
    var selectedCell = UIImageView()
    var todoItem:(item:TodoModel?,index:Int?,edit:Bool?)
    var todoItemList = [TodoItemList]()

    private var date:(year:Int,month:Int,firstDay:Int,daysCount:Int)?
    
    override func viewDidLoad() {
        
        todoItemCollectionView.dataSource = self
        todoItemCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        isInited = false
        prepareUI()
        retrieveItemData(todoItem.item)
        
    }
    
    //FIXME
    func retrieveItemData(model:TodoModel?) {
        if model != nil {
            todoTxt.text = model!.title
            self.currentItemImg.image = model!.image
            self.taskDate = model!.date
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
            cell.isCellSelected = true
            
            guard indexPath.row > 6 else{return}
            
            self.taskDate = (date!.year, month: date!.month, day: Int(cell.dateText.text!)!)
            
            selectedCell.removeFromSuperview()
            selectedCell = UIImageView()
            selectedCell.backgroundColor = UIColor.lightGrayColor()
            selectedCell.frame = CGRectMake(0, 0, cell.frame.width, cell.frame.height)
            selectedCell.transform = CGAffineTransformMakeRotation(CGFloat(45.0*M_PI/180.0))
            selectedCell.layer.cornerRadius = 20
            cell.contentView.addSubview(selectedCell)
            cell.contentView.sendSubviewToBack(selectedCell)
            
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
                cell.dateText.textColor = UIColor.blackColor()
                cell.dateText.text = TodoListHelper.getWeekDays()[indexPath.item];
            } else {
                cell.dateText.text = "";
            }
        
        
            if indexPath.item >= date!.firstDay - 1 + 7 {
                cell.dateText.text = String(indexPath.item + 1 - (date!.firstDay-1) - 7)
            }
            
            if (cell.dateText.text! == String(taskDate!.day)) {
                print("==> \(cell.dateText.text!),  ==> \(taskDate!.day)");
                selectedCell.removeFromSuperview();
                
                selectedCell = UIImageView()
                selectedCell.backgroundColor = UIColor.lightGrayColor()
                selectedCell.frame = CGRectMake(0, 0, cell.frame.width, cell.frame.height)
                selectedCell.transform = CGAffineTransformMakeRotation(CGFloat(45.0*M_PI/180.0))
                selectedCell.layer.cornerRadius = 20
                cell.contentView.addSubview(selectedCell)
                cell.contentView.sendSubviewToBack(selectedCell)
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
            todos[todoItem.index!] = TodoModel(image: taskImage!, title: todoTxt.text!, date: (self.taskDate!.year, month: self.taskDate!.month, day: self.taskDate!.day))
            
        case false:
            let item = TodoModel(image: taskImage!, title: todoTxt.text!, date: (self.taskDate!.year, month: self.taskDate!.month, day: self.taskDate!.day))
            todos.append(item)
        }
        
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
        backBtn = UIButton(type:.Custom)
        backBtn.setImage(UIImage(named: "back"), forState: .Normal)
        backBtn.frame = CGRectMake(0, 0, 25, 25)
        backBtn.addTarget(self, action: #selector(dismiss), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        
        logBtn = UIButton(type:.Custom)
        logBtn.setImage(UIImage(named: "log"), forState: .Normal)
        logBtn.frame = CGRectMake(0, 0, 30, 30)
        logBtn.addTarget(self, action: #selector(confirmBtnTapped(_:)), forControlEvents: .TouchUpInside)
        
        confirmBtn = UIButton(type:.Custom)
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
    }
}
