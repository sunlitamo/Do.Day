 //
 //  TodoViewController.swift
 //  TodoList
 //
 //  Created by Sunlit.Amo on 24/04/16.
 //  Copyright © 2016年 Sunlit.Amo. All rights reserved.
 //
 
 import UIKit
 import CoreData
 
 //FIXME Can not load tableview correctly
 
 let moc = DataController().managedObjectContext
 
 class TodoViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate {
    
    @IBOutlet var toDoListTableView: UITableView!
    var addButton: UIButton!
    var editButton: UIButton!
    var doneButton: UIButton!
    
    var todos: [TodoModel] = []
    
    var fetchController:NSFetchedResultsController!
    
    
    
    override func viewDidLoad() {
        
        toDoListTableView.delegate = self
        toDoListTableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(reloadData), name: Constants.RELOAD, object: nil)
        
        prepareUI()
        
        
    }
    override func viewWillAppear(animated: Bool) {
        reloadData()
    }
    
    func setEditting() {
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
    
    func viewTransfer() {
        self.performSegueWithIdentifier(Constants.SEGUE_NEW_ITEM, sender: self)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.fetchController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) ->UITableViewCell {
        
        let todoModel = self.fetchController.sections![1].objects![indexPath.row] as! TodoModel
        
        let cell = toDoListTableView.dequeueReusableCellWithIdentifier(Constants.CELL_TODO) as! TodoCell
        
        cell.despTxt.text = todoModel.title
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        
        cell.taskTimeTxt.text = CalendarHelper.dateConverter_String(todoModel.taskDate!)
        
        cell.todoImg.image = UIImage(data:todoModel.image!)
        
        cell.todoImg.frame = CGRectMake(8, 10, 50, 50)
        cell.despTxt.frame = CGRectMake(56, 10, (cell.frame.width)-30, 20)
        cell.taskTimeTxt.frame = CGRectMake((cell.frame.width)-30, 40, (cell.frame.width)-30, 20)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = todos[indexPath.row]
        
        let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier("DetailViewController")
            as! DetailViewController
        detailVC.todoItem = (item,indexPath.row,true)
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let todoModel = todos.removeAtIndex(indexPath.row)
            
            moc.deleteObject(todoModel)
            
            do{try moc.save()}catch{fatalError()}
            
            toDoListTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let todo = todos.removeAtIndex(sourceIndexPath.row)
        moc.deleteObject(todo)
        
        todos.insert(todo, atIndex: destinationIndexPath.row)
        moc.insertObject(todo)
        
        do{try moc.save()}catch{fatalError()}
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func reloadData(){
        
        loadCoreData()
        
        toDoListTableView.reloadData()
    }
    
    func loadCoreData() {
        
        let fetchRequest = NSFetchRequest(entityName:Constants.ENTITY_MODEL_TODO)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date",ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc,sectionNameKeyPath: nil,cacheName:Constants.ENTITY_MODEL_TODO)
        fetchController.delegate = self
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
