//
//  EmployeeTableViewController.swift
//  EmployeeTracker
//
//  Created by Catalyst IT on 7/25/16.
//  Copyright © 2016 Catalyst DevWorks. All rights reserved.
//

import UIKit
import CoreData

class EmployeeTableViewController: UITableViewController
{
    // MARK: Properties
    
    var employees = [Employee]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        employees = loadEmployees()
        
        // Need to clean employees array here
        // deleteEmployeesAndReInsert()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            print("Hit On Delete Operation")
            
            // Delete the row from the data source (aka employee array)
            employees.removeAtIndex(indexPath.row)
            
            // Persist
            deleteEmployeesAndReInsert()
            
            // Fade It Away
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "EmployeeTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EmployeeTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let employee = employees[indexPath.row]
        
        cell.nameLabel.text = employee.name
        cell.photoImageView.image = employee.photo
        cell.titleLabel.text = employee.title
        
        return cell
    }

    @IBAction func unwindToEmployeeList(sender: UIStoryboardSegue)
    {
        if let sourceViewController = sender.sourceViewController as? EmployeeViewController, employee = sourceViewController.employee
        {
            if let selectedIndexPath = tableView.indexPathForSelectedRow
            {
                // Update an existing employee.
                employees[selectedIndexPath.row] = employee
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            else
            {
                // Add a new employee.
                let newIndexPath = NSIndexPath(forRow: employees.count, inSection: 0)
                employees.append(employee)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            deleteEmployeesAndReInsert()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowDetail"
        {
            let employeeDetailViewController = segue.destinationViewController as! EmployeeViewController
            
            // Get the cell that generated this segue.
            if let selectedEmployeeCell = sender as? EmployeeTableViewCell
            {
                let indexPath = tableView.indexPathForCell(selectedEmployeeCell)!
                let selectedEmployee = employees[indexPath.row]
                employeeDetailViewController.employee = selectedEmployee
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new employee.")
        }
    }
    
    // Reads The Employee Array And Inserts All
    func insertEmployees()
    {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        for item in employees
        {
            let newUser = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context)
            
            // Prep The Image For Core Data
            let image = item.photo
            let imageData = NSData(data: UIImageJPEGRepresentation(image!, 1.0)!)
            
            
            // Set Its Properties
            newUser.setValue(item.name, forKey: "name")
            newUser.setValue(item.title, forKey: "title")
            
            if(imageData.length > 0) {
                newUser.setValue(imageData, forKey: "photo")
            }
            
            // Gotta check if its already in DB
            if(doesEmployeeExistInCoreData(newUser) == false)
            {
                // Persist
                do
                {
                    try context.save()
                }
                catch
                {
                    print("Error saving data")
                }
            }
        }
    }
    
    // Deletes All Employees
    func deleteEmployeesAndReInsert()
    {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        do
        {
            // Set up Request To Get All Records
            let request = NSFetchRequest(entityName: "Employee")
            
            // Now Create A Delete Request Using All Those Records
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
            // Execute The Delete
            try context.executeRequest(deleteRequest)
            
            insertEmployees()
        }
        catch
        {
            print("Error deleting all employees data")
        }
    }
    
    func doesEmployeeExistInCoreData(employee: NSManagedObject) -> Bool
    {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext

        // Assign the properties we seek to variables
        let seekingName = employee.valueForKey("name")
        let seekingTitle = employee.valueForKey("title")
        let seekingPhoto = employee.valueForKey("photo")
        
        do
        {
            // Set up Request
            let request = NSFetchRequest(entityName: "Employee")
            
            // Setup Sorting Alphabetically
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            // Get Them Back (Alphabetically At This Point)
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0
            {
                for items in results as! [NSManagedObject]
                {
                    let name = items.valueForKey("name")
                    let title = items.valueForKey("title")
                    let photo = items.valueForKey("photo")
                    
                    
                    if(seekingName as! String == name as! String)
                    {
                        if(seekingTitle as! String == title as! String)
                        {
                            if(seekingPhoto as! NSData == photo as! NSData)
                            {
                                print("We Got A Hit From Our Database")
                                return(true)
                            }
                        }
                    }
                    
                }
            }
        }
        catch
        {
            print("Error pulling data")
        }
        return(false)
    }
    
    // Return A Array Of Employees
    func loadEmployees() -> [Employee]
    {
        var returnList = [Employee]()
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        do
        {
            // Set up Request
            let request = NSFetchRequest(entityName: "Employee")
            
            // Setup Sorting Alphabetically
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            // Get Them Back (Alphabetically At This Point)
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0
            {
                for items in results as! [NSManagedObject]
                {
                    let name = items.valueForKey("name")
                    let title = items.valueForKey("title")
                    let photo = UIImage(data: items.valueForKey("photo")! as! NSData)
                    
                    
                    if(returnList.last?.name != name as? String)
                    {
                        if(returnList.last?.title != title as? String)
                        {
                            if(returnList.last?.photo != items.valueForKey("photo") as! NSData)
                            {
                                returnList.append(Employee(name: name as! String, title: title as! String, photo: photo)!)
                                print(name!, title!)
                            }
                        }
                    }
                }
            }
        }
        catch
        {
            print("Error pulling data")
        }
        return returnList
    }
}
