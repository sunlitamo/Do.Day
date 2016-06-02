 //
 //  TodoViewController.swift
 //  TodoList
 //
 //  Created by Sunlit.Amo on 24/04/16.
 //  Copyright © 2016年 Sunlit.Amo. All rights reserved.
 //
 
 import UIKit
 import CoreData
 
 var todos: [TodoModel] = []
 class TodoViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var toDoListTableView: UITableView!
    var transitionButton: UIButton!
    var editButton: UIButton!
    var doneButton: UIButton!
    
    
    let moc = DataController().managedObjectContext
    
    override func viewDidLoad() {
        
        toDoListTableView.delegate = self
        toDoListTableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(reloadData), name: "reload", object: nil)
        
        prepareUI()
        readFromStorage()
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
        self.performSegueWithIdentifier("addNew", sender: self)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) ->UITableViewCell {
        
        let cell = toDoListTableView.dequeueReusableCellWithIdentifier("todoCell") as! TodoCell
        
        
        cell.despTxt.text = todos[indexPath.row].title
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        
        cell.taskTimeTxt.text = CalendarHelper.dateConverter_String(todos[indexPath.row].taskDate!)
        
        cell.todoImg.image = UIImage(data:todos[indexPath.row].image!)
        
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
        readFromStorage()
        toDoListTableView.reloadData()
    }
    
    
    private func readFromStorage(){
        
        let fetch = NSFetchRequest(entityName:"TodoModel")
        
        do{
            todos = try moc.executeFetchRequest(fetch) as! [TodoModel]
        }
        catch{
            fatalError()
        }
    }
    
    private func prepareUI(){
        navigationItem.leftBarButtonItem = editButtonItem()
        transitionButton = UIButton(type:.Custom)
        transitionButton!.backgroundColor = UIColor.darkGrayColor()
        transitionButton!.frame = CGRectMake((self.view.frame.width)-70, (self.view.frame.height)-80, 50, 50)
        transitionButton.transform = CGAffineTransformMakeRotation(CGFloat(45.0*M_PI/180.0))
        transitionButton!.layer.cornerRadius = 25
        transitionButton.setImage(UIImage(named:"addWhiteSmall"), forState:.Normal)
        transitionButton!.addTarget(self, action: #selector(viewTransfer), forControlEvents: .TouchUpInside)
        
        editButton = UIButton(type:.Custom)
        editButton!.setImage(UIImage(named:"edit"), forState:.Normal)
        editButton!.setImage(UIImage(named:"editting"), forState:.Selected)
        editButton!.frame = CGRectMake(0, 0, 30, 30)
        editButton!.addTarget(self, action: #selector(setEditting), forControlEvents:.TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: editButton)
        
        self.view.insertSubview(transitionButton, aboveSubview: toDoListTableView)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 }
