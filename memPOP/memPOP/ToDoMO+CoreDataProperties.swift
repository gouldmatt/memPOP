//
//  ToDoMO+CoreDataProperties.swift
//  memPOP
//
//  Created by Matthew Gould   on 2018-11-01.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension ToDoMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoMO> {
        return NSFetchRequest<ToDoMO>(entityName: "ToDoMO")
    }

    @NSManaged public var toDoItem: String?
    @NSManaged public var hotspot: HotspotMO?

}
