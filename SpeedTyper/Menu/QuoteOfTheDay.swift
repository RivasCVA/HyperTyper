//
//  QuoteOfTheDay.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 8/15/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import Foundation

struct QuoteOfTheDay {
    
    //Calls the API to get the Quote of the Day
    static public func getQuoteOfTheDay(completion: @escaping (String?, String?) -> ()) {
        //The API request URL
        let apiURL = URL(string: "https://favqs.com/api/qotd")
        //Holds the return vars
        var quote = ""
        var author = ""
        //Calls the API
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(3)
        config.timeoutIntervalForResource = TimeInterval(3)
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: apiURL!) { (data, response, error) in
            if (error != nil) {
                print("There was an error accessing the Quote of the Day API (favqs.com).")
                completion(nil, nil)
            } else {
                if let content = data {
                    do {
                        //Converts json to readable format
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        let apiData = myJson as! [String: Any]
                        let quoteData = apiData["quote"] as! [String: Any]
                        
                        //Gets the Quote from the API
                        quote = quoteData["body"] as? String ?? String("Error")
                        author = quoteData["author"] as? String ?? String("Error")
                        
                        //Returns Completion
                        completion((quote == "Error") ? nil : quote, (author == "Error") ? nil : author)
                    }
                    catch {
                        print("There was an error in parsing the Quote of the Day API data.")
                        completion(nil, nil)
                    }
                }
            }
        }
        task.resume()
    }
    
}
