//
//  MostPlayedPassage+CoreDataProperties.swift
//  
//
//  Created by Carlos Rivas on 9/28/19.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MostPlayedPassage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MostPlayedPassage> {
        return NSFetchRequest<MostPlayedPassage>(entityName: "MostPlayedPassage")
    }

    @NSManaged public var author: String?
    @NSManaged public var numtimesplayed: Int64
    @NSManaged public var textid: String?
    @NSManaged public var title: String?

}
