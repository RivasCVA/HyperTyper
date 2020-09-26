//
//  MostAccuratePassage+CoreDataProperties.swift
//  
//
//  Created by Carlos Rivas on 9/28/19.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MostAccuratePassage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MostAccuratePassage> {
        return NSFetchRequest<MostAccuratePassage>(entityName: "MostAccuratePassage")
    }

    @NSManaged public var accuracy: Double
    @NSManaged public var author: String?
    @NSManaged public var textid: String?
    @NSManaged public var title: String?

}
