 //
 //  TodoViewController.swift
 //  TodoList
 //
 //  Created by Sunlit.Amo on 24/04/16.
 //  Copyright © 2016年 Sunlit.Amo. All rights reserved.
 //
 
 import UIKit
 import CoreData
 
 class TodoViewController: UIViewController {
    
    @IBOutlet var toDoListTableView: UITableView!
    
    var addButton: UIButton!
    var editButton: UIButton!
    var doneButton: UIButton!
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController:NSFetchedResultsController!
    
    var managedContext:NSManagedObjectContext!
    
    override func viewDidLoad() {
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(reloadData), name: Constants.RELOAD, object: nil)
        
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        managedContext = coreDataStack.context
        
        reloadData()
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
        
        editButton.selected = false
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
        
        let fetchRequest = NSFetchRequest(entityName: "TodoModel")
        let dateSort =
            NSSortDescriptor(key: "taskDate", ascending: true)
        let orderSort =
            NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [dateSort,orderSort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataStack.context,
                                                              sectionNameKeyPath: "taskDate",cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do{ try fetchedResultsController.performFetch() }
        catch{ fatalError() }
    }
    
    private func prepareUI(){
        navigationItem.leftBarButtonItem = editButtonItem()
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: editButton)
        
        self.view.insertSubview(addButton, aboveSubview: toDoListTableView)
        
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
        let sectionInfo =
            fetchedResultsController.sections![section]
        return  CalendarHelper.dateConverter_GMT(sectionInfo.name)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo =
            fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) ->UITableViewCell {
        
        let todoModel = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoModel
        
        let cell = toDoListTableView.dequeueReusableCellWithIdentifier(Constants.CELL_TODO) as! TodoCell
        
        cell.despTxt.text = todoModel.title
        cell.taskTimeTxt.text = CalendarHelper.dateConverter_String(todoModel.taskDate!)
        cell.todoImg.image = UIImage(data:todoModel.image!)
        cell.todoImg.frame = CGRectMake(8, 10, 50, 50)
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
        return UITableViewCellEditingStyle.Delete
    }
    
    //FIXME pending..
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        var fetchResult = self.fetchedResultsController.fetchedObjects
        
        NSLog("check 1 \(fetchResult!.count)")
        
        let srcModel = fetchResult![sourceIndexPath.row] as! TodoModel
        let dstModel = fetchResult![destinationIndexPath.row] as? TodoModel
        
        NSLog("orin src order:\(srcModel.order!)")
        
        let newSrcOrder = dstModel!.order!
        
        let sectionInfo_src = fetchedResultsController.sections![sourceIndexPath.section]
        let sectionInfo_dst = fetchedResultsController.sections![destinationIndexPath.section]
        
         NSLog("check 2:section name src:\(sectionInfo_src.name) vs dst:\(sectionInfo_dst.name))")
        
        let modelCount = sectionInfo_dst.numberOfObjects
        
        let isSameSection  = (sourceIndexPath.section == destinationIndexPath.section)
        
        //Not the same section
        if (sourceIndexPath.section != destinationIndexPath.section) {
            
            if srcModel.order!.intValue <= dstModel!.order!.intValue {
                
                for i in 1...modelCount {
                    
                    // item.order > dst.order -> break
                    
                    if (i >= Int(dstModel!.order!.intValue)) {
                        
                        let temp = sectionInfo_dst.objects![i - 1] as! TodoModel
                        NSLog("dst section [\(i)] model name: \(temp.title!)")
                        NSLog("dst section [\(i)] orin:\(temp.order)")
                        temp.order = Int(temp.order!.intValue) + 1
                        NSLog("dst section [\(i)] new:\(temp.order)")
                    }
                }
            }
        }
            //Same section
        else{
            //调整 同一 section 中items 的顺序
            
            // src.order < dst.order : item.order > src.order && item.order <= dst.order
            if srcModel.order!.intValue < dstModel!.order!.intValue {
                
                for i in 1...modelCount {
                    
                    // item.order > dst.order -> break
                    NSLog("check 3:第\(i)个 vs dst:\(Int(dstModel!.order!.intValue))")
                    
                    guard i <= Int(dstModel!.order!.intValue) else{ break }
                    
                    if (i <= Int(dstModel!.order!.intValue)) && (i > Int(srcModel.order!.intValue)) {
                        
                        let model = fetchResult![i - 1] as! TodoModel
                        NSLog("[\(i)] model name: \(model.title!)")
                        NSLog("[\(i)] orin:\(model.order)")
                        model.order = Int(model.order!.intValue) - 1
                        NSLog("[\(i)] new:\(model.order)")
                    }
                }
            }
            // src.order > dst.order : item.order < src.order && item.order >= dst.order
            if srcModel.order!.intValue > dstModel!.order!.intValue {
                
                for i in 1...modelCount {
                    
                    // item.order > src.order -> break
                    NSLog("check 3:第\(i)个 vs dst:\(Int(dstModel!.order!.intValue))")
                    
                    guard i < Int(srcModel.order!.intValue) else{ break }
                    
                    if i < Int(srcModel.order!.intValue) && i >= Int(dstModel!.order!.intValue) {
                        
                        let model = fetchResult![i - 1] as! TodoModel
                        NSLog("[\(i)] model name: \(model.title!)")
                        NSLog("[\(i)] orin:\(model.order)")
                        model.order = Int(model.order!.intValue) + 1
                        NSLog("[\(i)] new:\(model.order)")
                    }
                }
            }
        }
        
        // from here
        //存储调整顺序后的item
        if (isSameSection) {
        guard srcModel.order != newSrcOrder else{ return }
        }
        
        let newModel = srcModel.copy() as! TodoModel
        
        coreDataStack.context.deleteObject(srcModel)
        
        NSLog("[src orin order:\(srcModel.order!)")
        newModel.order = newSrcOrder
        NSLog("[src new order :\(srcModel.order!)")
        
        NSLog("[src orin date:\(srcModel.taskDate)")
        newModel.taskDate = CalendarHelper.dateConverter_NSDate(sectionInfo_dst.name)
        NSLog("[src new date:\(srcModel.taskDate)")
        
        coreDataStack.context.insertObject(newModel)
        coreDataStack.saveContext()

        
//        //保存context
//        do{ try managedContext.save() }
//        catch{ fatalError() }
//        
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            tableView.reloadRowsAtIndexPaths(tableView.indexPathsForVisibleRows!, withRowAnimation: UITableViewRowAnimation.Fade)
//        })
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
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
        toDoListTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            toDoListTableView.insertRowsAtIndexPaths([newIndexPath!],
                                             withRowAnimation: .Automatic)
        case .Delete:
            toDoListTableView.deleteRowsAtIndexPaths([indexPath!],
                                             withRowAnimation: .Automatic)
    
        //TODO check how to do this
        case .Update: break
            
        case .Move:
            toDoListTableView.deleteRowsAtIndexPaths([indexPath!],
                                             withRowAnimation: .Automatic)
            toDoListTableView.insertRowsAtIndexPaths([newIndexPath!],
                                             withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller:
        NSFetchedResultsController) {
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
                                     withRowAnimation: .Automatic)
        case .Delete:
            toDoListTableView.deleteSections(indexSet,
                                     withRowAnimation: .Automatic)
        default :
            break
        }
    }
    
    //
    //    - (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    //    switch(type) {
    //    case NSFetchedResultsChangeInsert:
    //    [self.theTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    //    break;
    //
    //    case NSFetchedResultsChangeDelete:
    //    [self.theTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    //    break;
    //    }
    //    }
    //    
    // controller: NSFetchedResultsController,
 }