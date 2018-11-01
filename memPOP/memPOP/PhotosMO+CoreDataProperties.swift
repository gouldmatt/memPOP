//
//  PhotosMO+CoreDataProperties.swift
//  memPOP
//
//  Created by Matthew Gould   on 2018-11-01.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotosMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotosMO> {
        return NSFetchRequest<PhotosMO>(entityName: "PhotosMO")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var hotspot: HotspotMO?

}
