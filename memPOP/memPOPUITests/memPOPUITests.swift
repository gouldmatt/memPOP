//  memPOPUITests.swift
//  memPOPUITests
//  Group 9, Iota Inc.
//  Created by nla52 on 10/23/18.
//  Programmers: Emily Chen, Matthew Gould, Diego Martin Marcelo
//  Copyright © 2018 Iota Inc. All rights reserved.

import XCTest

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        }
        else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }
}

class memPOPUITests: XCTestCase {
    
        
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launch()
        print("SETUP")
        
    }
    
    // Test the start button linkage to main display
    func testStartButton() {
        let app = XCUIApplication()
        app.buttons["Start"].tap()
    }
    
    func testAddHotspot() {

        let app = XCUIApplication()
        let app2 = app
        app.alerts["Welcome to Mem-POP!"].buttons["Get Started"].tap()
        app.otherElements.containing(.navigationBar, identifier:"Personal Information").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element.tap()
        
        let tKey = app2/*@START_MENU_TOKEN@*/.keys["t"]/*[[".keyboards.keys[\"t\"]",".keys[\"t\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        tKey.tap()

        let returnButton = app2/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        returnButton.tap()
        app.searchFields["Search the location"].tap()
        
        let sKey = app2/*@START_MENU_TOKEN@*/.keys["S"]/*[[".keyboards.keys[\"S\"]",".keys[\"S\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        sKey.tap()
        app2.tables/*@START_MENU_TOKEN@*/.staticTexts["8888 University Dr, Burnaby BC V5A 1S6, Canada"]/*[[".cells.staticTexts[\"8888 University Dr, Burnaby BC V5A 1S6, Canada\"]",".staticTexts[\"8888 University Dr, Burnaby BC V5A 1S6, Canada\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.keyboards.buttons["Done"].tap()
        app.buttons["Done"].tap()
        app.buttons["Start"].tap()
        app.buttons["Add Hotspot"].tap()
        
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.children(matching: .textField).element.tap()
        tKey.tap()
        returnButton.tap()
        
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.searchFields["Search the location"].tap()
        
        let tKey2 = app2/*@START_MENU_TOKEN@*/.keys["T"]/*[[".keyboards.keys[\"T\"]",".keys[\"T\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        tKey2.tap()
        app2/*@START_MENU_TOKEN@*/.tables/*[[".scrollViews.tables",".tables"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"Target").staticTexts["Search Nearby"].tap()
    
        app2/*@START_MENU_TOKEN@*/.textViews.containing(.staticText, identifier:"Record your memories here in detail").element/*[[".scrollViews.textViews.containing(.staticText, identifier:\"Record your memories here in detail\").element",".textViews.containing(.staticText, identifier:\"Record your memories here in detail\").element"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tKey2.tap()
        returnButton.tap()
        app/*@START_MENU_TOKEN@*/.scrollViews.containing(.staticText, identifier:"   About This Memory").element.swipeRight()/*[[".scrollViews.containing(.button, identifier:\"Add Image\").element",".swipeUp()",".swipeRight()",".scrollViews.containing(.staticText, identifier:\"   Add Photos\").element",".scrollViews.containing(.staticText, identifier:\"   To-Do List\").element",".scrollViews.containing(.staticText, identifier:\"   Description\").element",".scrollViews.containing(.staticText, identifier:\"Transportation:\").element",".scrollViews.containing(.staticText, identifier:\"Category:\").element",".scrollViews.containing(.staticText, identifier:\"Address:\").element",".scrollViews.containing(.staticText, identifier:\"Name:\").element",".scrollViews.containing(.staticText, identifier:\"   About This Memory\").element"],[[[-1,10,1],[-1,9,1],[-1,8,1],[-1,7,1],[-1,6,1],[-1,5,1],[-1,4,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        elementsQuery.textFields["Enter an item and click on '+' to add to your list"].tap()
        tKey.tap()
        returnButton.tap()
        elementsQuery.buttons["Button"].tap()
        scrollViewsQuery.children(matching: .table).element.swipeUp()
        elementsQuery.buttons["Done"].tap()
        app2.collectionViews/*@START_MENU_TOKEN@*/.images["defaultPhoto"]/*[[".cells.images[\"defaultPhoto\"]",".images[\"defaultPhoto\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    
    }
    
    func testEditButton() {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        
        let editHotspotButton = app.buttons["Edit Hotspot"]
        editHotspotButton.tap()
        editHotspotButton.tap()
        
    }
    
    func testDeleteHotspot() {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Edit Hotspot"].tap()
        app.collectionViews.cells.otherElements.containing(.image, identifier:"defaultPhoto").buttons["Button"].tap()
        app/*@START_MENU_TOKEN@*/.scrollViews.containing(.staticText, identifier:"   About This Memory").element.swipeRight()/*[[".scrollViews.containing(.button, identifier:\"Add Image\").element",".swipeUp()",".swipeRight()",".scrollViews.containing(.staticText, identifier:\"   Add Photos\").element",".scrollViews.containing(.staticText, identifier:\"   To-Do List\").element",".scrollViews.containing(.staticText, identifier:\"   Description\").element",".scrollViews.containing(.staticText, identifier:\"Transportation:\").element",".scrollViews.containing(.staticText, identifier:\"Category:\").element",".scrollViews.containing(.staticText, identifier:\"Address:\").element",".scrollViews.containing(.staticText, identifier:\"Name:\").element",".scrollViews.containing(.staticText, identifier:\"   About This Memory\").element"],[[[-1,10,1],[-1,9,1],[-1,8,1],[-1,7,1],[-1,6,1],[-1,5,1],[-1,4,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        app.scrollViews.otherElements.buttons["Delete"].tap()
        app.alerts["Deleting Hotspot"].buttons["Delete"].tap()
        
    }
   
    func testHotspotOverview () {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.collectionViews.cells.otherElements.children(matching: .image).element.tap()
        
    }
    
    func testHotspotNavigation () {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.collectionViews.cells.otherElements.children(matching: .image).element.tap()
        
        let app2 = app
        app2/*@START_MENU_TOKEN@*/.buttons["Navigation"]/*[[".segmentedControls.buttons[\"Navigation\"]",".buttons[\"Navigation\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app2/*@START_MENU_TOKEN@*/.buttons["Overview"]/*[[".segmentedControls.buttons[\"Overview\"]",".buttons[\"Overview\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
    }
    
    func testHotspotEdit() {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Edit Hotspot"].tap()
        
        let app2 = app
        app2.collectionViews/*@START_MENU_TOKEN@*/.buttons["Button"]/*[[".cells.buttons[\"Button\"]",".buttons[\"Button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.children(matching: .textView).element.tap()
        app2/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app2/*@START_MENU_TOKEN@*/.staticTexts["   To-Do List"]/*[[".scrollViews.staticTexts[\"   To-Do List\"]",".staticTexts[\"   To-Do List\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        scrollViewsQuery.otherElements.buttons["Done"].tap()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
    }
}
