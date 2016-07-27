//
//  EmployeeViewController.swift
//  EmployeeTracker
//
//  Created by Catalyst IT on 7/25/16.
//  Copyright © 2016 Catalyst DevWorks. All rights reserved.
//

import UIKit
import CoreData

class EmployeeViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var employee : Employee?
    
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        checkValidEmployeeNameAndTitle()
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func checkValidEmployeeNameAndTitle()
    {
        // Disable the Save button if the text field's are empty.
        let nameText = nameTextField.text ?? ""
        let titleText = titleTextField.text ?? ""
        saveButton.enabled = !nameText.isEmpty || !titleText.isEmpty
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Navigation
    @IBAction func saveButton(sender: UIButton)
    {
        print("Hit On Save Button!")
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        // Add New User
        let newUser = NSEntityDescription.insertNewObjectForEntityForName("Employee", inManagedObjectContext: context)
        
        // Prep The Image For Core Data
        let image = photoImageView.image
        let imageData = NSData(data: UIImageJPEGRepresentation(image!, 1.0)!)
        
        
        // Set Its Properties
        newUser.setValue(nameTextField.text, forKey: "name")
        newUser.setValue(titleTextField.text, forKey: "title")
        
        if(imageData.length > 0)
        {
            newUser.setValue(imageData, forKey: "photo")
        }
        
        // Persist
        do
        {
            try context.save()
        }
        catch
        {
            print("Error saving data")
        }
        
        // Not Sure I Need This
        context.refreshAllObjects()
    }
    
    
    @IBAction func cancelButton(sender: UIButton)
    {
        let isPresentingInAddEmployeeMode = presentingViewController is UINavigationController
        
        if isPresentingInAddEmployeeMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if saveButton === sender
        {
            let name = nameTextField.text ?? ""
            let title = titleTextField.text ?? ""
            let photo = photoImageView.image
            
            employee = Employee(name: name, title : title, photo: photo)
        }
    }
    
    // MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer)
    {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }

    // MARK: Parent Member Functions
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        if let employee = employee {
            nameTextField.text   = employee.name
            titleTextField.text  = employee.title
            photoImageView.image = employee.photo
        }
        checkValidEmployeeNameAndTitle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

