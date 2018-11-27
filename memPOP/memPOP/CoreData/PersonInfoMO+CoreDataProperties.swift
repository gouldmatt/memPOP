//
//  PersonInfoMO+CoreDataProperties.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Matthew Gould   on 2018-11-17.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension PersonInfoMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonInfoMO> {
        return NSFetchRequest<PersonInfoMO>(entityName: "PersonInfoMO")
    }

    @NSManaged public var name: String?
    @NSManaged public var totalDistance: Int32
    @NSManaged public var contactName: String?
    @NSManaged public var contactPhone: Int16
}
