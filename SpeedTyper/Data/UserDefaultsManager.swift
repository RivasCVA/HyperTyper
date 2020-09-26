//
//  UserDefaultsManager.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 8/15/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import Foundation

struct UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    func getTextTypeIndex() -> Int {
        let newIndex: Int
        //Gets the Type
        if let udType = UserDefaults.standard.value(forKey: "TextType") as? Int {
            newIndex = udType
        } else {
            newIndex = TextType.random.rawValue
            UserDefaults.standard.setValue(newIndex, forKey: "TextType")
        }
        return newIndex
    }
    
    func getTextLengthIndex() -> Int {
        let newIndex: Int
        //Gets the Length
        if let udType = UserDefaults.standard.value(forKey: "TextLength") as? Int {
            newIndex = udType
        } else {
            newIndex = TextLength.random.rawValue
            UserDefaults.standard.setValue(newIndex, forKey: "TextLength")
        }
        return newIndex
    }
    
    func getEmojifyEnabled() -> Bool {
        let isEnabled: Bool
        //Gets the Emojify boolean
        if let udEmojifyEnabled = UserDefaults.standard.value(forKey: "EmojifyEnabled") as? Bool {
            isEnabled = udEmojifyEnabled
        } else {
            isEnabled = false
            UserDefaults.standard.setValue(isEnabled, forKey: "EmojifyEnabled")
        }
        return isEnabled
    }
}
