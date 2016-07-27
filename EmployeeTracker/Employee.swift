//
//  Employee.swift
//  EmployeeTracker
//
//  Created by Catalyst IT on 7/25/16.
//  Copyright © 2016 Catalyst DevWorks. All rights reserved.
//

import UIKit
import Foundation
import CoreData

/*
    First off...
        I appologize for how terrible this is. Its not just terrible, its TERRIBLE.
        So I plan on redoing this in a more thought out manner taking the lessons I learned here in mind.
 
    Secondly...
        It works. Shocking right? Yeah I know
 
 
    - Nick
*/

class Employee
{
    // MARK: Properties
    var name : String
    var title : String
    var photo : UIImage?
    

    // MARK: Constructor
    init?(name: String, title : String, photo: UIImage?)
    {
        // Initialize stored properties.
        self.name = name
        self.title = title
        self.photo = photo
        
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || title.isEmpty {
            return nil
        }
    }
}