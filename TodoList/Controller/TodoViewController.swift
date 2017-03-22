 //
 //  TodoViewController.swift
 //  TodoList
 //
 //  Created by Sunlit.Amo on 24/04/16.
 //  Copyright © 2016年 Sunlit.Amo. All rights reserved.
 //
 
 import UIKit
 import CoreData
 import Firebase
 import FirebaseAuthUI
 
 let isDebugVersion = true
 
 class TodoViewController: UIViewController {
    
    @IBOutlet var toDoListTableView: UITableView!
    
    var addButton: UIButton!
    var editButton: UIButton!
    var doneButton: UIButton!
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>!
    
    var isMovingItem : Bool = false
    var forceTouchTriggered: Bool = false
    
    fileprivate var _authHandle: FIRAuthStateDidChangeListenerHandle!
    var user:FIRUser?
    var displayName = "Anonymous"
    
    //MARK: UI Control Method
    
    override func viewDidLoad() {
    
        NotificationCenter.default.addObserver(self,selector: #selector(reloadData), name: NSNotification.Name(rawValue: Constants.RELOAD), object: nil)
        
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        reloadData()
    }
    
    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.ended {
            let point = sender.location(in: toDoListTableView)
            if let indexPath = toDoListTableView.indexPathForRow(at: point) {
                
                let model = self.fetchedResultsController.object(at: indexPath) as! TodoModel
                
                switch sender.direction {
                case UISwipeGestureRecognizerDirection.left:
                    
                    if (model.done.boolValue) { model.done = NSNumber(value: false as Bool) }
                    
                case UISwipeGestureRecognizerDirection.right:
                    
                    if (!model.done.boolValue) { model.done = NSNumber(value: true as Bool) }
                    
                default: break }
                
                coreDataStack.saveContext()
            }
        }
    }
    //MARK: Internal Method
    @objc fileprivate func setEditting() {
        switch toDoListTableView.isEditing {
        case false:
            
            super.setEditing(true, animated: true)
            toDoListTableView.setEditing(true, animated: true)
            editButton.isSelected = true
            
        case true:
            
            super.setEditing(false, animated: true)
            toDoListTableView.setEditing(false, animated: true)
            editButton.isSelected = false
        }
    }
    
    func viewTransfer() {
        
        super.setEditing(false, animated: true)
    
        if !forceTouchTriggered {
            toDoListTableView.setEditing(false, animated: true)
            editButton.isSelected = false
        }
        
        let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.todoItem = (nil,nil,false)
        detailVC.managedContext = coreDataStack.getContext()
        detailVC.fetchedResultsController = self.fetchedResultsController
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc fileprivate func reloadData(){
        
        loadCoreData()
        toDoListTableView.reloadData()
    }
    
    fileprivate func loadCoreData() {
        
        do{ try fetchedResultsController.performFetch() } catch{ fatalError() }
    }
    
    fileprivate func prepareUI(){
        
        addButton = UIButton(type:.custom)
        addButton!.backgroundColor = UIColor.darkGray
        addButton!.frame = CGRect(x: (self.view.frame.width)-70, y: (self.view.frame.height)-80, width: 50, height: 50)
        addButton.transform = CGAffineTransform(rotationAngle: CGFloat(45.0*M_PI/180.0))
        addButton!.layer.cornerRadius = 25
        addButton.setImage(UIImage(named:"addWhiteSmall"), for:UIControlState())
        addButton!.addTarget(self, action: #selector(viewTransfer), for: .touchUpInside)
        
        editButton = UIButton(type:.custom)
        editButton!.setImage(UIImage(named:"edit"), for:UIControlState())
        editButton!.setImage(UIImage(named:"editting"), for:.selected)
        editButton!.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        editButton!.addTarget(self, action: #selector(setEditting), for:.touchUpInside)
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: editButton)
        
        self.view.insertSubview(addButton, aboveSubview: toDoListTableView)
        
    }
    
    fileprivate func configureAttributeStr(_ model:TodoModel,sourceStr:String)->NSAttributedString{
        
        let font  = (model.done.boolValue) ? UIFont.italicSystemFont(ofSize: 17) : UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
        let color = (model.done.boolValue) ? UIColor.lightGray : UIColor.black
        let style = (model.done.boolValue) ? NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int) : NSNumber(value: NSUnderlineStyle.styleNone.rawValue as Int)
        
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
 
 //MARK:UITableView DataSource Method
 
 extension TodoViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections!.count
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return  CalendarHelper.dateConverter_GMT(sectionInfo.name)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) ->UITableViewCell {
        
        let todoModel = fetchedResultsController.object(at: indexPath) as! TodoModel
        let cell = toDoListTableView.dequeueReusableCell(withIdentifier: Constants.CELL_TODO) as! TodoCell
        
        cell.despTxt.attributedText = configureAttributeStr(todoModel, sourceStr: todoModel.title!)
        cell.taskTimeTxt.text = CalendarHelper.dateConverter_String(todoModel.taskDate!)
        cell.todoImg.image = UIImage(data:todoModel.image!)
        cell.todoImg.frame = CGRect(x: 8, y: 10, width: 40, height: 40)
        cell.despTxt.frame = CGRect(x: 56, y: 10, width: (cell.frame.width)-30, height: 20)
        cell.taskTimeTxt.frame = CGRect(x: (cell.frame.width)-30, y: 40, width: (cell.frame.width)-30, height: 20)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            if editingStyle == .delete {
                let item = fetchedResultsController.object(at: indexPath) as! TodoModel
                coreDataStack.getContext().delete(item)
                coreDataStack.saveContext()
            }
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (toDoListTableView.isEditing) {return .delete}
        return .none
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        isMovingItem = true
        
        if var fetchResult = self.fetchedResultsController.fetchedObjects{
            
            let sectionInfo_src = fetchedResultsController.sections![(sourceIndexPath as NSIndexPath).section]
            let sectionInfo_dst = fetchedResultsController.sections![(destinationIndexPath as NSIndexPath).section]
            
            let modelCount_src = sectionInfo_src.numberOfObjects
            let modelCount_dst = sectionInfo_dst.numberOfObjects
            
            
            let srcModel =  sectionInfo_src.objects?[(sourceIndexPath as NSIndexPath).row] as! TodoModel
            let dstModel:TodoModel? = ((destinationIndexPath as NSIndexPath).row < modelCount_dst) ? (sectionInfo_dst.objects?[(destinationIndexPath as NSIndexPath).row] as? TodoModel) : nil
            
            let newSrcOrder:NSNumber = (dstModel != nil) ? (dstModel!.order! ) : (sectionInfo_dst.numberOfObjects + 1) as NSNumber!
            
            let isSameSection  = ((sourceIndexPath as NSIndexPath).section == (destinationIndexPath as NSIndexPath).section)
            
            //Not the same section
            if (!isSameSection) {
                
                for i in 1...modelCount_src {
                    if (i > Int(srcModel.order!.int32Value)) {
                        let temp = sectionInfo_src.objects![i - 1] as! TodoModel
                        temp.order = Int(temp.order!.intValue - 1) as NSNumber!
                    }
                }
                
                if dstModel != nil {
                    for i in 1...modelCount_dst {
                        if (i >= Int(dstModel!.order!.int32Value)) {
                            let temp = sectionInfo_dst.objects![i - 1] as! TodoModel
                            temp.order = Int(temp.order!.intValue + 1) as NSNumber!
                        }
                    }
                }
            }
                //Same section
            else{
                //调整 同一 section 中items 的顺序
                
                // src.order < dst.order : item.order > src.order && item.order <= dst.order
                if srcModel.order!.int32Value < dstModel!.order!.int32Value {
                    
                    for i in 1...modelCount_dst {
                        
                        // item.order > dst.order -> break
                        guard i <= Int(dstModel!.order!.int32Value) else{ break }
                        
                        if (i <= Int(dstModel!.order!.int32Value)) && (i > Int(srcModel.order!.int32Value)) {
                            
                            let model = sectionInfo_src.objects![i - 1] as! TodoModel
                            model.order = Int(model.order!.int32Value - 1) as NSNumber!
                        }
                    }
                }
                // src.order > dst.order : item.order < src.order && item.order >= dst.order
                if srcModel.order!.int32Value > dstModel!.order!.int32Value {
                    
                    for i in 1...modelCount_dst {
                        
                        // item.order > src.order -> break
                        guard i < Int(srcModel.order!.int32Value) else{ break }
                        
                        if i < Int(srcModel.order!.int32Value) && i >= Int(dstModel!.order!.int32Value) {
                            
                            let model = sectionInfo_src.objects![i - 1] as! TodoModel
                            model.order = Int(model.order!.int32Value + 1) as NSNumber!
                        }
                    }
                }
            }
            
            if (isSameSection) {
                guard srcModel.order != newSrcOrder else{ return }
            }
            
            fetchResult.remove(at: (sourceIndexPath as NSIndexPath).row)
            
            srcModel.taskDate! = CalendarHelper.dateConverter_NSDate(sectionInfo_dst.name)
            srcModel.order! = newSrcOrder
            
            fetchResult.insert(srcModel, at: (destinationIndexPath as NSIndexPath).row)
            
            coreDataStack.saveContext()
            
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.toDoListTableView.reloadRows(at: self.toDoListTableView.indexPathsForVisibleRows!, with: UITableViewRowAnimation.none)
        })
        isMovingItem = false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        let sectionInfo_src = fetchedResultsController.sections![(indexPath as NSIndexPath).section]
//        let todoModel = sectionInfo_src.objects![(indexPath as NSIndexPath).row] as! TodoModel
//        if todoModel.done.boolValue {
//            return false
//        }
//        return true
        return false;
    }
 }
 
 //MARK: UITableViewDelegate Method
 extension TodoViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let todoModel =
            fetchedResultsController.object(at: indexPath)
                as! TodoModel
        
        let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.todoItem = (todoModel,(indexPath as NSIndexPath).row,true)
        detailVC.managedContext = coreDataStack.getContext()
        detailVC.fetchedResultsController = self.fetchedResultsController
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
 }
 
 extension TodoViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        if isMovingItem { return }
        toDoListTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                                    at indexPath: IndexPath?,
                                                for type: NSFetchedResultsChangeType,
                                                              newIndexPath: IndexPath?) {
        
        if isMovingItem { return }
        
        switch type {
        case .insert:
            toDoListTableView.insertRows(at: [newIndexPath!],
                                                     with: .none)
        case .delete:
            toDoListTableView.deleteRows(at: [indexPath!],
                                                     with: .none)
        case .update:
            toDoListTableView.reloadRows(at: [indexPath!],
                                                     with: .none)
        case .move:
            toDoListTableView.deleteRows(at: [indexPath!],
                                                     with: .none)
            toDoListTableView.insertRows(at: [newIndexPath!],
                                                     with: .none)
        }
    }
    
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        
        if isMovingItem { return }
        toDoListTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                                     atSectionIndex sectionIndex: Int,
                                             for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            toDoListTableView.insertSections(indexSet,
                                             with: .none)
        case .delete:
            toDoListTableView.deleteSections(indexSet,
                                             with: .none)
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
