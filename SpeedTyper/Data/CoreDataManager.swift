//
//  CoreDataManager.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 6/26/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class CoreDataManager {
    //Creates Singleton to make class a Shared Resource
    static let shared = CoreDataManager()
    
    //Shared App Delegate and Context
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context: NSManagedObjectContext!
    
    init() {
        context = appDelegate.persistentContainer.viewContext
    }
    
    //Obtains the records for selected entity
    private func getRecordsForEntity(_ entityName: String) -> [NSManagedObject]? {
        //Fetches the Request
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        
        var outObjects: [NSManagedObject]? = nil
        
        //Gets the results
        do {
            let results = try context.fetch(request)
            outObjects = results as? [NSManagedObject] ?? nil
        } catch {
            outObjects = nil
            print("Error in fetching " + "\(entityName)" + " request from Core Data!")
        }
        
        return outObjects
    }
    
    //Sets a new fastest time passage
    public func SetFastestTimePassage(Time time: Double, Title title: String, Author author: String, TextID id: String) {
        //Holds the object
        var entityObject: NSManagedObject
        
        if let record = getRecordsForEntity("FastestTimePassage")?.first {
            //Obtains the existing object record
            entityObject = record
        } else {
            //Creates new entity
            let newEntity = NSEntityDescription.insertNewObject(forEntityName: "FastestTimePassage", into: context)
            entityObject = newEntity
        }
        
        //Attempts to edit context
        do {
            //Sets values for the entity
            entityObject.setValue(time, forKey: "time")
            entityObject.setValue(title, forKey: "title")
            entityObject.setValue(author, forKey: "author")
            entityObject.setValue(id, forKey: "textid")
            try context.save()
        } catch {
            print("Error in saving new FastestTimePassage in Core Data!")
        }
    }
    
    //Returns the data from Core Data
    public func GetFastestTimeData() -> [String: Any]? {
        //Return var
        var outData: [String: Any] = [:]
        
        if let record = getRecordsForEntity("FastestTimePassage")?.first {
            outData["title"] = record.value(forKey: "title") as? String ?? ""
            outData["author"] = record.value(forKey: "author") as? String ?? ""
            outData["textid"] = record.value(forKey: "textid") as? String ?? ""
            outData["time"] = record.value(forKey: "time") as? Double ?? Double(0)
            return outData
        } else {
            print("Error in fetching FastestTimePassage request!")
            return nil
        }
    }
    
    //Returns the data from Core Data
    public func GetFastestTime() -> Double? {
        //Return var
        var outTime: Double? = nil
        
        if let record = getRecordsForEntity("FastestTimePassage")?.first {
            outTime = record.value(forKey: "time") as? Double ?? Double(0)
            return outTime
        } else {
            print("Error in fetching FastestTimePassage request!")
            return nil
        }
    }
    
    
    //Sets a new fastest time per word passage
    public func SetFastestTimePerWordPassage(TimePerWord timeperword: Double, Title title: String, Author author: String, TextID id: String) {
        //Holds the object
        var entityObject: NSManagedObject
        
        if let record = getRecordsForEntity("FastestTimePerWordPassage")?.first {
            //Obtains the existing object record
            entityObject = record
        } else {
            //Creates new entity
            let newEntity = NSEntityDescription.insertNewObject(forEntityName: "FastestTimePerWordPassage", into: context)
            entityObject = newEntity
        }
        
        //Attempts to edit context
        do {
            //Sets values for the entity
            entityObject.setValue(timeperword, forKey: "timeperword")
            entityObject.setValue(title, forKey: "title")
            entityObject.setValue(author, forKey: "author")
            entityObject.setValue(id, forKey: "textid")
            try context.save()
        } catch {
            print("Error in saving new FastestTimePerWordPassage in Core Data!")
        }
    }
    
    //Returns the data from Core Data
    public func GetFastestTimePerWordData() -> [String: Any]? {
        //Return var
        var outData: [String: Any] = [:]
        
        if let record = getRecordsForEntity("FastestTimePerWordPassage")?.first {
            outData["title"] = record.value(forKey: "title") as? String ?? ""
            outData["author"] = record.value(forKey: "author") as? String ?? ""
            outData["textid"] = record.value(forKey: "textid") as? String ?? ""
            outData["timeperword"] = record.value(forKey: "timeperword") as? Double ?? Double(0)
            return outData
        } else {
            print("Error in fetching FastestTimePerWordPassage request!")
            return nil
        }
    }
    
    //Returns the data from Core Data
    public func GetFastestTimePerWord() -> Double? {
        //Return var
        var outTime: Double? = nil
        
        if let record = getRecordsForEntity("FastestTimePerWordPassage")?.first {
            outTime = record.value(forKey: "timeperword") as? Double ?? Double(0)
            return outTime
        } else {
            print("Error in fetching FastestTimePerWordPassage request!")
            return nil
        }
    }
    
    //Sets a new fastest time per word passage
    public func SetHighestAverageWPM(AvgWPM avgwpm: Int64, Title title: String, Author author: String, TextID id: String) {
        //Holds the object
        var entityObject: NSManagedObject
        
        if let record = getRecordsForEntity("HighestAvgWPMPassage")?.first {
            //Obtains the existing object record
            entityObject = record
        } else {
            //Creates new entity
            let newEntity = NSEntityDescription.insertNewObject(forEntityName: "HighestAvgWPMPassage", into: context)
            entityObject = newEntity
        }
        
        //Attempts to save the context
        do {
            entityObject.setValue(avgwpm, forKey: "averagewpm")
            entityObject.setValue(title, forKey: "title")
            entityObject.setValue(author, forKey: "author")
            entityObject.setValue(id, forKey: "textid")
            try context.save()
        } catch {
            print("Error in saving new HighestAvgWPMPassage in Core Data!")
        }
    }
    
    //Returns the data from Core Data
    public func GetHighestAverageWPMData() -> [String: Any]? {
        //Return var
        var outData: [String: Any] = [:]
        
        if let record = getRecordsForEntity("HighestAvgWPMPassage")?.first {
            outData["title"] = record.value(forKey: "title") as? String ?? ""
            outData["author"] = record.value(forKey: "author") as? String ?? ""
            outData["textid"] = record.value(forKey: "textid") as? String ?? ""
            outData["averagewpm"] = record.value(forKey: "averagewpm") as? Int64 ?? Int64(0)
            return outData
        } else {
            print("Error in fetching HighestAvgWPMPassage request!")
            return nil
        }
    }
    
    //Returns the data from Core Data
    public func GetHighestAverageWPM() -> Int64? {
        //Return var
        var outWPM: Int64? = nil
        
        if let record = getRecordsForEntity("HighestAvgWPMPassage")?.first {
            outWPM = record.value(forKey: "averagewpm") as? Int64 ?? Int64(0)
            return outWPM
        } else {
            print("Error in fetching HighestAvgWPMPassage request!")
            return nil
        }
    }
    
    //Sets a new fastest time per word passage
    public func SetMostAccurate(Accuracy accuracy: Double, Title title: String, Author author: String, TextID id: String) {
        //Holds the object
        var entityObject: NSManagedObject
        
        if let record = getRecordsForEntity("MostAccuratePassage")?.first {
            //Obtains the existing object record
            entityObject = record
        } else {
            //Creates new entity
            let newEntity = NSEntityDescription.insertNewObject(forEntityName: "MostAccuratePassage", into: context)
            entityObject = newEntity
        }
        
        //Attempts to save the context
        do {
            entityObject.setValue(accuracy, forKey: "accuracy")
            entityObject.setValue(title, forKey: "title")
            entityObject.setValue(author, forKey: "author")
            entityObject.setValue(id, forKey: "textid")
            try context.save()
        } catch {
            print("Error in saving new MostAccuratePassage in Core Data!")
        }
    }
    
    //Returns the data from Core Data
    public func GetMostAccurateData() -> [String: Any]? {
        //Return var
        var outData: [String: Any] = [:]
        
        if let record = getRecordsForEntity("MostAccuratePassage")?.first {
            outData["title"] = record.value(forKey: "title") as? String ?? ""
            outData["author"] = record.value(forKey: "author") as? String ?? ""
            outData["textid"] = record.value(forKey: "textid") as? String ?? ""
            outData["accuracy"] = record.value(forKey: "accuracy") as? Double ?? Double(0)
            return outData
        } else {
            print("Error in fetching MostAccuratePassage request!")
            return nil
        }
    }
    
    //Returns the data from Core Data
    public func GetMostAccurate() -> Double? {
        //Return var
        var outAccuracy: Double? = nil
        
        if let record = getRecordsForEntity("MostAccuratePassage")?.first {
            outAccuracy = record.value(forKey: "accuracy") as? Double ?? Double(0)
            return outAccuracy
        } else {
            print("Error in fetching MostAccuratePassage request!")
            return nil
        }
    }
    
    //Increases the number of times played for the select TextID
    public func IncreaseNumPlayed(ForTextID id: String?) {
        if (id != nil) {
            if let numPlayed = GetNumPlayedWith(TextID: id!) {
                SetNumPlayedWith(TextID: id!, NewNumPlayed: numPlayed + 1)
            }
            else {
                SetNumPlayedWith(TextID: id!, NewNumPlayed: 1)
            }
        }
    }
    
    //Gets the num of most played with corresponding TextID, returns nil if else
    public func GetNumPlayedWith(TextID id: String?) -> Int64? {
        //Return var
        var outNumPlayed: Int64? = nil
        
        if (id != nil) {
            if let records = getRecordsForEntity("NumTimesPlayed") {
                for record in records {
                    let idKey = record.value(forKey: "textid") as? String
                    if (idKey == id) {
                        outNumPlayed = record.value(forKey: "numtimesplayed") as? Int64 ?? Int64(0)
                        return outNumPlayed
                    }
                }
            } else {
                print("Error in fetching NumTimesPlayed request!")
            }
        }
        return nil
    }
    
    //Sets the number of times played for passage with corresponding TextID
    private func SetNumPlayedWith(TextID id: String, NewNumPlayed numPlayed: Int64) {
        //Holds the object
        var entityObject: NSManagedObject? = nil
        
        //Tests each result to check if they have the corresponding textID
        do {
            if let records = getRecordsForEntity("NumTimesPlayed") {
                for record in records {
                    let idKey = record.value(forKey: "textid") as? String
                    if (idKey == id) {
                        entityObject = record
                        entityObject?.setValue(numPlayed, forKey: "numtimesplayed")
                    }
                }
            }
            if (entityObject == nil) {
                //Creates new entity
                let newEntity = NSEntityDescription.insertNewObject(forEntityName: "NumTimesPlayed", into: context)
                entityObject = newEntity
                //Sets values for the new entity
                entityObject?.setValue(numPlayed, forKey: "numtimesplayed")
                entityObject?.setValue(id, forKey: "textid")
            }
            try context.save()
        } catch {
            print("Error in fetching and saving new value for NumTimesPlayed result request from Core Data!")
        }
    }
    
    //Sets the new most times played passage
    public func SetMostPlayed(NumTimesPlayed numTimesPlayed: Int64, Title title: String, Author author: String, TextID id: String) {
        //Holds the object
        var entityObject: NSManagedObject
        
        if let record = getRecordsForEntity("MostPlayedPassage")?.first {
            //Obtains the existing object record
            entityObject = record
        } else {
            //Creates new entity
            let newEntity = NSEntityDescription.insertNewObject(forEntityName: "MostPlayedPassage", into: context)
            entityObject = newEntity
        }
        
        //Attempts to save the context
        do {
            entityObject.setValue(numTimesPlayed, forKey: "numtimesplayed")
            entityObject.setValue(title, forKey: "title")
            entityObject.setValue(author, forKey: "author")
            entityObject.setValue(id, forKey: "textid")
            try context.save()
        } catch {
            print("Error in saving new MostPlayedPassage in Core Data!")
        }
    }
    
    //Returns the data from Core Data
    public func GetMostPlayedData() -> [String: Any]? {
        //Return var
        var outData: [String: Any] = [:]
        
        if let record = getRecordsForEntity("MostPlayedPassage")?.first {
            outData["title"] = record.value(forKey: "title") as? String ?? ""
            outData["author"] = record.value(forKey: "author") as? String ?? ""
            outData["textid"] = record.value(forKey: "textid") as? String ?? ""
            outData["numtimesplayed"] = record.value(forKey: "numtimesplayed") as? Int64 ?? Int64(0)
            return outData
        } else {
            print("Error in fetching MostPlayedPassage request!")
            return nil
        }
    }
    
    //Returns the data from Core Data
    public func GetMostPlayed() -> Int64? {
        //Return var
        var outNumber: Int64? = nil
        
        if let record = getRecordsForEntity("MostPlayedPassage")?.first {
            outNumber = record.value(forKey: "numtimesplayed") as? Int64 ?? Int64(0)
            return outNumber
        } else {
            print("Error in fetching MostPlayedPassage request!")
            return nil
        }
    }
    
    //Adds to the total games played
    public func AddToTotalGamesPlayed() {
        //Holds the object
        var entityObject: NSManagedObject
        
        var count: Int64 = 0
        if let record = getRecordsForEntity("TotalGamesPlayed")?.first {
            //Obtains the existing object record
            entityObject = record
            count = record.value(forKey: "count") as? Int64 ?? 0
        } else {
            //Creates new entity
            let newEntity = NSEntityDescription.insertNewObject(forEntityName: "TotalGamesPlayed", into: context)
            entityObject = newEntity
        }
        
        //Attempts to save the context
        do {
            if (count == 0) {
                entityObject.setValue(1, forKey: "count")
            } else {
                entityObject.setValue(count + 1, forKey: "count")
            }
            
            try context.save()
        } catch {
            print("Error in saving new TotalGamesPlayed in Core Data!")
        }
    }
    
    //Returns the data from Core Data
    public func GetTotalGamesPlayed() -> Int64? {
        //Return var
        var outNumber: Int64? = nil
        
        if let record = getRecordsForEntity("TotalGamesPlayed")?.first {
            outNumber = record.value(forKey: "count") as? Int64 ?? 0
            return outNumber
        } else {
            print("Error in fetching TotalGamesPlayed request!")
            return nil
        }
    }
    
    //Adds to the overall average WPM
    public func AddOverallAverageWPM(WPM wpm: Int64) {
        //Holds the object
        var entityObject: NSManagedObject
        
        var count: Int64 = 0
        var overallAvgWPM: Int64 = 0
        if let record = getRecordsForEntity("OverallAverageWPM")?.first {
            //Obtains the existing object record
            entityObject = record
            count = record.value(forKey: "count") as? Int64 ?? 0
            overallAvgWPM = record.value(forKey: "wpm") as? Int64 ?? 0
        } else {
            //Creates new entity
            let newEntity = NSEntityDescription.insertNewObject(forEntityName: "OverallAverageWPM", into: context)
            entityObject = newEntity
        }
        
        //Attempts to save the context
        do {
            if (count == 0) {
                entityObject.setValue(wpm, forKey: "wpm")
                entityObject.setValue(1, forKey: "count")
            }
            else {
                let newWPM = ((count * overallAvgWPM) + wpm) / (count + 1)
                entityObject.setValue(newWPM, forKey: "wpm")
                entityObject.setValue(count + 1, forKey: "count")
            }
            
            try context.save()
        } catch {
            print("Error in saving new OverallAverageWPM in Core Data!")
        }
    }
    
    //Returns the data from Core Data
    public func GetOverallAverageWPM() -> Int64? {
        //Return var
        var outNumber: Int64? = nil
        
        if let record = getRecordsForEntity("OverallAverageWPM")?.first {
            outNumber = record.value(forKey: "wpm") as? Int64 ?? Int64(0)
            return outNumber
        } else {
            print("Error in fetching OverallAverageWPM request!")
            return nil
        }
    }
    
    //Adds to the last 5 games WPM
    public func AddLast5GamesWPM(WPM wpm: Int64) {
        //Holds the object
        var entityObject: NSManagedObject
        
        var count: Int64 = 0
        var wpm1: Int64 = 0
        var wpm2: Int64 = 0
        var wpm3: Int64 = 0
        var wpm4: Int64 = 0
        var wpm5: Int64 = 0
        if let record = getRecordsForEntity("Last5GamesWPM")?.first {
            //Obtains the existing object record
            entityObject = record
            wpm1 = record.value(forKey: "wpm1") as? Int64 ?? 0
            wpm2 = record.value(forKey: "wpm2") as? Int64 ?? 0
            wpm3 = record.value(forKey: "wpm3") as? Int64 ?? 0
            wpm4 = record.value(forKey: "wpm4") as? Int64 ?? 0
            wpm5 = record.value(forKey: "wpm5") as? Int64 ?? 0
            count = record.value(forKey: "count") as? Int64 ?? 0
        } else {
            //Creates new entity
            let newEntity = NSEntityDescription.insertNewObject(forEntityName: "Last5GamesWPM", into: context)
            entityObject = newEntity
        }
        
        //Attempts to save the context
        do {
            if (count == 0) {
                entityObject.setValue(wpm, forKey: "wpm1")
                entityObject.setValue(-1, forKey: "wpm2")
                entityObject.setValue(-1, forKey: "wpm3")
                entityObject.setValue(-1, forKey: "wpm4")
                entityObject.setValue(-1, forKey: "wpm5")
                entityObject.setValue(1, forKey: "count")
            } else {
                wpm5 = wpm4
                wpm4 = wpm3
                wpm3 = wpm2
                wpm2 = wpm1
                wpm1 = wpm
                entityObject.setValue(wpm1, forKey: "wpm1")
                entityObject.setValue(wpm2, forKey: "wpm2")
                entityObject.setValue(wpm3, forKey: "wpm3")
                entityObject.setValue(wpm4, forKey: "wpm4")
                entityObject.setValue(wpm5, forKey: "wpm5")
                entityObject.setValue(count + 1, forKey: "count")
            }
            
            try context.save()
        } catch {
            print("Error in saving new OverallAverageWPM in Core Data!")
        }
    }
    
    //Returns the data from Core Data
    public func GetLast5GamesWPM() -> Int64? {
        //Return var
        var outNumber: Int64? = nil
        
        if let record = getRecordsForEntity("Last5GamesWPM")?.first {
            var divisor: Int64 = 5
            var wpm1 = record.value(forKey: "wpm1") as? Int64 ?? 0
            if (wpm1 <= 1) {
                divisor -= 1
                wpm1 = 0
            }
            var wpm2 = record.value(forKey: "wpm2") as? Int64 ?? 0
            if (wpm2 <= 1) {
                divisor -= 1
                wpm2 = 0
            }
            var wpm3 = record.value(forKey: "wpm3") as? Int64 ?? 0
            if (wpm3 <= 1) {
                divisor -= 1
                wpm3 = 0
            }
            var wpm4 = record.value(forKey: "wpm4") as? Int64 ?? 0
            if (wpm4 <= 1) {
                divisor -= 1
                wpm4 = 0
            }
            var wpm5 = record.value(forKey: "wpm5") as? Int64 ?? 0
            if (wpm5 <= 1) {
                divisor -= 1
                wpm5 = 0
            }
            divisor = (divisor == 0) ? 1 : divisor
            let totalWPM = wpm1 + wpm2 + wpm3 + wpm4 + wpm5
            outNumber = totalWPM / divisor
            return outNumber
        } else {
            print("Error in fetching Last5GamesWPM request!")
            return nil
        }
    }
    
    //Saves individual high scores for each passage using its unique TextID
    public func SetIndividualHighScores(ForTextID textID: String?, FastestTime fastestTime: Double?, FastestTimePerWord fastestTimePerWord: Double?, HighestAvgWPM highestAvgWPM: Int64?, BestAccuracy bestAccuracy: Double?) {
        if (textID != nil) {
            //Holds the object
            var entityObject: NSManagedObject? = nil
            
            if let records = getRecordsForEntity("IndividualHighScores") {
                //Obtains the existing object record
                RecordLoop: for record in records {
                    let idKey = record.value(forKey: "textid") as? String
                    if (idKey == textID) {
                        entityObject = record
                        if let ftime = fastestTime {
                            entityObject!.setValue(ftime, forKey: "fastesttime")
                        }
                        if let ftimeperword = fastestTimePerWord {
                            entityObject!.setValue(ftimeperword, forKey: "fastesttimeperword")
                        }
                        if let avgwpm = highestAvgWPM {
                            entityObject!.setValue(avgwpm, forKey: "highestaveragewpm")
                        }
                        if let accuracy = bestAccuracy {
                            entityObject!.setValue(accuracy, forKey: "mostaccurate")
                        }
                        break RecordLoop
                    }
                }
            }
            
            if (entityObject == nil) {
                //Creates new entity
                let newEntity = NSEntityDescription.insertNewObject(forEntityName: "IndividualHighScores", into: context)
                entityObject = newEntity
                //Sets values for the new entity
                entityObject!.setValue(textID!, forKey: "textid")
                entityObject!.setValue(fastestTime ?? 0, forKey: "fastesttime")
                entityObject!.setValue(fastestTimePerWord ?? 0, forKey: "fastesttimeperword")
                entityObject!.setValue(highestAvgWPM ?? 0, forKey: "highestaveragewpm")
                entityObject!.setValue(bestAccuracy ?? 0, forKey: "mostaccurate")
            }
        }
    }
    
    //Returns the data from Core Data
    public func GetIndividualHighScores(ForTextID textID: String?) -> [String: Any]? {
        if (textID != nil) {
            //Return var
            var outData: [String: Any] = [:]
            
            if let records = getRecordsForEntity("IndividualHighScores") {
                RecordLoop: for record in records {
                    let idKey = record.value(forKey: "textid") as? String
                    if (idKey == textID) {
                        outData["fastesttime"] = record.value(forKey: "fastesttime") as? Double ?? Double(0)
                        outData["fastesttimeperword"] = record.value(forKey: "fastesttimeperword") as? Double ?? Double(0)
                        outData["highestaveragewpm"] = record.value(forKey: "highestaveragewpm") as? Int64 ?? Int64(0)
                        outData["mostaccurate"] = record.value(forKey: "mostaccurate") as? Double ?? Double(0)
                        break RecordLoop
                    }
                }
                return outData
            } else {
                print("Error in fetching IndividualHighScores request!")
            }
        }
        return nil
    }
    
    //Removes the specified Core Data entity from the device
    public func ClearEntity(EntityName entityName: String) {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            
        } catch {
            print("Had a problem with Batch Deleting the delete request for \(entityName) entity!")
        }
    }
    
}
