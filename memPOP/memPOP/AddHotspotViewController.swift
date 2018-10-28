//
//  AddHotspotViewController.swift
//  memPOP
//
//  Created by Emily on 2018-10-23.
//  Copyright © 2018 Iota Inc. All rights reserved.
//

import UIKit

class AddHotspotViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var hotspotName: UITextField!
    @IBOutlet weak var hotspotAddress: UITextField!
    @IBOutlet weak var hotspotTransportation: UISegmentedControl!
    @IBOutlet weak var hotspotCategory: UISegmentedControl!
    @IBOutlet weak var hotspotInfo: UITextView!
    @IBOutlet weak var hotspotTodoList: UITextView!
    @IBOutlet weak var hotspotImage: UIImageView!
    
    var categoryChosen:String = ""
    var transportationChosen:String = ""
    
    var hotspots = [HotspotMO]()

    
    @IBAction func ImportPhoto(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imageView.image = image
        }
        else
        {
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a border around the description UI textfield, and image view
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.black.cgColor
        
        hotspotName.delegate = self
        hotspotAddress.delegate = self
        
        
    
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func donePressed(_ sender: UIButton) {
        let name = hotspotName.text!
        let address = hotspotAddress.text!
        
        let newHotspot = HotspotMO(context: PersistenceService.context)
        newHotspot.name = name
        newHotspot.address = address
        
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
        
        if(hotspotTransportation.selectedSegmentIndex == 1) {
            newHotspot.transportation = hotspotTransportation.titleForSegment(at: 1)!
        }
        else {
            newHotspot.transportation = hotspotTransportation.titleForSegment(at: 0)!
        }
        
        if(hotspotTodoList.text != nil) {
            newHotspot.todoList = hotspotTodoList.text! as String
        }
        
        if(hotspotInfo.text != nil) {
            newHotspot.info = hotspotInfo.text! as String
        }

        if(hotspotImage.image != nil) {
            newHotspot.picture = UIImageJPEGRepresentation(hotspotImage.image!, 1)! as NSData
        }  
        
        PersistenceService.saveContext()
        
        self.hotspots.append(newHotspot)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    

}
