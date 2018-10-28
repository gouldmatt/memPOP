//
//  HotspotMO+CoreDataProperties.swift
//  memPOP
//
//  Created by Diego Martin on 2018-10-27.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension HotspotMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HotspotMO> {
        return NSFetchRequest<HotspotMO>(entityName: "HotspotMO")
    }

    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var category: String?
    @NSManaged public var transportation: String?
    @NSManaged public var todoList: String?
    @NSManaged public var picture: NSData?
    @NSManaged public var info: String?

}
