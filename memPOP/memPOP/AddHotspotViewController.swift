//
//  AddHotspotViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-23.
//  Programmers: Emily Chen, Matthew Gould, Diego Martin Marcelo
//  Copyright © 2018 Iota Inc. All rights reserved.
//

// Changes that have been made
// - Description place holder text
// - Saving user inputted information
// - Done button disabling and enabling
// - Delete button dialog

import CoreData
import UIKit

class AddHotspotViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UICollectionViewDelegate,UICollectionViewDataSource, UITableViewDataSource {
    
    //===================================================================================================
    // Constants
    //===================================================================================================
    let image = UIImagePickerController()

    //===================================================================================================
    // Variables declaration
    //===================================================================================================
    var descriptionPlaceholder: UILabel!
    var categoryChosen:String = ""
    var transportationChosen:String = ""
    var list = ["My To-Do List"]
    var addedImages = [UIImage]()
    var hotspots = [HotspotMO]()
    var isHomeHotspot = false

    // For editing hotpost
    var fetchedToDos = [NSManagedObject]()
    var fetchedImages = [NSManagedObject]()
    var selectedHotspot: NSManagedObject?
    
    // Used to keep track of the NSData objects, not only UIImage objects
    // Needed when updating each photo
    var addedImagesNSData = [NSData]()
    
    //===================================================================================================
    // Outlets
    //===================================================================================================
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var hotspotName: UITextField!
    @IBOutlet weak var hotspotAddress: UITextField!
    @IBOutlet weak var hotspotTransportation: UISegmentedControl!
    @IBOutlet weak var hotspotCategory: UISegmentedControl!
    @IBOutlet weak var hotspotInfo: UITextView!
    
    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var todoItem: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var dialogCheck: UITextField!
    
    //===================================================================================================
    // Actions
    //===================================================================================================
    
    @IBAction func ImportPhoto(_ sender: Any) {
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        image.allowsEditing = false
        self.present(image, animated: true, completion: nil)
    }
    
    @IBAction func addToDo(_ sender: Any) {
        if (todoItem.text != "") {
            list.append("- " + todoItem.text!)
            todoItem.text = ""
            tableView.reloadData()
        }
    }
    
    // Action needed to save all the attributes for a single hotspot and their relationships
    @IBAction func donePressed(_ sender: UIButton) {
        
        if (hotspotName.text!.isEmpty || hotspotAddress.text!.isEmpty)
        {
            dialogCheck.isHidden = false
            if (hotspotName.text!.isEmpty) {
                hotspotName.layer.borderWidth = 1.0
                let layerColor : UIColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
                hotspotName.layer.borderColor = layerColor.cgColor
                
            }
            else {
                hotspotName.layer.borderWidth = 0.0
            }
            
            if (hotspotAddress.text!.isEmpty) {
                hotspotAddress.layer.borderWidth = 1.0
                let layerColor : UIColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
                hotspotAddress.layer.borderColor = layerColor.cgColor
            }
            else {
                hotspotAddress.layer.borderWidth = 0.0
            }
        }
        else {
            dialogCheck.isHidden = true

            if( selectedHotspot == nil) {
                let name = hotspotName.text!
                let address = hotspotAddress.text!
                let newHotspot = HotspotMO(context: PersistenceService.context)
                var newPhotos = [PhotosMO(context: PersistenceService.context)]
                var newToDos = [ToDoMO(context: PersistenceService.context)]
     
                var index: Int = 0
                
                // Update the attribute values of the hotspot object
                newHotspot.name = name
                newHotspot.address = address
                
                // Check the category selected
                if(hotspotCategory.selectedSegmentIndex == 1) {
                    newHotspot.category = hotspotCategory.titleForSegment(at: 1)!
                }
                else if (hotspotCategory.selectedSegmentIndex == 2) {
                    newHotspot.category = hotspotCategory.titleForSegment(at: 2)!
                }
                else if (hotspotCategory.selectedSegmentIndex == 3) {
                    newHotspot.category = hotspotCategory.titleForSegment(at: 3)!
                }
                else {
                    newHotspot.category = hotspotCategory.titleForSegment(at: 0)!
                }
                
                // Check the method of transportation selected
                if(hotspotTransportation.selectedSegmentIndex == 1) {
                    newHotspot.transportation = hotspotTransportation.titleForSegment(at: 1)!
                }
                else {
                    newHotspot.transportation = hotspotTransportation.titleForSegment(at: 0)!
                }
                
                // Check that the description is not an empty string
                if(hotspotInfo.text != nil) {
                    newHotspot.info = hotspotInfo.text! as String
                }
                
                // Pass all the images to the Photos object
                for image in addedImages{
                    newPhotos.append(PhotosMO(context: PersistenceService.context))
                    newPhotos[index].photo = UIImageJPEGRepresentation(image, 1)! as NSData
                    newHotspot.addToPhotos(newPhotos[index])
                    index = index + 1
                }
                
                index = 0
                
                // Pass all the todo list items to the ToDo object
                for listItem in list{
                    if(listItem != "My To-Do List"){
                        newToDos.append(ToDoMO(context: PersistenceService.context))
                        newToDos[index].toDoItem = listItem
                        newHotspot.addToToDo(newToDos[index])
                        index = index + 1
                    }
                }
            
                // Once all changes have been checked, save the hotspot object with all its relationships
                print("Creating new one")
                PersistenceService.saveContext()
                
                // Add to the list of created hotspots
                self.hotspots.append(newHotspot)
            }
            else {
                print("Updating one")
                let updateHotspot = selectedHotspot as! HotspotMO
                var newToDos = updateHotspot.toDo as! [ToDoMO]
                var newPhotos = updateHotspot.photos as! [PhotosMO]
                var index: Int = 0
                
                updateHotspot.name = hotspotName.text!
                updateHotspot.address = hotspotAddress.text!
                
                // Check the category selected
                if(hotspotCategory.selectedSegmentIndex == 1) {
                    updateHotspot.category = hotspotCategory.titleForSegment(at: 1)
                }
                else if (hotspotCategory.selectedSegmentIndex == 2) {
                    updateHotspot.category = hotspotCategory.titleForSegment(at: 2)
                }
                else if (hotspotCategory.selectedSegmentIndex == 3) {
                    updateHotspot.category = hotspotCategory.titleForSegment(at: 3)
                }
                else {
                    updateHotspot.category = hotspotCategory.titleForSegment(at: 0)
                }
                
                // Check the method of transportation selected
                if(hotspotTransportation.selectedSegmentIndex == 1) {
                    updateHotspot.transportation = hotspotTransportation.titleForSegment(at: 1)
                }
                else {
                    updateHotspot.transportation = hotspotTransportation.titleForSegment(at: 0)
                }
                
                // Check that the description is not an empty string
                if(hotspotInfo.text != nil) {
                    updateHotspot.info = hotspotInfo.text
                }
                
                // Update or append Todo list
                for listItem in list{
                    if(listItem != "My To-Do List"){
                        print(list.count)
                        
                        // If our index is less than the number of todos fetched, we update the existing todos
                        if(index < newToDos.count) {
                            newToDos[index].toDoItem = listItem
                        }
                        else {
                            // If it is greater than, then we are creating new ToDoMOs
                            newToDos.append(ToDoMO(context: PersistenceService.context))
                            newToDos[index].toDoItem = listItem
                        }
                        updateHotspot.addToToDo(newToDos[index])
                        index = index + 1
                
                    }
                }
                
                index = 0
                
                // Update or append Photos
                for photoItem in addedImagesNSData{
                    // If our index is less than the number of photos fetched, we update the existing photos
                    if(index < newPhotos.count) {
                        newPhotos[index].photo = photoItem
                    }
                    else {
                        // If it is greater than, then we are creating new PhotoMOs
                        newPhotos.append(PhotosMO(context: PersistenceService.context))
                        newPhotos[index].photo = photoItem
                    }
                    updateHotspot.addToPhotos(newPhotos[index])
                    index = index + 1
                }
                
                PersistenceService.saveContext()
            }
            
            // Update the navigation bar back button so that when back is pressed on the main display screen
            // it will take the user to the start screen instead of the add hotspot form again
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is AddHotspotViewController {
                    self.navigationController!.popViewController(animated: true)
                }
            }
        }
    }
    
    // Show an alert when the user wants to delete a hotspot
    @IBAction func deleteButtonIsTapped(_ sender: UIButton) {
        
        // Check if we want to Add or Edit a hotpost
        // If adding -> "Cancel" title then no need to show warnings
        // If editing -> "Delete" title then we need to show warnings
        if(deleteButton.title(for: UIControlState.normal) == "Cancel") {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            // Create the alert
            let alert = UIAlertController(title: "Deleting Hotspot", message: "Are you sure you wish to delete this Hotspot? Changes will not be saved.", preferredStyle: .alert)
            
            // Create the actions
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
                (action:UIAlertAction) in
                print ("pressed Delete")
                
                // Deleting selected hotspot
                if(self.selectedHotspot != nil) {
                    PersistenceService.context.delete(self.selectedHotspot!)
                    PersistenceService.saveContext()
                }
                
                _ = self.navigationController?.popViewController(animated: true)
            
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (action:UIAlertAction) in
                print ("pressed Cancel")
            }
            
            // Add actions to alert
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            // Show the alert
            self.present(alert,animated: true, completion: nil)
        }
    }
    
    //---------------------------------------------------------------------------------------------------
    // The name and address fields must be filled before the done button is enabled
    //https://stackoverflow.com/questions/34941069/enable-a-button-in-swift-only-if-all-text-fields-have-been-filled-out
    @objc func editChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
    }
    //---------------------------------------------------------------------------------------------------

    //===================================================================================================
    // Override Functions
    //===================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dialogCheck.isHidden = true

        // Add a border around the description UI textfield, and image view
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        hotspotName.delegate = self
        hotspotAddress.delegate = self
        todoItem.delegate = self
        
        if(selectedHotspot == nil) {
            print("Adding")
            
            // Change the navigation title to match the action desired, in this case to "Add a Hotpost"
            self.title = "Add a Hotspot"
            
            // When we are creating a new hotspot, change the button title to "Cancel"
            deleteButton.setTitle("Cancel", for: UIControlState.normal)
            
            // Add placeholder text for text view
            // https://stackoverflow.com/questions/27652227/text-view-placeholder-swift
            descriptionTextView.delegate = self
            descriptionPlaceholder = UILabel()
            descriptionPlaceholder.text = "Record your memories here in detail"
            descriptionPlaceholder.sizeToFit()
            descriptionTextView.addSubview(descriptionPlaceholder)
            descriptionPlaceholder.frame.origin = CGPoint(x: 5, y: (descriptionTextView.font?.pointSize)! / 2)
            descriptionPlaceholder.textColor = UIColor.lightGray
            descriptionPlaceholder.isHidden = !descriptionTextView.text.isEmpty
            
            // Done button should only be enabled when the hotspot and address is filled
            doneButton.isEnabled = true
            [hotspotName, hotspotAddress].forEach({ $0.addTarget(self, action: #selector(editChanged), for: .editingChanged) })
        }
        else {
            print("Editing")
            
            // Check if editing the home hotspot, if so, disable change for the title and delete button
            if(isHomeHotspot){
                 hotspotName.isEnabled = false
                 deleteButton.isHidden = true 
            }
            
            
            // When we are editting a hotspot, change the button title to "Delete"
            deleteButton.setTitle("Delete", for: UIControlState.normal)
            
            let updateHotspot = selectedHotspot as! HotspotMO
            let todoItems = updateHotspot.toDo as! [ToDoMO]
            let photoItems = updateHotspot.photos as! [PhotosMO]
            
            // Change the navigation title to match the action desired, in this case to "Editing <HotspotName>"
            self.title = ("Editing " + updateHotspot.name!)
            
            // Check if hotspotName or hotspotAddress are empty and disable Done button
            [hotspotName, hotspotAddress].forEach({ $0.addTarget(self, action: #selector(editChanged), for: .editingChanged) })
            
            // Fetch every object for that specific hotpost to the new AddHotspotViewController //
            
            // Fetch name
            hotspotName.text = selectedHotspot?.value(forKey: "name") as? String
            
            // Fetch address
            hotspotAddress.text = selectedHotspot?.value(forKey: "address") as? String
            
            // Fetch category
            switch selectedHotspot?.value(forKey: "category") as? String {
            case "All":
                hotspotCategory.selectedSegmentIndex = 0
            case "Food":
                hotspotCategory.selectedSegmentIndex = 1
            case "Fun":
                hotspotCategory.selectedSegmentIndex = 2
            case "Task":
                hotspotCategory.selectedSegmentIndex = 3
            default:
                print("Category not found")
            }
            
            // Fetch transportation
            switch selectedHotspot?.value(forKey: "transportation") as? String {
            case "Walk":
                hotspotTransportation.selectedSegmentIndex = 0
            case "Car":
                hotspotTransportation.selectedSegmentIndex = 1
            default:
                print("Method of transportation not found")
            }
            
            // Fetch info
            hotspotInfo.text = selectedHotspot?.value(forKey: "info") as? String
            
            // Fetch toDo items
            for listItems in todoItems {
                print("list count: \(todoItems.count)")
                list.append(listItems.toDoItem!)
            }
            
            // Fetch photo items
            for images in photoItems {
                print("photo count: \(photoItems.count)")
                let imageData = images.value(forKey: "photo")
                addedImagesNSData.append(imageData as! Data as NSData)
                addedImages.append(UIImage(data: imageData as! Data)!)
            }
        }
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.setHidesBackButton(true, animated: true)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //===================================================================================================
    // Functions
    //===================================================================================================
    
    func textViewDidChange(_ descriptionTextView: UITextView) {
        if(selectedHotspot == nil) {
            descriptionPlaceholder.isHidden = !descriptionTextView.text.isEmpty
        }
    }
    
    // Choosing an image from pictures library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imagePicked = info[UIImagePickerControllerOriginalImage] as? UIImage {
            addedImages.append(imagePicked)
            addedImagesNSData.append(UIImageJPEGRepresentation(imagePicked, 1)! as NSData)
            print("Photo pick pass")
        }
        else {
            print("Photo pick fail")
        }
        collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    // https://www.youtube.com/watch?v=LrCqXmHenJY
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (list.count)
    }
    
    // https://www.youtube.com/watch?v=LrCqXmHenJY
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = list[indexPath.row]
  
        return(cell)
    }
    
    // delete an item by a left swipe
    // https://www.youtube.com/watch?v=LrCqXmHenJY
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            print("removed todo")
            
            if (selectedHotspot != nil){
                // Delete the specific toDo item at the specified index
                deleteTodo(index: indexPath.row)
            }
            
            // Then remove it from the list array
            self.list.remove(at:indexPath.row)
            
            // Update the table view to show changes
            tableView.reloadData()
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return addedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:  CollectionViewPhotoDelete = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPhotos", for: indexPath) as! CollectionViewPhotoDelete
        
        cell.image.image = addedImages[indexPath.row]
        
        // Set the value of the index at which the image is added to key "index"
        cell.deletePhotoButton?.layer.setValue(indexPath.row, forKey: "index")
        // Call the deletePhoto to delete the image at a particular index
        cell.deletePhotoButton?.addTarget(self, action: #selector((deletePhoto(sender:))), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    
    // Delete ToDo items from database
    func deleteTodo (index : Int) {
        
        let chosenHotspot = selectedHotspot as! HotspotMO
        var toDosToDelete = chosenHotspot.toDo as! [ToDoMO]
        
        if(index > fetchedToDos.count) {
            // This means that we have not yet saved any changes to the toDo list
        }
        else {
            //let toDos = fetchedToDos as? [ToDoMO]
            
            // '-1' to ignore the first line of the array
            // let toDoToDelete = toDos![index-1]
            
            let toDoToDelete = toDosToDelete[index-1]
            
            // Delete specific item from database
            PersistenceService.context.delete(toDoToDelete)
            PersistenceService.saveContext()
        }
    }
    
    // Delete Photo items from database
    func deletePhoto (index : Int) {

        let chosenHotspot = selectedHotspot as! HotspotMO
        var photosToDelete = chosenHotspot.photos as! [PhotosMO]
        
        if(index > fetchedImages.count) {
            // This means that we have not yet saved any changes to the photos list
        }
        else {
            //let photos = fetchedImages as? [PhotosMO]
        
            //let photoToDelete = photos![index]
            
            let photoToDelete = photosToDelete[index]
            
            // Delete specific item from database
            PersistenceService.context.delete(photoToDelete)
            PersistenceService.saveContext()
        }
    }
    
    // Delete image from CollectionView Object
    @objc func deletePhoto(sender:UIButton) {
        let i : Int = (sender.layer.value(forKey: "index")) as! Int
        addedImages.remove(at: i)
        
        addedImagesNSData.remove(at: i)
        
        if (selectedHotspot != nil ){
            deletePhoto(index: i)
        }
        
        print(i)
    
        print("Removed image")
        collectionView.reloadData()
    }
    
    // Close the keyboard on return for a textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Close the keyboard on return for a textView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            textView.resignFirstResponder()
            return false
        }
        return true 
    }
}
