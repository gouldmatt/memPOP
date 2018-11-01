//
//  HotspotMO+CoreDataProperties.swift
//  memPOP
//
//  Created by Matthew Gould   on 2018-11-01.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
//

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
    @NSManaged public var picture: NSData?
    @NSManaged public var todoList: String?
    @NSManaged public var transportation: String?
    @NSManaged public var photos: NSSet
    @NSManaged public var toDo: NSSet

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
