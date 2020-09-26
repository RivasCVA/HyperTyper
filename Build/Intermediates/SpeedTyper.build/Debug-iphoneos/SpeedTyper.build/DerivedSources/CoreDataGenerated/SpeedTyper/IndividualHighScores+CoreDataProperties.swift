//
//  IndividualHighScores+CoreDataProperties.swift
//  
//
//  Created by Carlos Rivas on 9/28/19.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension IndividualHighScores {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IndividualHighScores> {
        return NSFetchRequest<IndividualHighScores>(entityName: "IndividualHighScores")
    }

    @NSManaged public var fastesttime: Double
    @NSManaged public var fastesttimeperword: Double
    @NSManaged public var highestaveragewpm: Int64
    @NSManaged public var mostaccurate: Double
    @NSManaged public var textid: String?

}
