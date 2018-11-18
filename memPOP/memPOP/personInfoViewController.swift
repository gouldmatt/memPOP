//  personInfoViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-24.
//  Programmers:
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// Changes that have been made in v2.0


import CoreData
import UIKit
import MapKit
class personInfoViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //===================================================================================================
    // Constants
    //===================================================================================================
    let fetchHotspot: NSFetchRequest<HotspotMO> = HotspotMO.fetchRequest()
    let fetchUser: NSFetchRequest<PersonInfoMO> = PersonInfoMO.fetchRequest()
    
    
    //===================================================================================================
    // Variables declaration
    //===================================================================================================
    var user: PersonInfoMO?
    
    // For getting the address
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var searchAddressChosen:String = ""
    var searchAddressLatitude:Double = 0.0
    var searchAddressLongitude:Double = 0.0
    var changedAddress: Bool = false

    //===================================================================================================
    // Outlets
    //===================================================================================================
    @IBOutlet var nameField: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var dialogCheck: UITextField!
    
    //===================================================================================================
    // Actions
    //===================================================================================================
    @IBAction func donePressed(_ sender: Any) {
    
        // Check that name and address are filled before saving
        if (nameField.text!.isEmpty || searchBar.text!.isEmpty){
            dialogCheck.isHidden = false
            if (nameField.text!.isEmpty) {
                nameField.layer.borderWidth = 1.0
                let layerColor : UIColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
                nameField.layer.borderColor = layerColor.cgColor
                
            }
            else {
                nameField.layer.borderWidth = 0.0
            }
            
            
            if (searchBar.text!.isEmpty) {
                self.searchBar.setTextFieldColor(color: UIColor.red.withAlphaComponent(1))
            }
            else {
                self.searchBar.setTextFieldColor(color: UIColor.white.withAlphaComponent(0))
                
            }
        }
        else {
            // create a new user or update existing user info
            if(user == nil){
                let newUser = PersonInfoMO(context: PersistenceService.context)
                newUser.name = nameField.text
                
                let newHotspot = HotspotMO(context: PersistenceService.context)
                let newPhoto = PhotosMO(context: PersistenceService.context)
                
                newPhoto.photo = UIImageJPEGRepresentation((UIImage(named: "home"))!, 1)! as NSData
                
                newHotspot.name = "Home"
                newHotspot.address = searchAddressChosen
                
                newHotspot.addToPhotos(newPhoto)
                
            }
            else {
                user?.name = nameField.text
                if(changedAddress){
                    user?.homeLat = searchAddressLatitude
                    user?.homeLong = searchAddressLongitude
                    user?.homeAddress = searchAddressChosen
                
                    do{
                        let homeHotspot = try PersistenceService.context.fetch(fetchHotspot)[0]
                        homeHotspot.address = searchAddressChosen
                        homeHotspot.longitude = searchAddressLongitude
                        homeHotspot.latitude = searchAddressLatitude
                        
                    }
                    catch {
                        print("failed hotspot fetch")
                    }
                    changedAddress = false
                }
            }

            PersistenceService.saveContext()
            
            // move back to start screen
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is personInfoViewController {
                    self.navigationController!.popViewController(animated: true)
                }
            }
        }
    }
    
    
    //===================================================================================================
    // Override Functions
    //===================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dialogCheck.isHidden = true
        
        // For autocomplete table view
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchResultsTableView.alpha = 0.0
        self.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.searchResultsTableView.layer.cornerRadius = 10;
        
        // For search bar button
        self.searchCompleter.delegate = self
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search the location"
        self.searchBar.returnKeyType = UIReturnKeyType.done
        self.searchBar.searchBarStyle = .minimal
        
        // fetch any existing user information 
        do{
            let userFetch = try PersistenceService.context.fetch(fetchUser)
            
            if(userFetch.count == 1){
                user = userFetch[0]
                nameField.text = user?.name
                searchBar.text = user?.homeAddress
            }
        } catch {
            print("failed user fetch")
        }
        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //===================================================================================================
    // Functions
    //===================================================================================================
    // https://www.youtube.com/watch?v=LrCqXmHenJY
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of items for each tableview
        
        var count : Int?
        

        count = searchResults.count
        
        return count!
        
    }
    
    // https://www.youtube.com/watch?v=LrCqXmHenJY
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        var cell : UITableViewCell?
        
        
        let searchResult = searchResults[indexPath.row]
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell!.textLabel?.text = searchResult.title
        cell!.detailTextLabel?.text = searchResult.subtitle
        
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        changedAddress = true 
        
        // Check which item is selected for each table view
        
        print("did select:  \(indexPath.row)    ")
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        let completion = searchResults[indexPath.row]
            
        if(!completion.subtitle.isEmpty && completion.subtitle != "Search Nearby") {
            searchBar.text? = completion.subtitle
        }
        else {
            if(!completion.title.isEmpty) {
                searchBar.text? = completion.title
            }
            else {
                print("No title or subtitle for this address")
            }
        }
            
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
            
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
                
            // Store the address of the location for later use
            self.searchAddressChosen = self.searchBar.text!
            self.searchAddressLatitude = coordinate!.latitude
            self.searchAddressLongitude = coordinate!.longitude
                
            print(String(describing: coordinate))
        }
        
        return indexPath
    }
}

/* Used code from https://stackoverflow.com/questions/13817330/how-to-change-inside-background-color-of-uisearchbar-component-on-ios */
extension UISearchBar {
    
    // Get the type of element that we are modifying
    private func getViewElement<T>(type: T.Type) -> T? {
        let svs = subviews.flatMap {$0.subviews}
        guard let element = (svs.filter {$0 is T}).first as? T else {return nil}
        return element
    }
    
    // Set the color of the border
    private func setTextColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                //textField.layer.backgroundColor = color.cgColor
                textField.layer.borderColor = color.cgColor
                textField.layer.borderWidth = 1.0;
                
            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }
}

extension personInfoViewController : UISearchBarDelegate {
    
    func searchBar( _ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Check when the text changes within the search bar and update it
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // Clicking on the 'X' will clear the text in the search bar
        searchBar.text = ""
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // When editing text within the search bar, show the table view with all its contents
        searchResultsTableView.alpha = 1.0
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        // When done editing, hide the table view
        searchResultsTableView.alpha = 0.0
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // When pressing "Done" from keyboard, hide the keyboard
        searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
        
        if(searchBar.text == "" || searchBar.text == nil) {
            searchAddressChosen = ""
            searchAddressLatitude = 0.0
            searchAddressLongitude = 0.0
        }
        
        print("Address Chosen: \(searchAddressChosen)")
        print("Latitude: \(searchAddressLatitude)")
        print("Longitude: \(searchAddressLongitude)")
        
    }
    
}

extension personInfoViewController : MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        // Autocomplete the address and update the results on the table view
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        
        // Handle error
        print("Error in getting results for address")
    }
}




