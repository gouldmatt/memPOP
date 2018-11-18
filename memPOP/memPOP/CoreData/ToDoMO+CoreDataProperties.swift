//  ToDoMO+CoreDataProperties.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Matthew Gould on 2018-11-01.
//  Programmers:
//  Copyright © 2018 Iota Inc. All rights reserved.

//===============================================================
// Defines characterstics of HotpotMO entity
// with its relationships with the ToDoMO
// This was generated from the xcdatamodeld
// Relationship is many ToDoMO to one HotspotMO
//===============================================================

import Foundation
import CoreData

extension ToDoMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoMO> {
        return NSFetchRequest<ToDoMO>(entityName: "ToDoMO")
    }

    @NSManaged public var toDoItem: String?
    @NSManaged public var hotspot: HotspotMO?
}
