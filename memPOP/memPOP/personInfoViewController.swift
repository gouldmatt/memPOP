//  personInfoViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-24.
//  Programmers: Matthew Gould
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// Changes that have been made in v2.0
// Added name textfield and autofill address


import CoreData
import UIKit
import MapKit
import Charts

class personInfoViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
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
    
    // Statistics
    var months: [String]!
    var hotspotsCount = [Int]()
    var categories: [String]!
    var count = [Int]()
    weak var axisFormatDelegate: IAxisValueFormatter?

    //===================================================================================================
    // Outlets
    //===================================================================================================
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dialogCheck: UITextField!
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    //===================================================================================================
    // Actions
    //===================================================================================================
    @IBAction func donePressed(_ sender: Any) {
    
        // Check that name and address are filled before saving
        if (nameField.text!.isEmpty || searchBar.text!.isEmpty){
            dialogCheck.isHidden = false
            dialogCheck.layer.borderWidth = 0.0
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
                newHotspot.longitude = searchAddressLongitude
                newHotspot.latitude = searchAddressLatitude
                
                newHotspot.addToPhotos(newPhoto)
            }
            else {
                user?.name = nameField.text
                if(changedAddress){
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
        do {
            let userFetch = try PersistenceService.context.fetch(fetchUser)
            let hotspotFetch = try PersistenceService.context.fetch(fetchHotspot)
            
            if(userFetch.count == 1){
                user = userFetch[0]
                nameField.text = user?.name
                searchBar.text = hotspotFetch[0].address
                loadPieChart(foodCount: Double((user?.foodNum)!), funCount: Double((user?.funNum)!), taskCount: Double((user?.taskNum)!))
            }
        }
        catch {
            print("failed user fetch")
        }
        
        // Fetch Statistics
        axisFormatDelegate = self
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        hotspotsCount = [20, 4, 6, 3, 12, 16, 4, 18, 2, 4, 5, 4]
        loadBarChart(dataEntryX: months, dataEntryY: hotspotsCount)
        //loadPieChart(foodCount: Double(foodCount!), funCount: Double(funCount!), taskCount: Double(taskCount!))
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
        for i in 0..<forX.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]) , data: months as AnyObject?)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = [UIColor(red: 255/255, green: 119/255, blue: 119/255, alpha: 1)]
        let chartData = BarChartData(dataSet: chartDataSet)
        barChart.data = chartData
        
        // Set up some chart configurations
        barChart.chartDescription?.text = ""
        barChart.rightAxis.enabled = false
        barChart.legend.enabled = false
        let xAxisValue = barChart.xAxis
        barChart.xAxis.labelPosition = .bottom
        
        // Don't skip x-axis values
        // barChart.xAxis.setLabelCount(12, force: true)
        xAxisValue.valueFormatter = axisFormatDelegate
    }
    
    // Create the pie chart showing categories division
    func loadPieChart(foodCount: Double, funCount: Double, taskCount: Double) {
        
        var dataEntries:[PieChartDataEntry] = []

        let food = PieChartDataEntry(value: foodCount)
        food.label = "Food"
        let fun = PieChartDataEntry(value: funCount)
        fun.label = "Fun"
        let task = PieChartDataEntry(value: taskCount)
        task.label = "Task"
        
        dataEntries = [food, fun, task]
        
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        let chartData = PieChartData(dataSet: chartDataSet)
        chartDataSet.colors = ChartColorTemplates.colorful()
        pieChart.data = chartData
        
        // Set up some chart configurations
        pieChart.chartDescription?.text = ""
        pieChart.legend.enabled = false
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
        
        // Autocomplete the address and update the results on the table view
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        
        // Handle error
        print("Error in getting results for address")
    }
}

extension personInfoViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value)]
    }
}





