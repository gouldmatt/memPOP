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
        PersistenceService.saveContext()
        
        // Add to the list of created hotspots
        self.hotspots.append(newHotspot)
        
        // Update the navigation bar back button so that when back is pressed on the main display screen
        // it will take the user to the start screen instead of the add hotspot form again
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is AddHotspotViewController {
                self.navigationController!.popViewController(animated: true)
            }
        }
    }
    
    // Show an alert when the user wants to delete a hotspot
    @IBAction func deleteButtonIsTapped(_ sender: UIButton) {
        // Create the alert
        let alert = UIAlertController(title: "Deleting Hotspot", message: "Are you sure you wish to delete this Hotspot? Changes will not be saved.", preferredStyle: .alert)
        
        // Create the actions
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            (action:UIAlertAction) in
            print ("pressed Delete")
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
        guard
            let name = hotspotName.text, !name.isEmpty,
            let address = hotspotAddress.text, !address.isEmpty
            else {
                doneButton.isEnabled = false
                return
        }
        doneButton.isEnabled = true
    }
    //---------------------------------------------------------------------------------------------------

    //===================================================================================================
    // Override Functions
    //===================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a border around the description UI textfield, and image view
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        hotspotName.delegate = self
        hotspotAddress.delegate = self
        todoItem.delegate = self 
        
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
        
        // Done button should only be enabled when the hotspot and address is filed
        doneButton.isEnabled = false
        [hotspotName, hotspotAddress].forEach({ $0.addTarget(self, action: #selector(editChanged), for: .editingChanged) })
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
        descriptionPlaceholder.isHidden = !descriptionTextView.text.isEmpty
    }
    
    // Choosing an image from pictures library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imagePicked = info[UIImagePickerControllerOriginalImage] as? UIImage {
            addedImages.append(imagePicked)
            print("picked pass")
        }
        else {
            print("fail")
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
            self.list.remove(at:indexPath.row)
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
    
    // Delete image from CollectionView Object
    @objc func deletePhoto(sender:UIButton) {
        let i : Int = (sender.layer.value(forKey: "index")) as! Int
        addedImages.remove(at: i)
        print("Removed image.")
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
