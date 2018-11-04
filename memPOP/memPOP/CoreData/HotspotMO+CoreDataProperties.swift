//
//  HotspotMO+CoreDataProperties.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Matthew Gould   on 2018-11-02.
//  Copyright © 2018 Iota Inc. All rights reserved.

//===============================================================
// Defines characterstics of hotspot managed object entity
// with its relationships with the photos and to-do list
// This was generated from the xcdatamodeld
// Relationship is one hotspot to many photos/to do lists
//===============================================================

import Foundation
import CoreData


extension HotspotMO {

    // Call to create fetch request
    @nonobjc public class func fetchRequest() -> NSFetchRequest<HotspotMO> {
        return NSFetchRequest<HotspotMO>(entityName: "HotspotMO")
    }

    // MARK: Description variables
    @NSManaged public var address: String?
    @NSManaged public var category: String?
    @NSManaged public var info: String?
    @NSManaged public var name: String?
    @NSManaged public var todoList: String?
    @NSManaged public var transportation: String?
    @NSManaged public var photos: NSSet?
    @NSManaged public var toDo: NSSet?
}

// MARK: Generated accessors for photos
extension HotspotMO {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: PhotosMO)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: PhotosMO)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)
}

// MARK: Generated accessors for toDo
extension HotspotMO {

    @objc(addToDoObject:)
    @NSManaged public func addToToDo(_ value: ToDoMO)

    @objc(removeToDoObject:)
    @NSManaged public func removeFromToDo(_ value: ToDoMO)

    @objc(addToDo:)
    @NSManaged public func addToToDo(_ values: NSSet)

    @objc(removeToDo:)
    @NSManaged public func removeFromToDo(_ values: NSSet)
}
