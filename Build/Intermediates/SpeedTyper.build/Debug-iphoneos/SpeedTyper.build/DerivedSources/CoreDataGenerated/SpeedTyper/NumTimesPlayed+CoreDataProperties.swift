//
//  NumTimesPlayed+CoreDataProperties.swift
//  
//
//  Created by Carlos Rivas on 9/28/19.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension NumTimesPlayed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NumTimesPlayed> {
        return NSFetchRequest<NumTimesPlayed>(entityName: "NumTimesPlayed")
    }

    @NSManaged public var numtimesplayed: Int64
    @NSManaged public var textid: String?

}
