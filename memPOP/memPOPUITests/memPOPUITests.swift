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

class memaPOPUITests: XCTestCase {
    
        
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launch()
        print("SETUP")
        
    }
    
    ///////// Important: Make sure this is not the first time using the app since notifications will not be clickable from the simulator ///////////
    
    // Test the start button linkage to main display
    func testaPersonalButton() {
        
        let app = XCUIApplication()
        app.buttons["Personal Info"].tap()
        app.scrollViews.otherElements.buttons["Done"].tap()
    
    }
    
    func testbStartButton() {
        XCUIApplication().buttons["Start"].tap()
        
    }
    
    func testcEditButton() {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        
        let editHotspotButton = app.buttons["Edit Hotspot"]
        editHotspotButton.tap()
        editHotspotButton.tap()

    }
    
    func testdAddHotspot() {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Add Hotspot"].tap()
        
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.children(matching: .textField).element.tap()
        
        let aKey = app/*@START_MENU_TOKEN@*/.keys["a"]/*[[".keyboards.keys[\"a\"]",".keys[\"a\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        aKey.tap()
        
        let returnButton = app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        returnButton.tap()
        
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.searchFields["Search the location"].tap()
        
        let aKey2 = app/*@START_MENU_TOKEN@*/.keys["A"]/*[[".keyboards.keys[\"A\"]",".keys[\"A\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        aKey2.tap()
        
        let app2 = app
        app2/*@START_MENU_TOKEN@*/.tables.staticTexts["3211 Grant McConachie Way, Richmond BC V7B 0A4, Canada"]/*[[".scrollViews.tables",".cells.staticTexts[\"3211 Grant McConachie Way, Richmond BC V7B 0A4, Canada\"]",".staticTexts[\"3211 Grant McConachie Way, Richmond BC V7B 0A4, Canada\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        app2/*@START_MENU_TOKEN@*/.textViews.containing(.staticText, identifier:"Record your memories here in detail").element/*[[".scrollViews.textViews.containing(.staticText, identifier:\"Record your memories here in detail\").element",".textViews.containing(.staticText, identifier:\"Record your memories here in detail\").element"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        aKey2.tap()
        returnButton.tap()
        app2/*@START_MENU_TOKEN@*/.staticTexts["   Description"]/*[[".scrollViews.staticTexts[\"   Description\"]",".staticTexts[\"   Description\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        elementsQuery.buttons["Done"].tap()
        
        
    }

    func testeDeleteHotspot() {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Edit Hotspot"].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"a").buttons["Button"].tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["   To-Do List"]/*[[".scrollViews.staticTexts[\"   To-Do List\"]",".staticTexts[\"   To-Do List\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        app.scrollViews.otherElements.buttons["Delete"].tap()
        app.alerts["Deleting Hotspot"].buttons["Delete"].tap()
        

    }

    func testfHotspotOverview () {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Home").images["defaultPhoto"].tap()
        

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
    }
}
