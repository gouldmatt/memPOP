//
//  memPOPUITests.swift
//  memPOPUITests
//
//  Created by nla52 on 10/23/18.
//  Copyright © 2018 Iota Inc. All rights reserved.
//

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
        XCUIApplication().launch()
    }
    
    // Test the start button linkage to main display
    func testStartButton() {
        let app = XCUIApplication()
        app.buttons["Start"].tap()
    }
    
    // Test the add hotspot display and the delete dialog
    func testAddHotspot() {
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Add Hotspot"].tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["   To-Do List"]/*[[".scrollViews.staticTexts[\"   To-Do List\"]",".staticTexts[\"   To-Do List\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        app.scrollViews.otherElements.buttons["Delete"].tap()
        app.alerts["Deleting Hotspot"].buttons["Delete"].tap()
        app.navigationBars["Memories"].buttons["Back"].tap()
    }
    
   
    func testAddHotspotWithoutPhoto() {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Add Hotspot"].tap()
        
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.children(matching: .textField).element(boundBy: 0).tap()
        
        let aKey = app/*@START_MENU_TOKEN@*/.keys["a"]/*[[".keyboards.keys[\"a\"]",".keys[\"a\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        aKey.tap()
        aKey.tap()
        
        let app2 = XCUIApplication()
        app2/*@START_MENU_TOKEN@*/.textFields["address"]/*[[".scrollViews.textFields[\"address\"]",".textFields[\"address\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let pKey = app2/*@START_MENU_TOKEN@*/.keys["p"]/*[[".keyboards.keys[\"p\"]",".keys[\"p\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        pKey.tap()
        pKey.tap()
        app2/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app2/*@START_MENU_TOKEN@*/.staticTexts["   To-Do List"].swipeRight()/*[[".scrollViews.staticTexts[\"   To-Do List\"]",".swipeUp()",".swipeRight()",".staticTexts[\"   To-Do List\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        scrollViewsQuery.otherElements.buttons["Done"].tap()
        
    }
    
    func testEditButton() {
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Add Hotspot"].tap()
        app.scrollViews.children(matching: .textField).element(boundBy: 0).tap()
        
        let aKey = app/*@START_MENU_TOKEN@*/.keys["a"]/*[[".keyboards.keys[\"a\"]",".keys[\"a\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        aKey.tap()
        
        let returnButton = app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        returnButton.tap()
        
        let app2 = XCUIApplication()
        app2/*@START_MENU_TOKEN@*/.textFields["address"]/*[[".scrollViews.textFields[\"address\"]",".textFields[\"address\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let bKey = app2/*@START_MENU_TOKEN@*/.keys["b"]/*[[".keyboards.keys[\"b\"]",".keys[\"b\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        bKey.tap()
        returnButton.tap()
        app/*@START_MENU_TOKEN@*/.scrollViews.containing(.staticText, identifier:"   About This Memory").element/*[[".scrollViews.containing(.button, identifier:\"Add Image\").element",".scrollViews.containing(.staticText, identifier:\"   Add Photos\").element",".scrollViews.containing(.staticText, identifier:\"   To-Do List\").element",".scrollViews.containing(.staticText, identifier:\"   Description\").element",".scrollViews.containing(.staticText, identifier:\"Transportation:\").element",".scrollViews.containing(.staticText, identifier:\"Category:\").element",".scrollViews.containing(.textField, identifier:\"address\").element",".scrollViews.containing(.staticText, identifier:\"Address:\").element",".scrollViews.containing(.staticText, identifier:\"Name:\").element",".scrollViews.containing(.staticText, identifier:\"   About This Memory\").element"],[[[-1,9],[-1,8],[-1,7],[-1,6],[-1,5],[-1,4],[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        XCUIApplication().scrollViews.otherElements.buttons["Done"].tap()
        app.buttons["Edit Hotspot"].tap()
        app.buttons["Edit Hotspot"].tap()
    }
    
    func testToDoList() {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Add Hotspot"].tap()
        
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.children(matching: .textField).element(boundBy: 0).tap()
        
        let aKey = app/*@START_MENU_TOKEN@*/.keys["a"]/*[[".keyboards.keys[\"a\"]",".keys[\"a\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        aKey.tap()
        aKey.tap()
        
        let app2 = XCUIApplication()
        app2/*@START_MENU_TOKEN@*/.textFields["address"]/*[[".scrollViews.textFields[\"address\"]",".textFields[\"address\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let bKey = app2/*@START_MENU_TOKEN@*/.keys["b"]/*[[".keyboards.keys[\"b\"]",".keys[\"b\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        bKey.tap()
        bKey.tap()
        
        let returnButton = app2/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        returnButton.tap()
        
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.textFields["Enter an item and click on '+' to add to your list"].tap()
        
        let tKey = app2/*@START_MENU_TOKEN@*/.keys["t"]/*[[".keyboards.keys[\"t\"]",".keys[\"t\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        tKey.tap()
        tKey.tap()
        returnButton.tap()
        elementsQuery.buttons["Button"].tap()
        app2/*@START_MENU_TOKEN@*/.staticTexts["   To-Do List"]/*[[".scrollViews.staticTexts[\"   To-Do List\"]",".staticTexts[\"   To-Do List\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        elementsQuery.buttons["Done"].tap()


    }
    
    
    func testAddHotspotWithPhotos() {
        

    
    }
    
    func testHotspotOverview() {
        
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"trees").images["defaultPhoto"].tap()
        
        let app2 = XCUIApplication()
        app2/*@START_MENU_TOKEN@*/.collectionViews.children(matching: .other).element.swipeRight()/*[[".scrollViews.collectionViews.children(matching: .other).element",".swipeUp()",".swipeRight()",".collectionViews.children(matching: .other).element"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        app2/*@START_MENU_TOKEN@*/.staticTexts["     Photos"]/*[[".scrollViews.staticTexts[\"     Photos\"]",".staticTexts[\"     Photos\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
        app.navigationBars["trees"].buttons["Memories"].tap()
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
