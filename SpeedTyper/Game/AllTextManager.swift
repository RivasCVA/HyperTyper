//
//  AllTextManager.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 9/16/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import Foundation

public struct AllTextManager {
    private static let AllTextJSONFilePath = Bundle.main.path(forResource: "AllTextData", ofType: "json")
    
    static public func GetSelectText(Type type: TextType, Length length: TextLength, Emojify emojify: Bool, TextID textID: String?) -> TextHolder? {
        //Gets and Initializes a String Array for Text Types and Text Lenths, Excludes the 'random' type
        var AllTextTypes: [String] = []
        var AllTextLengths: [String] = []
        for eachType in TextType.allCases {
            if (eachType.caseString != "random") {
                AllTextTypes.append(eachType.caseString)
            }
        }
        for eachLength in TextLength.allCases {
            if (eachLength.caseString != "random") {
                AllTextLengths.append(eachLength.caseString)
            }
        }
        
        //Type and Length identifying character
        var idTypeChar: Character? = textID?.first
        var idLengthChar: Character? = textID?.dropFirst().first
        //The return holder
        var outTextHolder: TextHolder!
        
        if let formattedResult = AllTextManager.GetTextJSONResult() as? [String: Any] {
            //Will emediatley return Emoji Story if selected
            if (emojify && textID == nil) {
                if let emojiTypeResult = formattedResult["emoji"] as? [String: Any] {
                    var selectedLength: String
                    if (length.caseString != "random") {
                        selectedLength = length.caseString
                    } else {
                        selectedLength = AllTextLengths.randomElement()!
                    }
                    if let textResults = emojiTypeResult[selectedLength] as? [[String: Any]] {
                        let dataResult = textResults.randomElement()!
                        let textArray: [String] = (dataResult["Text"] as? String ?? "error").map{ String($0) }
                        let finalText = textArray.joined(separator: " ")
                        return TextHolder(
                            Text: finalText,
                            Title: dataResult["Title"] as? String ?? "",
                            TitleStyle: "n",
                            Author: dataResult["Author"] as? String ?? "",
                            TextType: "quote",
                            Language: "en",
                            TextLength: selectedLength,
                            TextID: dataResult["ID"] as? String ?? ""
                        )
                    }
                }
            }
            
            //Will hold the wanted type
            var selectedType: String!
            
            //Gets the desired Type from TextID type identifying
            if let typeChar = idTypeChar {
                switch (typeChar) {
                case "B":
                    selectedType = AllTextTypes[TextType.book.rawValue]
                    break
                case "M":
                    selectedType = AllTextTypes[TextType.movie.rawValue]
                    break
                case "S":
                    selectedType = AllTextTypes[TextType.song.rawValue]
                    break
                case "Q":
                    selectedType = AllTextTypes[TextType.quote.rawValue]
                    break
                case "E":
                    if (emojify) {
                        selectedType = "emoji"
                    } else {
                        idTypeChar = nil
                    }
                    break
                default:
                    idTypeChar = nil
                    print("The Text with TextID: \(textID ?? "NO TEXT ID") has no identifying Type starting character!");
                    break
                }
            }
            if (idTypeChar == nil) {
                if (type.caseString != "random") {
                    selectedType = type.caseString
                } else {
                    selectedType = AllTextTypes.randomElement()!
                }
            }
            
            if let typeData = formattedResult[selectedType] as? [String : Any] {
                //Will hold the wanted Length
                var selectedLength: String!
                
                //Gets the desired Length from TextID length identifying
                if let lengthChar = idLengthChar {
                    switch (lengthChar) {
                    case "S":
                        selectedLength = AllTextLengths[TextLength.short.rawValue]
                        break
                    case "M":
                        selectedLength = AllTextLengths[TextLength.medium.rawValue]
                        break
                    case "L":
                        selectedLength = AllTextLengths[TextLength.long.rawValue]
                        break
                    default:
                        idLengthChar = nil
                        print("The Text with TextID: \(textID ?? "NO TEXT ID") has no identifying Length second character!");
                        break
                    }
                }
                if (idLengthChar == nil) {
                    if (length.caseString != "random") {
                        selectedLength = length.caseString
                    } else {
                        selectedLength = AllTextLengths.randomElement()!
                    }
                }
                
                if let lengthData = typeData[selectedLength] as? [[String: Any]] {
                    //Holds the data of the obtained text
                    var selectedData: [String: Any]? = nil
                    //Will search for Text with passed TextID
                    if (idTypeChar != nil && idLengthChar != nil) {
                        for data in lengthData {
                            let ID = data["ID"] as? String ?? ""
                            if (textID! == ID)  {
                                selectedData = data
                            }
                        }
                        //Did not find text, recurses (with TextID as nil)
                        if (selectedData == nil) {
                            return AllTextManager.GetSelectText(Type: type, Length: length, Emojify: emojify, TextID: nil)
                        }
                    }
                    //Did need to find TextID, so get Random
                    if (selectedData == nil) {
                        selectedData = lengthData.randomElement()
                    }
                    
                    //Will format the text if needed
                    var finalText: String
                    if (emojify) {
                        let textArray: [String] = (selectedData?["Text"] as? String ?? "error").map{ String($0) }
                        finalText = textArray.joined(separator: " ")
                    } else {
                        finalText = selectedData?["Text"] as? String ?? "error"
                    }
                    
                    //Initializes the out text holder
                    outTextHolder = TextHolder(
                        Text: finalText,
                        Title: selectedData?["Title"] as? String ?? "",
                        TitleStyle: AllTextManager.GetTitleStyleFrom(Type: selectedType).caseString,
                        Author: selectedData?["Author"] as? String ?? "",
                        TextType: selectedType,
                        Language: "en",
                        TextLength: selectedLength,
                        TextID: selectedData?["ID"] as? String ?? ""
                    )
                    return outTextHolder
                } else { print("Could not obtain Length Data from result!") }
            } else { print("Could not obtain Type Data from result!") }
        } else { print("Could not format JSON result!") }
        return nil
    }
    
    //Reads the JSON file
    static private func GetTextJSONResult() -> Any? {
        if let path = AllTextJSONFilePath {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                return jsonResult
            } catch {
                print("Could not obtain Text Data from JSON File!")
            }
        }
        return nil
    }
    
    static private func GetTitleStyleFrom(Type type: String) -> TitleStyle {
        switch (type) {
        case TextType.book.caseString:
            return TitleStyle.italicize
        case TextType.movie.caseString:
            return TitleStyle.italicize
        case TextType.song.caseString:
            return TitleStyle.quotation
        case TextType.quote.caseString:
            return TitleStyle.none
        default:
            return TitleStyle.none
        }
    }
    
}

//Struct Used To Hold Each Text Information
public struct TextHolder {
    public var Text: String = ""
    public var Title: String = ""
    public var TitleStyle: String = ""
    public var Author: String = ""
    public var TextType: String = ""
    public var Language: String = ""
    public var TextLength: String = ""
    public var TextID: String = ""
    
    init(Text text: String, Title title: String, TitleStyle titleStyle: String, Author author: String, TextType textType: String, Language language: String, TextLength textLength: String, TextID textid: String?) {
        self.Text = text
        self.Title = title
        self.TitleStyle = titleStyle.lowercased()
        self.Author = author
        self.TextType = textType.lowercased()
        self.Language = language.lowercased()
        self.TextLength = textLength.lowercased()
        self.TextID = textid ?? ""
    }
}

public enum TextType: Int, CaseIterable {
    case book = 0
    case movie = 1
    case song = 2
    case quote = 3
    case random = 4
    
    var caseString: String {
        switch (self) {
        case .book:
            return "book"
        case .movie:
            return "movie"
        case .song:
            return "song"
        case .quote:
            return "quote"
        case .random:
            return "random"
        }
    }
}

public enum TextLength: Int, CaseIterable {
    case short = 0
    case medium = 1
    case long = 2
    case random = 3
    
    var caseString: String {
        switch (self) {
        case .short:
            return "short"
        case .medium:
            return "medium"
        case .long:
            return "long"
        case .random:
            return "random"
        }
    }
}

public enum TitleStyle: Int, CaseIterable {
    case quotation = 0
    case italicize = 1
    case none = 3
    
    var caseString: String {
        switch (self) {
        case .quotation:
            return "q"
        case .italicize:
            return "i"
        case .none:
            return "n"
        }
    }
}
