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
            
            let todoModel = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoModel
            
            managedContext.deleteObject(todoModel)
            
            toDoListTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            do{try managedContext.save()}
            catch{fatalError()}
        }
    }
    
    
    //FIXME pending..
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        var fetchResult = self.fetchedResultsController.fetchedObjects
        
        NSLog("check 1 \(fetchResult!.count)")
        
        let srcModel = fetchResult![sourceIndexPath.row] as! TodoModel
        let dstModel = fetchResult![destinationIndexPath.row] as? TodoModel
        
        let newSrcOrder = dstModel!.order!
        
        let sectionInfo = fetchedResultsController.sections![destinationIndexPath.section]
        let modelCount = sectionInfo.numberOfObjects
        
        //Not the same section
        if (sourceIndexPath.section != destinationIndexPath.section) {
            NSLog("check diff section")
            if srcModel.order!.intValue < dstModel!.order!.intValue {
                
                for i in 1...modelCount {
                    
                    // item.order > dst.order -> break
                    NSLog("check 3:第\(i)个 vs dst:\(Int(dstModel!.order!.intValue))")
                    
                    if (i >= Int(dstModel!.order!.intValue)) {
                        
                        let model = fetchResult![i - 1] as! TodoModel
                        NSLog("[\(i)] model name: \(model.title!)")
                        NSLog("[\(i)] orin:\(model.order)")
                        model.order = Int(model.order!.intValue) + 1
                        NSLog("[\(i)] new:\(model.order)")
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
                    
                    //FIXME: Pending not correct dst task date
                    NSLog("[src orin date:\(srcModel.taskDate)")
                    NSLog("[dst orin date:\(sectionInfo.name)")
                    srcModel.taskDate = CalendarHelper.dateConverter_NSDate(sectionInfo.name)
                    NSLog("[src new date:\(srcModel.taskDate)")

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
        
        //存储调整顺序后的item
        guard srcModel.order != newSrcOrder else{ return }
        
        NSLog("[src orin:\(srcModel.order)")
        srcModel.order = newSrcOrder
        NSLog("[src new:\(srcModel.order)")
        
        fetchResult!.removeAtIndex(sourceIndexPath.row)
        fetchResult!.insert(srcModel, atIndex: destinationIndexPath.row)
        //保存context
        do{ try managedContext.save() }
        catch{ fatalError() }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            tableView.reloadRowsAtIndexPaths(tableView.indexPathsForVisibleRows!, withRowAnimation: UITableViewRowAnimation.Fade)
        })
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
 }
 
 extension TodoViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller:
        NSFetchedResultsController) {
        toDoListTableView.reloadData()
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