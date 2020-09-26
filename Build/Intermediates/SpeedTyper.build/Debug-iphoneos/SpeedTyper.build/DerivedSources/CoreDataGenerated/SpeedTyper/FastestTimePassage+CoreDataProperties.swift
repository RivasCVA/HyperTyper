//
//  FastestTimePassage+CoreDataProperties.swift
//  
//
//  Created by Carlos Rivas on 9/28/19.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension FastestTimePassage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FastestTimePassage> {
        return NSFetchRequest<FastestTimePassage>(entityName: "FastestTimePassage")
    }

    @NSManaged public var author: String?
    @NSManaged public var textid: String?
    @NSManaged public var time: Double
    @NSManaged public var title: String?

}
