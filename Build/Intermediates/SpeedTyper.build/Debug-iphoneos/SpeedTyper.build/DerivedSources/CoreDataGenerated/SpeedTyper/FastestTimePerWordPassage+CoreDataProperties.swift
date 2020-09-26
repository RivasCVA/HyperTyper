//
//  FastestTimePerWordPassage+CoreDataProperties.swift
//  
//
//  Created by Carlos Rivas on 9/28/19.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension FastestTimePerWordPassage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FastestTimePerWordPassage> {
        return NSFetchRequest<FastestTimePerWordPassage>(entityName: "FastestTimePerWordPassage")
    }

    @NSManaged public var author: String?
    @NSManaged public var textid: String?
    @NSManaged public var timeperword: Double
    @NSManaged public var title: String?

}
