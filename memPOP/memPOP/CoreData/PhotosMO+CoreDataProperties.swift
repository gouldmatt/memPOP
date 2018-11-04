//
//  PhotosMO+CoreDataProperties.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Matthew Gould   on 2018-11-01.
//  Copyright © 2018 Iota Inc. All rights reserved.

//===============================================================
// Defines characterstics of hotspot managed object entity
// with its relationships with the photos and to-do list
// This was generated from the xcdatamodeld
// Relationship is many photos to one hotspot
//===============================================================

import Foundation
import CoreData


extension PhotosMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotosMO> {
        return NSFetchRequest<PhotosMO>(entityName: "PhotosMO")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var hotspot: HotspotMO?
}
