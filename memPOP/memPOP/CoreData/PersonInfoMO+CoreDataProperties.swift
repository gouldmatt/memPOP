//
//  PersonInfoMO+CoreDataProperties.swift
//  memPOP
//
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
    @NSManaged public var homeAddress: String?
    @NSManaged public var homeLat: Double
    @NSManaged public var homeLong: Double
    
}
