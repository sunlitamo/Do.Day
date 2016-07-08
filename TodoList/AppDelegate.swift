//
//  AppDelegate.swift
//  TodoList
//
//  Created by Sunlit.Amo on 19/04/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    lazy var  coreDataStack = CoreDataStack()
    var  fetchedResultsController:NSFetchedResultsController!
    var  todoViewController:TodoViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let navController = window!.rootViewController as! UINavigationController
        todoViewController = navController.topViewController as! TodoViewController
        
        self.configureCoreData()
        
        todoViewController.fetchedResultsController = fetchedResultsController
        todoViewController.coreDataStack = self.coreDataStack
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.coreDataStack.saveContext()
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        //        if shortcutItem.type == "com.do.day.addtask"{
        //
        //            let storyboard = UIStoryboard(name: "Main",bundle: nil)
        //
        //            let addVC = storyboard.instantiateViewControllerWithIdentifier("DetailViewController") as!DetailViewController
        //
        //            let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController as! UINavigationController
        //
        //
        //            rootController.presentViewController(addVC, animated: false, completion: {
        //                () -> Void in
        //
        //                self.configureCoreData()
        //
        //                addVC.todoItem = (nil,nil,false)
        //                addVC.managedContext = self.coreDataStack.context
        //                addVC.fetchedResultsController = self.fetchedResultsController
        //
        //                completionHandler(true)
        //
        //            })
        //        }
        
        
        if shortcutItem.type == "com.do.day.addtask"{
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            //FirstViewcontroller UI will be called as root UIView
            let addVC : DetailViewController = storyboard.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
            
            let rootVC : TodoViewController = storyboard.instantiateViewControllerWithIdentifier("TodoViewController") as! TodoViewController
            
            self.configureCoreData()
            
          //  addVC.todoItem = (nil,nil,false)
            rootVC.managedContext = self.coreDataStack.context
            rootVC.fetchedResultsController = self.fetchedResultsController

            
            let navigationController = UINavigationController(rootViewController: rootVC)
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            
            rootVC.viewTransfer1()
            
        }
    }
    
    private func configureCoreData(){
        let fetchRequest = NSFetchRequest(entityName: "TodoModel")
        
        let dateSort  = NSSortDescriptor(key: "taskDate", ascending: true)
        let orderSort = NSSortDescriptor(key: "order", ascending: true)
        let doneSort  = NSSortDescriptor(key: "done", ascending: true)
        
        fetchRequest.sortDescriptors = [dateSort,doneSort,orderSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataStack.context,
                                                              sectionNameKeyPath: "taskDate",cacheName: nil)
        
        fetchedResultsController.delegate = todoViewController
    }
    
}

