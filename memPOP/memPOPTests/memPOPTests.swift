//
//  memPOPTests.swift
//  memPOPTests
//
//  Created by nla52 on 10/23/18.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
import CoreData
import XCTest
@testable import memPOP

let fetchRequest: NSFetchRequest<HotspotMO> = HotspotMO.fetchRequest()

class memPOPTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        
        for i in 0 ... 9 {
            print(i)
            let newHotspot = HotspotMO(context: PersistenceService.context)
            let newPhoto = PhotosMO(context: PersistenceService.context)
            
            newPhoto.photo = UIImageJPEGRepresentation((UIImage(named: "home"))!, 1)! as NSData
            
            newHotspot.name = "Home" + String(i)
            newHotspot.address = "address" + String(i)
            newHotspot.longitude = -122.915097
            newHotspot.latitude = 49.277575
            newHotspot.addToPhotos(newPhoto)
            
            PersistenceService.saveContext()
        }
 
        do{
            
            let hotspots = try PersistenceService.context.fetch(fetchRequest)
            print(hotspots.count)
            XCTAssert(hotspots.count == 10)
            // Put setup code here. This method is called before the invocation of each test method in the class.
        }
        catch {
            print("failed")
        }
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
