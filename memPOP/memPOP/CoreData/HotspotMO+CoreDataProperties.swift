//  HotspotMO+CoreDataProperties.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Diego Martin on 2018-11-16.
//  Programmers:
//  Copyright © 2018 Iota Inc. All rights reserved.

//===============================================================
// Defines characterstics and attributes of HotpotMO entity
// with its relationships with the PhotosMO and ToDOMO
// This was generated from the xcdatamodeld
//===============================================================

import Foundation
import CoreData


extension HotspotMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HotspotMO> {
        return NSFetchRequest<HotspotMO>(entityName: "HotspotMO")
    }

    @NSManaged public var address: String?
    @NSManaged public var category: String?
    @NSManaged public var info: String?
    @NSManaged public var name: String?
    @NSManaged public var todoList: String?
    @NSManaged public var transportation: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timesVisit: Int32
    @NSManaged public var photos: NSArray?
    @NSManaged public var toDo: NSArray?

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
