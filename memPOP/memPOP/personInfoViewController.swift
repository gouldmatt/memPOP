//  personInfoViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-24.
//  Programmers: Emily Chen, Matthew Gould, Diego Martin Marcelo
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// Changes that have been made in v2.0
// Added name textfield and autofill address

//===================================================================================================
// Changes that have been made in v3.0
// Added multiple checks to ensure users inputs required information with its correct format
// Added warning message and scrolling to top when user puts invalid inputs
// Added a way to manage hiding/showing sections based on the user's statistics
// Implemented Pie and Bar charts using Cocopoads/Charts library for displaying statistics
// Updated contraints and UI elements such as colors and sizes for the view controller

import CoreData
import UIKit
import MapKit
import Charts

class personInfoViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
    //===================================================================================================
    // MARK: Constants
    //===================================================================================================
    let fetchHotspot: NSFetchRequest<HotspotMO> = HotspotMO.fetchRequest()
    let fetchUser: NSFetchRequest<PersonInfoMO> = PersonInfoMO.fetchRequest()
    
    //===================================================================================================
    // MARK: Variables declaration
    //===================================================================================================
    var user: PersonInfoMO?
    
    // For getting the address
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var searchAddressChosen:String = ""
    var searchAddressLatitude:Double = 0.0
    var searchAddressLongitude:Double = 0.0
    var changedAddress: Bool = false
    
    // Statistics
    var hotspotNames = [String]()
    var hotspotsCount = [Int]()
    var categories: [String]!
    var count = [Int]()
    weak var axisFormatDelegate: IAxisValueFormatter?

    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dialogCheck: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emergencyTextField: UITextField!
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    
    @IBOutlet var pieChartLabel: UILabel!
    @IBOutlet var barChartLabel: UILabel!
    
    @IBOutlet var pieChartLabelHeight: NSLayoutConstraint!
    @IBOutlet var barChartLabelHeight: NSLayoutConstraint!
    
    
    @IBOutlet var pieChartHeight: NSLayoutConstraint!
    @IBOutlet var barChartHeight: NSLayoutConstraint!
    
    //===================================================================================================
    // MARK: Actions
    //===================================================================================================
    @IBAction func donePressed(_ sender: Any) {
    
        // Reference color used for warning messages
        let layerColor : UIColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        
        // Reference to the top of the view controller for scrolling
        let top = CGPoint.init(x: 0.0, y: -(self.scrollView.contentInset.top))
        
        // Check that name and address are filled before saving
        if (nameField.text!.isEmpty || searchBar.text!.isEmpty || emergencyTextField.text!.isEmpty){
            dialogCheck.text = "Please complete the highlighted fields"
            dialogCheck.isHidden = false
            dialogCheck.layer.borderWidth = 0.0
            
            // Create a red border around the name field if empty
            if (nameField.text!.isEmpty) {
                nameField.layer.borderWidth = 1.0
                nameField.layer.borderColor = layerColor.cgColor
            }
            else {
                nameField.layer.borderWidth = 0.0
            }
            
            // Create a red border around the contact phone field if empty
            if (emergencyTextField.text!.isEmpty) {
                emergencyTextField.layer.borderWidth = 1.0
                emergencyTextField.layer.borderColor = layerColor.cgColor
            }
            else {
                emergencyTextField.layer.borderWidth = 0.0
            }
            
            // Crete a red border around the search bar field if empty
            if (searchBar.text!.isEmpty) {
                self.searchBar.setTextFieldColor(color: UIColor.red.withAlphaComponent(1))
            }
            else {
                self.searchBar.setTextFieldColor(color: UIColor.white.withAlphaComponent(0))
            }
            
            // Move the scroll view to the top
            self.scrollView.setContentOffset(top, animated: true)
        }
        else if (!(emergencyTextField.text?.isNumber)!){
            
            // Check if the the Contact field has only numbers
            dialogCheck.text = "Please enter only numbers for Contact field"
            dialogCheck.isHidden = false
            dialogCheck.layer.borderWidth = 0.0
            
            emergencyTextField.layer.borderWidth = 1.0
            emergencyTextField.layer.borderColor = layerColor.cgColor
            
            // Move the scroll view to the top
            self.scrollView.setContentOffset(top, animated: true)
            
        }
        else if ((emergencyTextField.text?.count)! > 10 || (emergencyTextField.text?.count)! <= 9) {
            
            // Check for too many or too few numbers, expected is 10 numbers
            dialogCheck.text = "Please enter 10 numbers only"
            dialogCheck.isHidden = false
            dialogCheck.layer.borderWidth = 0.0
            
            emergencyTextField.layer.borderWidth = 1.0
            emergencyTextField.layer.borderColor = layerColor.cgColor
            
            // Move the scroll view to the top
            self.scrollView.setContentOffset(top, animated: true)
            
        }
        else {
            // Once all checks have passed, clear the borders
            emergencyTextField.layer.borderWidth = 0.0
            nameField.layer.borderWidth = 0.0
            
            // Create a new user or update existing user info
            if (user == nil) {
                // Creating a new user
                let newUser = PersonInfoMO(context: PersistenceService.context)
                newUser.name = nameField.text
                newUser.contactName = emergencyTextField.text
                
                // Set the default values for the notification setting to off.
                newUser.activitiesNotifSetting = 0
                newUser.addHotspotNotifSetting = 0
                
                let newHotspot = HotspotMO(context: PersistenceService.context)

                // Check for a valid address
                if (!changedAddress && (searchAddressLatitude == 0.0 || searchAddressLongitude == 0.0)) {
                    dialogCheck.text = "Please select a valid address"
                    dialogCheck.isHidden = false
                    
                    self.searchBar.setTextFieldColor(color: UIColor.red.withAlphaComponent(1))
                    
                    // Move the scroll view to the top
                    self.scrollView.setContentOffset(top, animated: true)
                }
                else {
                    newHotspot.name = "Home"
                    newHotspot.address = searchAddressChosen
                    newHotspot.longitude = searchAddressLongitude
                    newHotspot.latitude = searchAddressLatitude
                    //newHotspot.addToPhotos(newPhoto)
                    
                    // Move back to start screen
                    self.navigationController?.popToRootViewController(animated: false)
                }
            }
            else {
                // Updating an existing user
                user?.name = nameField.text
                user?.contactName = emergencyTextField.text
                
                // Check if the address has been changed, if not then no need to update it
                if (changedAddress) {
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
                
                // Move back to start screen
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                for aViewController in viewControllers {
                    if aViewController is personInfoViewController {
                        self.navigationController!.popViewController(animated: true)
                    }
                }
            }

            PersistenceService.saveContext()
        }
    }
    
    //===================================================================================================
    // MARK: Override Functions
    //===================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initiliaze variables need to be reset
        searchAddressLatitude = 0.0
        searchAddressLongitude = 0.0
        changedAddress = false
        
        // Hide the warning message by default
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
        
        axisFormatDelegate = self
        
        // Fetch any existing user information
        do {
            let userFetch = try PersistenceService.context.fetch(fetchUser)
            let hotspotFetch = try PersistenceService.context.fetch(fetchHotspot)
            
            if(userFetch.count == 1){
                user = userFetch[0]
                nameField.text = user?.name
                emergencyTextField.text = user?.contactName
                searchBar.text = hotspotFetch[0].address
                
                // Load Pie Chart with information collected from all hotspots
                loadPieChart(foodCount: Double((user?.foodNum)!), funCount: Double((user?.funNum)!), taskCount: Double((user?.taskNum)!))
                
                // Check if no categories are available and hide that section
                if(user?.foodNum == 0 && user?.funNum == 0 && user?.taskNum == 0){
                    pieChart.isHidden = true
                    pieChartHeight.constant = 0
                    pieChartLabel.isHidden = true
                    pieChartLabelHeight.constant = 0
                }
                else {
                    pieChartHeight.constant = 217
                    pieChartLabelHeight.constant = 31
                }
                
                // Reset variable
                var noVisits:Bool = true
                
                // Clear arrays from their previous values
                hotspotNames.removeAll()
                hotspotsCount.removeAll()
                
                // Cycle through all hotspots and store their name and timesVisit into arrays
                for hotspot in hotspotFetch {
                    if(hotspot.timesVisit != 0) {
                        hotspotNames.append(hotspot.name!)
                        hotspotsCount.append(Int(hotspot.timesVisit))
                        noVisits = false
                    }
                }
                
                // For debugging
                print(hotspotNames.count)
                
                // If no hotspot has yet been visited, hide that section
                if(noVisits){
                    barChart.isHidden = true
                    barChartHeight.constant = 0
                    barChartLabel.isHidden = true
                    barChartLabelHeight.constant = 0
                }
                else {
                    barChartHeight.constant = 212
                    barChartLabelHeight.constant = 31
                }
            }
            else {
                
                // Hide everything
                pieChart.isHidden = true
                pieChartHeight.constant = 0
                pieChartLabel.isHidden = true
                pieChartLabelHeight.constant = 0
                
                barChart.isHidden = true
                barChartHeight.constant = 0
                barChartLabel.isHidden = true
                barChartLabelHeight.constant = 0
            }
        }
        catch {
            print("failed user fetch")
        }
        
        // Load Bar Chart with information collected from all hotspots
        loadBarChart(dataEntryX: hotspotNames, dataEntryY: hotspotsCount)
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
    // MARK: Functions
    //===================================================================================================
    // Consulted https://www.youtube.com/watch?v=LrCqXmHenJY
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of items for each tableview
        
        var count : Int?
        count = searchResults.count
        return count!
    }
    
    // Consulted https://www.youtube.com/watch?v=LrCqXmHenJY
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        var cell : UITableViewCell?
        
        let searchResult = searchResults[indexPath.row]
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell!.textLabel?.text = searchResult.title
        cell!.detailTextLabel?.text = searchResult.subtitle
        
        return cell!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Close the keyboard on return for a textField
        textField.resignFirstResponder()
        return true
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
    
    // Create the bar chart showing the number of hotspots visited per month
    // Consulted https://stackoverflow.com/questions/39049188/how-to-add-strings-on-x-axis-in-ios-charts to create the bar chart
    func loadBarChart(dataEntryX forX:[String],dataEntryY forY: [Int]) {
        
        var dataEntries:[BarChartDataEntry] = []

        // For debugging
        print(forX.count)
        
        // Create each data entry and append to array
        for i in 0..<forX.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]) , data: hotspotNames as AnyObject?)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = [UIColor(red: 255/255, green: 119/255, blue: 119/255, alpha: 1)]
        let chartData = BarChartData(dataSet: chartDataSet)
        barChart.data = chartData
        barChart.setScaleEnabled(true) // Remove if it doesnt work
        
        // Set up some chart configurations
        barChart.chartDescription?.text = ""
        barChart.rightAxis.enabled = false
        barChart.legend.enabled = false
        barChart.xAxis.labelPosition = .bottom
        
        // Don't skip x-axis values
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: forX)

        barChart.xAxis.granularityEnabled = true
        barChart.xAxis.granularity = 1
        barChart.xAxis.wordWrapEnabled = true
        
        // barChart.xAxis.axisMinimum = 0.0
        // barChart.xAxis.avoidFirstLastClippingEnabled = false
        // barChart.xAxis.centerAxisLabelsEnabled = true
        // barChart.xAxis.setLabelCount(hotspotNames.count, force: true)
        // let xAxisValue = barChart.xAxis
        // xAxisValue.valueFormatter = axisFormatDelegate add back
    }
    
    // Create the pie chart showing categories division
    func loadPieChart(foodCount: Double, funCount: Double, taskCount: Double) {
        
        var dataEntries:[PieChartDataEntry] = []
        
        // Append only valid statistics to the array
        if(foodCount > 0) {
            let food = PieChartDataEntry(value: foodCount)
            food.label = "Food"
            dataEntries.append(food)
        }
        
        if(funCount > 0) {
            let fun = PieChartDataEntry(value: funCount)
            fun.label = "Fun"
            dataEntries.append(fun)
        }
        
        if(taskCount > 0) {
            let task = PieChartDataEntry(value: taskCount)
            task.label = "Task"
            dataEntries.append(task)
        }

        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        let chartData = PieChartData(dataSet: chartDataSet)
        chartDataSet.colors = ChartColorTemplates.colorful()
        pieChart.data = chartData
        
        // Set up some chart configurations
        pieChart.chartDescription?.text = ""
        pieChart.legend.enabled = false
    }
}

//===================================================================================================
// MARK: Extensions
//===================================================================================================
extension String {
    // Check if the string contains only numbers
    var isNumber:Bool {
        let characters = CharacterSet.decimalDigits.inverted
        return !self.isEmpty && rangeOfCharacter(from: characters) == nil
    }
}

// Used code from
// https://stackoverflow.com/questions/13817330/how-to-change-inside-background-color-of-uisearchbar-component-on-ios
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
        let size = completer.results.count
        var counter:Int = 0
        var filteredResults = [MKLocalSearchCompletion]()
        
        // Filter out any address with "Search Nearby" string
        while(counter < size) {
            if(completer.results[counter].subtitle == "Search Nearby") {
                // Do nothing
            }
            else {
                // Append to the filtered results array
                filteredResults.append(completer.results[counter])
            }
            counter = counter + 1
        }
        
        // Autocomplete the address and update the results on the table view
        searchResults = filteredResults
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        
        // Handle error
        print("Error in getting results for address")
    }
}

extension personInfoViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return hotspotNames[Int(value)]
    }
}





