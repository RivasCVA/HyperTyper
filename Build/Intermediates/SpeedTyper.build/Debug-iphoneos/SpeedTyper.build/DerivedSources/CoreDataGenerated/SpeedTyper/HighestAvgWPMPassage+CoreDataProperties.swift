//
//  HighestAvgWPMPassage+CoreDataProperties.swift
//  
//
//  Created by Carlos Rivas on 9/28/19.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension HighestAvgWPMPassage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HighestAvgWPMPassage> {
        return NSFetchRequest<HighestAvgWPMPassage>(entityName: "HighestAvgWPMPassage")
    }

    @NSManaged public var author: String?
    @NSManaged public var averagewpm: Int64
    @NSManaged public var textid: String?
    @NSManaged public var title: String?

}
