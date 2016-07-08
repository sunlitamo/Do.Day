 //
 //  TodoViewController.swift
 //  TodoList
 //
 //  Created by Sunlit.Amo on 24/04/16.
 //  Copyright © 2016年 Sunlit.Amo. All rights reserved.
 //
 
 import UIKit
 import CoreData
 
 
 let isDebugVersion = true
 
 class TodoViewController: UIViewController {
    
    @IBOutlet var toDoListTableView: UITableView!
    
    var addButton: UIButton!
    var editButton: UIButton!
    var doneButton: UIButton!
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController:NSFetchedResultsController!
    
    var managedContext:NSManagedObjectContext!
    
    var isMovingItem : Bool = false
    
    
    override func viewDidLoad() {
        
        //managedContext = coreDataStack.context
        
        reloadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(reloadData), name: Constants.RELOAD, object: nil)
        
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        
      
    }
    
    @IBAction func swipeAction(sender: UISwipeGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.Ended {
            let point = sender.locationInView(toDoListTableView)
            if let indexPath = toDoListTableView.indexPathForRowAtPoint(point) {
                
                let model = self.fetchedResultsController.objectAtIndexPath(indexPath) as! TodoModel
                
                switch sender.direction {
                case UISwipeGestureRecognizerDirection.Left:
                    
                    if (model.done.boolValue) { model.done = NSNumber(bool: false) }
                    
                case UISwipeGestureRecognizerDirection.Right:
                    
                    if (!model.done.boolValue) { model.done = NSNumber(bool: true) }
                    
                default: break }
                
                do{try managedContext.save() } catch{ fatalError() }
            }
        }
    }
    
    /**---------------------
     *--- Private Method ---
     *---------------------*/
    
    
    @objc private func setEditting() {
        switch toDoListTableView.editing {
        case false:
            
            super.setEditing(true, animated: true)
            toDoListTableView.setEditing(true, animated: true)
            editButton.selected = true
            
        case true:
            
            super.setEditing(false, animated: true)
            toDoListTableView.setEditing(false, animated: true)
            editButton.selected = false
        }
    }
    
    @objc private func viewTransfer() {
        
        super.setEditing(false, animated: true)
        toDoListTableView.setEditing(false, animated: true)
        editButton.selected = false
        
        let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        detailVC.todoItem = (nil,nil,false)
        detailVC.managedContext = self.managedContext
        detailVC.fetchedResultsController = self.fetchedResultsController
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    func viewTransfer1() {
        
        super.setEditing(false, animated: true)
        
        let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        detailVC.todoItem = (nil,nil,false)
        detailVC.managedContext = self.managedContext
        detailVC.fetchedResultsController = self.fetchedResultsController
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }

    
    
    @objc private func reloadData(){
        
        loadCoreData()
        toDoListTableView.reloadData()
    }
    
    private func loadCoreData() {
        
        do{ try fetchedResultsController.performFetch() } catch{ fatalError() }
    }
    
    private func prepareUI(){
        
        addButton = UIButton(type:.Custom)
        addButton!.backgroundColor = UIColor.darkGrayColor()
        addButton!.frame = CGRectMake((self.view.frame.width)-70, (self.view.frame.height)-80, 50, 50)
        addButton.transform = CGAffineTransformMakeRotation(CGFloat(45.0*M_PI/180.0))
        addButton!.layer.cornerRadius = 25
        addButton.setImage(UIImage(named:"addWhiteSmall"), forState:.Normal)
        addButton!.addTarget(self, action: #selector(viewTransfer), forControlEvents: .TouchUpInside)
        
        editButton = UIButton(type:.Custom)
        editButton!.setImage(UIImage(named:"edit"), forState:.Normal)
        editButton!.setImage(UIImage(named:"editting"), forState:.Selected)
        editButton!.frame = CGRectMake(0, 0, 30, 30)
        editButton!.addTarget(self, action: #selector(setEditting), forControlEvents:.TouchUpInside)
        
        navigationItem.leftBarButtonItem = editButtonItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: editButton)
        
        self.view.insertSubview(addButton, aboveSubview: toDoListTableView)
        
    }
    
    private func configureAttributeStr(model:TodoModel,sourceStr:String)->NSAttributedString{
        
        let font  = (model.done.boolValue) ? UIFont.italicSystemFontOfSize(17) : UIFont.systemFontOfSize(17, weight: UIFontWeightLight)
        let color = (model.done.boolValue) ? UIColor.lightGrayColor() : UIColor.blackColor()
        let style = (model.done.boolValue) ? NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue) : NSNumber(integer: NSUnderlineStyle.StyleNone.rawValue)
       
        let attributes = [
            NSFontAttributeName:font,
            NSForegroundColorAttributeName:color,
            NSStrikethroughStyleAttributeName:style
        ]
        
        return NSAttributedString(string:sourceStr,attributes:attributes)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 }
 
 /**---------------------------------------
  *--- UITableView Delegate Method ---
  *---------------------------------------*/
 
 extension TodoViewController:UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return  CalendarHelper.dateConverter_GMT(sectionInfo.name)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) ->UITableViewCell {
        
        let todoModel = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoModel
        let cell = toDoListTableView.dequeueReusableCellWithIdentifier(Constants.CELL_TODO) as! TodoCell
        
        cell.despTxt.attributedText = configureAttributeStr(todoModel, sourceStr: todoModel.title!)
        cell.taskTimeTxt.text = CalendarHelper.dateConverter_String(todoModel.taskDate!)
//        cell.hideTxt.hidden = true
//        if todoModel.done.boolValue {
//            cell.hideTxt.hidden = false
//            cell.hideTxt.frame = CGRectMake(56, 10, (cell.frame.width)-30, 20)
//            cell.hideTxt.attributedText = configureAttributeStr(todoModel, sourceStr:"—————————————————",isPlaceHolder: true)
//        }
        cell.todoImg.image = UIImage(data:todoModel.image!)
        cell.todoImg.frame = CGRectMake(8, 10, 40, 40)
        cell.despTxt.frame = CGRectMake(56, 10, (cell.frame.width)-30, 20)
        cell.taskTimeTxt.frame = CGRectMake((cell.frame.width)-30, 40, (cell.frame.width)-30, 20)
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            if editingStyle == .Delete {
                let item = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoModel
                coreDataStack.context.deleteObject(item)
                coreDataStack.saveContext()
            }
        }
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if (toDoListTableView.editing) {return .Delete}
        return .None
    }
    
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        isMovingItem = true
        
        if var fetchResult = self.fetchedResultsController.fetchedObjects{
            
            let sectionInfo_src = fetchedResultsController.sections![sourceIndexPath.section]
            let sectionInfo_dst = fetchedResultsController.sections![destinationIndexPath.section]
            
            let modelCount_src = sectionInfo_src.numberOfObjects
            let modelCount_dst = sectionInfo_dst.numberOfObjects
            
            
            let srcModel =  sectionInfo_src.objects?[sourceIndexPath.row] as! TodoModel
            let dstModel:TodoModel? = (destinationIndexPath.row < modelCount_dst) ? (sectionInfo_dst.objects?[destinationIndexPath.row] as? TodoModel) : nil
            
            let newSrcOrder:NSNumber = (dstModel != nil) ? (dstModel!.order!) : (sectionInfo_dst.numberOfObjects + 1)
            
            let isSameSection  = (sourceIndexPath.section == destinationIndexPath.section)
            
            //Not the same section
            if (!isSameSection) {
                
                for i in 1...modelCount_src {
                    if (i > Int(srcModel.order!.intValue)) {
                        let temp = sectionInfo_src.objects![i - 1] as! TodoModel
                        temp.order = Int(temp.order!.intValue) - 1
                    }
                }
                
                if dstModel != nil {
                    for i in 1...modelCount_dst {
                        if (i >= Int(dstModel!.order!.intValue)) {
                            let temp = sectionInfo_dst.objects![i - 1] as! TodoModel
                            temp.order = Int(temp.order!.intValue) + 1
                        }
                    }
                }
            }
                //Same section
            else{
                //调整 同一 section 中items 的顺序
                
                // src.order < dst.order : item.order > src.order && item.order <= dst.order
                if srcModel.order!.intValue < dstModel!.order!.intValue {
                    
                    for i in 1...modelCount_dst {
                        
                        // item.order > dst.order -> break
                        guard i <= Int(dstModel!.order!.intValue) else{ break }
                        
                        if (i <= Int(dstModel!.order!.intValue)) && (i > Int(srcModel.order!.intValue)) {
                            
                            let model = sectionInfo_src.objects![i - 1] as! TodoModel
                            model.order = Int(model.order!.intValue) - 1
                        }
                    }
                }
                // src.order > dst.order : item.order < src.order && item.order >= dst.order
                if srcModel.order!.intValue > dstModel!.order!.intValue {
                    
                    for i in 1...modelCount_dst {
                        
                        // item.order > src.order -> break
                        guard i < Int(srcModel.order!.intValue) else{ break }
                        
                        if i < Int(srcModel.order!.intValue) && i >= Int(dstModel!.order!.intValue) {
                            
                            let model = sectionInfo_src.objects![i - 1] as! TodoModel
                            model.order = Int(model.order!.intValue) + 1
                        }
                    }
                }
            }
            
            if (isSameSection) {
                guard srcModel.order != newSrcOrder else{ return }
            }
            
            fetchResult.removeAtIndex(sourceIndexPath.row)
            
            srcModel.taskDate! = CalendarHelper.dateConverter_NSDate(sectionInfo_dst.name)
            srcModel.order! = newSrcOrder
            
            fetchResult.insert(srcModel, atIndex: destinationIndexPath.row)
            
            coreDataStack.saveContext()
            
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.toDoListTableView.reloadRowsAtIndexPaths(self.toDoListTableView.indexPathsForVisibleRows!, withRowAnimation: UITableViewRowAnimation.None)
        })
        isMovingItem = false
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let sectionInfo_src = fetchedResultsController.sections![indexPath.section]
        let todoModel = sectionInfo_src.objects![indexPath.row] as! TodoModel
        if todoModel.done.boolValue {
            return false
        }
        return true
    }
 }
 
 extension TodoViewController:UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let todoModel =
            fetchedResultsController.objectAtIndexPath(indexPath)
                as! TodoModel
        
        let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        detailVC.todoItem = (todoModel,indexPath.row,true)
        detailVC.managedContext = self.managedContext
        detailVC.fetchedResultsController = self.fetchedResultsController
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
 }
 
 extension TodoViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller:
        NSFetchedResultsController) {
        if isMovingItem { return }
        toDoListTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        
        if isMovingItem { return }
        
        switch type {
        case .Insert:
            toDoListTableView.insertRowsAtIndexPaths([newIndexPath!],
                                                     withRowAnimation: .None)
        case .Delete:
            toDoListTableView.deleteRowsAtIndexPaths([indexPath!],
                                                     withRowAnimation: .None)
        case .Update:
            toDoListTableView.reloadRowsAtIndexPaths([indexPath!],
                                                     withRowAnimation: .None)
        case .Move:
            toDoListTableView.deleteRowsAtIndexPaths([indexPath!],
                                                     withRowAnimation: .None)
            toDoListTableView.insertRowsAtIndexPaths([newIndexPath!],
                                                     withRowAnimation: .None)
        }
    }
    
    func controllerDidChangeContent(controller:
        NSFetchedResultsController) {
        
        if isMovingItem { return }
        toDoListTableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                     atIndex sectionIndex: Int,
                                             forChangeType type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        
        switch type {
        case .Insert:
            toDoListTableView.insertSections(indexSet,
                                             withRowAnimation: .None)
        case .Delete:
            toDoListTableView.deleteSections(indexSet,
                                             withRowAnimation: .None)
        default : break
        }
    }
    
    /**---------------------------------------
     *--- Internal test helper ---
     *---------------------------------------*/
//    var testDataDone : Bool = false
//    private func testData() {
//        
//        for i in 1...4 {
//            
//            let entity = NSEntityDescription.insertNewObjectForEntityForName(Constants.ENTITY_MODEL_TODO, inManagedObjectContext: managedContext) as! TodoModel
//            
//            entity.setValue(UIImagePNGRepresentation(UIImage(named:"general")!), forKey: "image")
//            entity.setValue("\(i)", forKey: "title")
//            entity.setValue(NSNumber(bool: false), forKey: "done")
//            
//            if i == 4 {
//                let taskDate = CalendarHelper.dateConverter_NSdate((2016, month: 07, day: 02))
//                entity.setValue(taskDate, forKey: "taskDate")
//                entity.setValue(1, forKey: "order")
//            }
//            else{
//                let taskDate = CalendarHelper.dateConverter_NSdate((2016, month: 07, day: 01))
//                entity.setValue(taskDate, forKey: "taskDate")
//                entity.setValue(i, forKey: "order")
//            }
//        }
//        do{try managedContext.save() }catch{fatalError()}
//        testDataDone = true
//    }
//    
//    private func ModelOrderValidator(){
//        var fetchResult = self.fetchedResultsController.fetchedObjects
//        
//        NSLog("-----------------------------")
//        for i in 1...fetchResult!.count {
//            
//            let model = fetchResult![i - 1] as! TodoModel
//            NSLog("show name:\(model.title!)")
//            NSLog("show order:\(model.order!)")
//        }
//        NSLog("-----------------------------")
//    }
 }