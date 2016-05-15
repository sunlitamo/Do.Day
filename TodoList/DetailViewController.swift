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
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var previousMth: UIButton!
    @IBOutlet var nextMth: UIButton!
    @IBOutlet var dateLbl: UILabel!
    
    private var image:UIImage? = nil
    
    var todoItem:(item:TodoModel?,index:Int?,edit:Bool?)
    
    var todoItemList = [TodoItemList]()
    
    private var date:(year:Int,month:Int,firstDay:Int,daysCount:Int)?
    
    var indexPath:NSIndexPath?
    
    override func viewDidLoad() {
        
        todoItemCollectionView.dataSource = self
        todoItemCollectionView.delegate = self
        
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        
        prepareUI()
        
        retrieveItemData(todoItem.item)
    
    }
    
    //FIXME
    func retrieveItemData(model:TodoModel?) {
        if model != nil {
            todoTxt.text = model!.title
            datePicker.date = model!.date
        }
    }
    
    
    //UICollection delegate method
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch collectionView {
        case self.todoItemCollectionView:
            let cell = todoItemCollectionView.cellForItemAtIndexPath(indexPath) as! TodoCollectionCell
            self.image = cell.todoImg.image
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
                                            self.currentItemImg.image = self.image
                                            self.currentItemImg.alpha = 1
                                            snapshot.removeFromSuperview()
                                        }})
        case self.calendarCollectionView:
            _ = calendarCollectionView.cellForItemAtIndexPath(indexPath) as! CalendarCell
            guard indexPath.row > 6 else{return}
            
        //TODO Selectable
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
//            if  indexPath.item < 7 && indexPath.item >= 0{
//                cell.dateText.textColor = UIColor.blackColor()
//                cell.dateText.text = TodoListHelper.getWeekDays()[indexPath.item];
//            }
//            else{
            if indexPath.item >= date!.firstDay{
            
                cell.dateText.text = String(indexPath.item + 1 - date!.firstDay)
            }
            if self.indexPath == nil {
                self.indexPath = indexPath
            }
//            }
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
            return date!.daysCount + date!.firstDay
        default:
            return 0
        }
        
    }
    
    
    @IBAction func confirmBtnTapped(sender: UIButton) {
        
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 5
        let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
        
        let weekDay = gregorian.components(NSCalendarUnit.Weekday,fromDate: date).weekday
        print("testing:\(weekDay)")
        
        guard todoTxt.text != nil && self.image != nil && String(datePicker.date) != nil else {
            showAlertView()
            return
        }
        
        let uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        switch todoItem.edit! {
            
        case true:
            todos[todoItem.index!] = TodoModel(id:uuid, image: image!, title: todoTxt.text!, date: datePicker.date)
            
        case false:
            let item = TodoModel(id:uuid, image: image!, title: todoTxt.text!, date: datePicker.date)
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
        let alertController = UIAlertController(title: "警告", message: "请填写完整信息",  preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func customConfirmBtn(inputBtn:UIButton!){
        inputBtn.layer.borderWidth = 1;
        inputBtn.layer.cornerRadius = 4.0;
        inputBtn.layer.masksToBounds = true;
        inputBtn.setTitleColor(UIColor(red: 92/255.0, green: 184/255.0, blue: 92/255.0, alpha: 1), forState: .Normal)
        //        inputBtn.titleLabel?.font = UIFont(name: "helvetica Neue", size: 16)
        inputBtn.setTitle("Done", forState: .Normal)
        
        //        inputBtn.backgroundColor = UIColor(red: 92/255.0, green: 184/255.0, blue: 92/255.0, alpha: 1)
        inputBtn.layer.borderColor = UIColor(red: 76/255.0, green: 174/255.0, blue: 76/255.0, alpha: 1).CGColor
        
    }
    
    
    @IBAction func prevMth(sender: AnyObject) {
        date!.month-=1
        updateCalendar(date!.year, month: date!.month)
    }
    @IBAction func nextMth(sender: AnyObject) {
        date!.month+=1
        updateCalendar(date!.year, month: date!.month)
    }
    private func updateCalendar(year:Int,month:Int){
        if(month>12){
            date!.month=1;
            date!.year+=1;
        }
        if(month<1){
            date!.month=12;
            date!.year-=1;
        }
        date = CalendarHelper.loadCalendar(date!.year, currentMonth: date!.month)
        dateLbl.text = ("\(CalendarHelper.formatDate(date!.month)) \(String(date!.year))")
        
        calendarCollectionView.reloadItemsAtIndexPaths([self.indexPath!])
    }
    
    private func prepareUI(){
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
        dateLbl.text = ("\(CalendarHelper.formatDate(date!.month)) \(String(date!.year))")
        
    }
}
