//  PhotosMO+CoreDataProperties.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Matthew Gould on 2018-11-01.
//  Programmers:
//  Copyright © 2018 Iota Inc. All rights reserved.

//===============================================================
// Defines characterstics of HotpotMO entity
// with its relationships with the PhotosMO
// This was generated from the xcdatamodeld
// Relationship is many PhotosMO to one HotspotMO
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
