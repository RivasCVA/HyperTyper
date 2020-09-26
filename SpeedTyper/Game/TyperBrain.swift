//
//  TyperBrain.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 8/19/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import Foundation
import UIKit

struct TyperBrain {
    
    //Locals Vars
    private var attributedMainTextString: NSMutableAttributedString! //Used to change the color of certain parts of the text
    private var MainTextComponents: [String]!
    private var completedMainTextString: String!
    
    private var currentWordIndex: Int = 0 //Holds the current index of the word the user must type
    private var completedWords: [String] = [] //Holds all of the words the user has correcly typed
    private var focusTextRange: NSRange? //Keeps track of the range of the text that should be a priority focus
        
    private var primaryTextColor: UIColor!
    
    private var hasProducedHaptic = false //Used to track whether haptic has been produced for an error
    
    
    //Tracks scores and stats
    private var percentCompleted: Int = 0
    private var WPM: Int = 0
    private var HighestWPM: Int = 0
    private var Accuracy: Double = 0
    
    //Used to Calculate scores and stats
    //Must be updated in the input process function(s)
    private var totalTimeTaken: TimeInterval = TimeInterval(0)
    private var typeStartTime: TimeInterval = TimeInterval(0)
    private var numWordsTyped: Int = 0
    private var MissedWordsArray: [Int] = []
    private var hasCompletedText = false
    private var totalWordCount: Int = 0 //Only updated at Init
    
    
    //Main Initializer
    init(AttributedMainText attText: NSAttributedString) {
        //Holds the text the user will type
        completedMainTextString = attText.string
        MainTextComponents = attText.string.components(separatedBy: " ")
        totalWordCount = MainTextComponents.count
        
        //Sets up the font and size of the attributed text
        attributedMainTextString = NSMutableAttributedString(attributedString: attText)
        
        //Sets up the focus range
        focusTextRange = (completedMainTextString as NSString).range(of: MainTextComponents[0])
        
        //Holds the main color of the Text
        primaryTextColor = attText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? UIColor.white
    }
    
    //Getter for the Main Attributed Text String
    public func GetAttributedMainTextString() -> NSMutableAttributedString {
        return attributedMainTextString
    }
    
    //Getter for whether user has completed typing the full text
    public func HasCompletedText() -> Bool {
        return hasCompletedText
    }
    
    //Getter for the total time taken to complete text (will be 0 until text is completed) {
    public func GetTotalTypeTimeTaken() -> Double {
        return totalTimeTaken
    }
    
    //Getter for the priority focus Text Range
    public func GetFocusTextRange() -> NSRange? {
        return focusTextRange
    }
    
    //Processes new input text in the Type Text View
    public mutating func ProcessInputText(InputText input: String?) -> String {
        //Keeps track of the return Input Text
        var inputText = input
        
        //Makes sure the input text is valid
        if (inputText != nil && currentWordIndex < totalWordCount) {
            //Gets the input text into an array
            var currentInputWordComponents = inputText!.components(separatedBy: " ")
            let loopInputComponents = currentInputWordComponents
            
            //Loops through all of the typed words in the input text field
            InputWordsLoop: for currentInputWord in loopInputComponents {
                if (currentInputWord == currentInputWordComponents.first!) {
                    //Highlights the current focus word to the starting text color
                    if (currentInputWord == loopInputComponents.first! && currentInputWord.count <= MainTextComponents[currentWordIndex].count) {
                        //Rehighlights the word in order to compensate for deleted input letters
                        let range = (completedMainTextString as NSString).range(of: MainTextComponents[currentWordIndex])
                        attributedMainTextString.addAttribute(.foregroundColor, value: primaryTextColor!, range: range)
                    }
                    
                    //Makes sure the input word is not empty
                    if (!currentInputWord.isEmpty) {
                        //Highlights the letters if the user has correctly typed part of the current word
                        if ((MainTextComponents[currentWordIndex].hasPrefix(currentInputWord) || (MainTextComponents[currentWordIndex] + " ").hasPrefix(currentInputWord))) {
                            //Gets the range to highlight
                            let range = (completedMainTextString as NSString).range(of: currentInputWord)
                            
                            //Adds the attribute
                            attributedMainTextString.addAttribute(.foregroundColor, value: UIColor.green, range: range)
                        }
                            //Highlights individual letters if the user has NOT correcly typed part of the current word
                        else if (currentInputWord.count <= MainTextComponents[currentWordIndex].count) {
                            var lettersIndex = 0 //Keeps track of the current index of the focus letter
                            let currentWord = MainTextComponents[currentWordIndex] //Reference to the current focus word
                            var hasRedHighlightBegin = false //Used to highlight the rest of the word red
                            var tempCompletedTextStr = completedMainTextString! //Used to remove completed letters in the focus word
                            
                            //Loops through each letter in the current input word
                            for letter in currentInputWord {
                                //Checks if the current word letter matches the current input letter
                                if (currentWord[currentWord.index(currentWord.startIndex, offsetBy: lettersIndex)] == letter && !hasRedHighlightBegin) {
                                    //Highlights the letter green
                                    let range = (tempCompletedTextStr as NSString).range(of: String(letter))
                                    attributedMainTextString.addAttribute(.foregroundColor, value: UIColor.green, range: range)
                                }
                                    //Will highlight red the rest of the letters that the user has gotten wrong
                                else {
                                    //Highlights the letter red
                                    let range = (tempCompletedTextStr as NSString).range(of: String(currentWord[currentWord.index(currentWord.startIndex, offsetBy: lettersIndex)]))
                                    //range(of: String(currentWord[startRedIndex...endRedIndex]))
                                    attributedMainTextString.addAttribute(.foregroundColor, value: UIColor.red, range: range)

                                    //Appends the current missed word to the missed words index array
                                    if (!MissedWordsArray.contains(currentWordIndex)) {
                                        MissedWordsArray.append(currentWordIndex)
                                    }
                                    hasRedHighlightBegin = true
                                    
                                    //Produces Haptic
                                    if (!hasProducedHaptic) {
                                        let hapticEnabled = UserDefaults.standard.value(forKey: "HapticEnabled") as? Bool
                                        if (hapticEnabled == true || hapticEnabled == nil) {
                                            let generator = UINotificationFeedbackGenerator()
                                            generator.notificationOccurred(.error)
                                            hasProducedHaptic = true
                                        }
                                        if (hapticEnabled == nil) {
                                            UserDefaults.standard.setValue(true, forKey: "HapticEnabled")
                                        }
                                    }
                                }
                                
                                //Places an asterisk in the processed letter
                                tempCompletedTextStr = tempCompletedTextStr.replacingOccurrences(of: String(currentWord[currentWord.index(currentWord.startIndex, offsetBy: lettersIndex)]), with: "*", options: [], range: tempCompletedTextStr.range(of: String(currentWord[currentWord.index(currentWord.startIndex, offsetBy: lettersIndex)])))
                                
                                //Increases the letter index by 1
                                lettersIndex += 1
                            }
                        }
                        
                        //Switches to the next focus word to type when the user completely types the current word
                        if (((MainTextComponents[currentWordIndex] + " ") == currentInputWord) || ((MainTextComponents[currentWordIndex]) == currentInputWord && (currentInputWordComponents.count > 1 || currentWordIndex == totalWordCount - 1))) {
                            //Resets the input text field
                            inputText!.removeSubrange(inputText!.range(of: MainTextComponents[currentWordIndex])!)
                            if (inputText!.first != nil) {
                                if (inputText!.first! == " ") {
                                    inputText!.removeFirst()
                                }
                            }
                            
                            //Updates the current input word components
                            currentInputWordComponents.removeFirst()
                            
                            //Appends the current word to the completed words array
                            completedWords.append(MainTextComponents[currentWordIndex])
                            
                            //Updates the completedMainTextString to contain "*"s in the words that are completed
                            var asteriskReplacers = ""
                            for _ in MainTextComponents[currentWordIndex] {
                                asteriskReplacers += "*"
                            }
                            completedMainTextString = completedMainTextString.replacingOccurrences(of: MainTextComponents[currentWordIndex], with: asteriskReplacers, options: [], range: completedMainTextString.range(of: MainTextComponents[currentWordIndex]))
                            
                            //Increases the index by 1
                            currentWordIndex += 1
                            
                            //Increases the number of words typed
                            numWordsTyped += 1
                            
                            //Resets haptic var
                            if (hasProducedHaptic) {
                                hasProducedHaptic = false
                            }
                            
                            //Checks if the user has finished typing everything
                            if (currentWordIndex == totalWordCount) {
                                totalTimeTaken = Date().timeIntervalSince1970 - typeStartTime
                                UpdateWPM()
                                inputText = ""
                                hasCompletedText = true
                                break InputWordsLoop
                            }
                            else {
                                //Resets the Focus Text Range to be updated in the MainTextView later
                                let startIndex = completedMainTextString.firstIndex(of: MainTextComponents[currentWordIndex].first!)
                                let endIndex = completedMainTextString.index(startIndex!, offsetBy: 150, limitedBy: completedMainTextString.index(before: completedMainTextString.endIndex))
                                if (endIndex != nil && startIndex != nil) {
                                    focusTextRange = (completedMainTextString as NSString).range(of: String(completedMainTextString[startIndex!...endIndex!]))
                                }
                            }
                        }
                    }
                }
            }
        }
        return inputText ?? ""
    }
    
    //Process text if Emojify is enabled
    public mutating func ProcessInputEmoji(InputText input: String?) -> String {
        var inputText = input ?? "1"
        var focusEmoji = MainTextComponents.first ?? "2"
        if (!inputText.isEmpty && !focusEmoji.isEmpty) {
            for inputChar in inputText {
                if (focusEmoji.first! == inputChar) {
                    //Removes the emoji from the Text View Components, input, and attrMainText
                    MainTextComponents.removeFirst()
                    inputText.removeFirst()
                    let spaceIfNeeded = (!MainTextComponents.isEmpty) ? " ": ""
                    attributedMainTextString.deleteCharacters(in: (attributedMainTextString.string as NSString).range(of: String(inputChar) + spaceIfNeeded))
                    
                    //Increases the number of words typed
                    numWordsTyped += 1
                    //Increases the word index by 1
                    currentWordIndex += 1
                    
                    //Resets haptic var
                    if (hasProducedHaptic) {
                        hasProducedHaptic = false
                    }
                    
                    //Updates the focus emoji
                    focusEmoji = (!MainTextComponents.isEmpty) ? MainTextComponents.first ?? "2": "2"
                } else {
                    //Produces Haptic
                    if (!hasProducedHaptic) {
                        let hapticEnabled = UserDefaults.standard.value(forKey: "HapticEnabled") as? Bool
                        if (hapticEnabled == true || hapticEnabled == nil) {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                            hasProducedHaptic = true
                        }
                        if (hapticEnabled == nil) {
                            UserDefaults.standard.setValue(true, forKey: "HapticEnabled")
                        }
                    }
                    //Appends the current missed word to the missed words index array
                    if (!MissedWordsArray.contains(currentWordIndex)) {
                        MissedWordsArray.append(currentWordIndex)
                    }
                }
                //Checks if user has finished typing all
                if (MainTextComponents.isEmpty) {
                    totalTimeTaken = Date().timeIntervalSince1970 - typeStartTime
                    UpdateWPM()
                    hasCompletedText = true
                }
            }
        }
        return inputText
    }
    
    //Keeps track of time
    public mutating func SetTypeTimeStartToNow() {
        typeStartTime = Date().timeIntervalSince1970
    }
    
    public mutating func GetCurrentTypeTime() -> Double {
        var currentTypeTime: Double = 0
        if (typeStartTime != 0) {
            currentTypeTime = Date().timeIntervalSince1970 - typeStartTime
        }
        return currentTypeTime
    }
    
    //Getters and Updaters of stat variables keeping track of different stats
    public mutating func UpdateAllStatTrackingComponents() {
        UpdateAccuracy()
        UpdateWPM()
        UpdatePercentCompleted()
    }
    
    private mutating func UpdateAccuracy() {
        if (numWordsTyped > 1) {
            let numTyped: Double = Double(numWordsTyped)
            let numMissed: Double = Double(MissedWordsArray.count)
            Accuracy = ((numTyped - numMissed) / numTyped) * 100.0
        }
    }
    public func GetAccuracy() -> Double {
        return Accuracy
    }
    
    private mutating func UpdateWPM() {
        if (hasCompletedText || (GetCurrentTypeTime() != 0 && (Date().timeIntervalSince1970 - typeStartTime) > 8)) {
            WPM = Int(round((Double(numWordsTyped) / (Date().timeIntervalSince1970 - typeStartTime)) * 60))
            //Attempts to check for new highest WPM
            if (WPM > HighestWPM) {
                HighestWPM = WPM
            }
        }
    }
    public func GetWPM() -> Int {
        return WPM
    }
    public func GetHighestWPM() -> Int {
        return HighestWPM
    }
    
    private mutating func UpdatePercentCompleted() {
        if (numWordsTyped != 0 && totalWordCount != 0) {
            percentCompleted = Int(floor(Double(Double(numWordsTyped) / Double(totalWordCount)) * 100.0))
        }
    }
    public func GetPercentCompleted() -> Int {
        return percentCompleted
    }
    
}
