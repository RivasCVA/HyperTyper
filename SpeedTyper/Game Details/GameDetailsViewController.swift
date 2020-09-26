//
//  GameDetailsViewController.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 6/12/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import UIKit

class GameDetailsViewController: UIViewController {
    
    //Delegates
    var MGDelegate: MainGameVCProtocol!
    
    //Outlets
    @IBOutlet weak var TimeValueLabel: UILabel!
    @IBOutlet weak var TimePerWordValueLabel: UILabel!
    @IBOutlet weak var AverageWPMValueLabel: UILabel!
    @IBOutlet weak var HighestWPMValueLabel: UILabel!
    @IBOutlet weak var AccuracyValueLabel: UILabel!
    @IBOutlet weak var WordCountValueLabel: UILabel!
    @IBOutlet weak var TypeValueLabel: UILabel!
    @IBOutlet weak var IDValueLabel: UILabel!
    @IBOutlet weak var LengthValueLabel: UILabel!
    @IBOutlet weak var TextTitleValueLabel: UILabel!
    @IBOutlet weak var TextAuthorValueLabel: UILabel!
    //High Score View
    @IBOutlet weak var FastestTimeValueLabel: UILabel!
    @IBOutlet weak var NewHighScoreImageView: UIImageView!
    @IBOutlet weak var FastestTimePerWordValueLabel: UILabel!
    @IBOutlet weak var HighestAverageWPMValueLabel: UILabel!
    @IBOutlet weak var BestAccuracyValueLabel: UILabel!
    @IBOutlet weak var NumTimesPlayedValueLabel: UILabel!
    
    //Variables
    //Set during Segue Transition
    var textData: TextHolder?
    var totalTime: Double = 0
    var numWords: Int = 0
    var highestWPM: Int = 0
    var accuracy: Double = 0
    //Set in the Pass Game func
    var avgWPM: Int = 0
    var avgTimePerWord: Double = 0
    //Used for exit buttons
    var isRetrying = false
    var isStartingNew = false
    //Used to hold the High Scores of the user
    var fastestTimeHS: Double = 0
    var fastestTimePerWordHS: Double = 0
    var highestAvgWPMHS: Int64 = 0
    var bestAccuracyHS: Double = 0
    var numTimesPlayedHS: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hides the New HS Image
        NewHighScoreImageView.isHidden = true
        
        //Sets up the labels' text
        TimeValueLabel.text = "\(String(format: "%.2f", totalTime)) seconds"
        TimePerWordValueLabel.text = "\(String(format: "%.2f", avgTimePerWord)) sec/word"
        AverageWPMValueLabel.text = "\(avgWPM) WPM"
        HighestWPMValueLabel.text = "\(highestWPM) WPM"
        AccuracyValueLabel.text = "\(String(format: "%.2f", accuracy))%"
        WordCountValueLabel.text = "\(numWords) words"
        TypeValueLabel.text = "\(textData?.TextType.capitalizingFirstLetter() ?? "")"
        IDValueLabel.text = "\(textData?.TextID ?? "")"
        LengthValueLabel.text = "\(textData?.TextLength.capitalizingFirstLetter() ?? "")"
        TextAuthorValueLabel.text = "\(textData?.Author ?? "")"
        
        //Sets up the Style of the Title (can be quotes or italized)
        if (textData?.TitleStyle == TitleStyle.italicize.caseString) {
            let font = UIFont(name: TextTitleValueLabel.font.fontName, size: TextTitleValueLabel.font.pointSize)!.setItalic()
            TextTitleValueLabel.font = font
            TextTitleValueLabel.text = "\(textData?.Title ?? "")"
        }
        else if (textData?.TitleStyle == TitleStyle.quotation.caseString) {
            TextTitleValueLabel.text = "\"\(textData?.Title ?? "")\""
        }
        else if (textData?.TitleStyle == TitleStyle.none.caseString) {
            TextTitleValueLabel.text = textData?.Title ?? ""
        }
        
        //Checks for new Best Stats of current played text
        CheckForNewBestStats()
        
        //Sets up the High Scores View
        CheckForIndividualHighScores()
        FastestTimeValueLabel.text = "\(String(format: "%.2f", fastestTimeHS)) seconds"
        FastestTimePerWordValueLabel.text = "\(String(format: "%.2f", fastestTimePerWordHS)) sec/word"
        HighestAverageWPMValueLabel.text = "\(highestAvgWPMHS) WPM"
        BestAccuracyValueLabel.text = "\(String(format: "%.2f", bestAccuracyHS))%"
        if (numTimesPlayedHS > 1) {
            NumTimesPlayedValueLabel.text = "\(numTimesPlayedHS) times"
        } else { NumTimesPlayedValueLabel.text = "\(numTimesPlayedHS) time" }
    }
    
    //Called by previous Segue to pass Game Details data
    public func PassGameDetailsData(TextData tdata: TextHolder?, Time time: Double, HighestWPM highWPM: Int, Accuracy taccuracy: Double) {
        //Assigns values to the data before presenting it
        self.textData = tdata
        self.totalTime = time
        self.highestWPM = highWPM
        self.numWords = tdata?.Text.components(separatedBy: " ").count ?? 0
        self.accuracy = taccuracy
        self.avgWPM = Int(round((Double(numWords)/(totalTime))*60))
        self.avgTimePerWord = totalTime/Double(numWords)
    }
    
    //Menu Button is Pressed
    @IBAction func MenuButtonPressed(_ sender: UIButton) {
        //Quits all views in returns to the root view which is the Menu View
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
            (appDelegate.window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: true)
        }
    }
    
    //Retry Button is Pressed
    @IBAction func RetryButtonPressed(_ sender: UIButton) {
        //Dismisses this view
        self.dismiss(animated: true, completion: nil)
    }
    
    //New Button is Pressed
    @IBAction func NewButtonPressed(_ sender: UIButton) {
        //Dismisses the view and passes data to find a new text
        var _length = TextLength.random
        var _type = TextType.random
        var _emojifyEnabled =  false
        if let udLength = UserDefaults.standard.value(forKey: "TextLength") as? Int {
            _length = TextLength.allCases.first(where: { $0.rawValue == udLength }) ?? TextLength.random
        }
        if let udType = UserDefaults.standard.value(forKey: "TextType") as? Int {
            _type = TextType.allCases.first(where:  { $0.rawValue == udType }) ?? TextType.random
        }
        if let udEmojify = UserDefaults.standard.value(forKey: "EmojifyEnabled") as? Bool {
            _emojifyEnabled = udEmojify
        }
        self.MGDelegate.DeliverNewTextPreferences(Length: _length, Type: _type, Emojify: _emojifyEnabled, TextID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    //Processes stats from Core Data to check for new highscores
    private func CheckForNewBestStats() {
        
        //Updates the History trackers
        CoreDataManager.shared.AddOverallAverageWPM(WPM: Int64(avgWPM))
        CoreDataManager.shared.AddLast5GamesWPM(WPM: Int64(avgWPM))
        CoreDataManager.shared.AddToTotalGamesPlayed()
        
        //Processes Fastest Time
        if let fastestTime = CoreDataManager.shared.GetFastestTime() {
            if (totalTime < fastestTime) {
                CoreDataManager.shared.SetFastestTimePassage(Time: totalTime, Title: textData?.Title ?? "", Author: textData?.Author ?? "", TextID: textData?.TextID ?? "")
            }
        }
        else {
            CoreDataManager.shared.SetFastestTimePassage(Time: totalTime, Title: textData?.Title ?? "", Author: textData?.Author ?? "", TextID: textData?.TextID ?? "")
        }
        
        //Processes Fastest Time Per Word
        if let fastestTimePerWord = CoreDataManager.shared.GetFastestTimePerWord() {
            if (avgTimePerWord < fastestTimePerWord) {
                CoreDataManager.shared.SetFastestTimePerWordPassage(TimePerWord: avgTimePerWord, Title: textData?.Title ?? "", Author: textData?.Author ?? "", TextID: textData?.TextID ?? "")
            }
        }
        else {
            CoreDataManager.shared.SetFastestTimePerWordPassage(TimePerWord: avgTimePerWord, Title: textData?.Title ?? "", Author: textData?.Author ?? "", TextID: textData?.TextID ?? "")
        }
        
        //Processes Highest Average WPM
        if let highestAvgWPM = CoreDataManager.shared.GetHighestAverageWPM() {
            if (avgWPM > highestAvgWPM) {
                CoreDataManager.shared.SetHighestAverageWPM(AvgWPM: Int64(avgWPM), Title: textData?.Title ?? "", Author: textData?.Author ?? "", TextID: textData?.TextID ?? "")
            }
        }
        else {
            CoreDataManager.shared.SetHighestAverageWPM(AvgWPM: Int64(avgWPM), Title: textData?.Title ?? "", Author: textData?.Author ?? "", TextID: textData?.TextID ?? "")
        }
        
        //Processes Most Accurate
        if let mostAccurate = CoreDataManager.shared.GetMostAccurate() {
            if (accuracy >= mostAccurate) {
                CoreDataManager.shared.SetMostAccurate(Accuracy: accuracy, Title: textData?.Title ?? "", Author: textData?.Author ?? "", TextID: textData?.TextID ?? "")
            }
        }
        else {
            CoreDataManager.shared.SetMostAccurate(Accuracy: accuracy, Title: textData?.Title ?? "", Author: textData?.Author ?? "", TextID: textData?.TextID ?? "")
        }
        
        //Processes Most Played
        CoreDataManager.shared.IncreaseNumPlayed(ForTextID: textData?.TextID)
        let currentNumPlayed = CoreDataManager.shared.GetNumPlayedWith(TextID: textData?.TextID) ?? 1
        if let numMostPlayed = CoreDataManager.shared.GetMostPlayed() {
            if (currentNumPlayed > numMostPlayed) {
                CoreDataManager.shared.SetMostPlayed(NumTimesPlayed: currentNumPlayed, Title: textData?.Title ?? "", Author: textData?.Author ?? "", TextID: textData?.TextID ?? "")
            }
        }
        else {
            CoreDataManager.shared.SetMostPlayed(NumTimesPlayed: currentNumPlayed, Title: textData?.Title ?? "", Author: textData?.Author ?? "", TextID: textData?.TextID ?? "")
        }
        
    }
    
    //Checks and processes individual high scores of this passage
    private func CheckForIndividualHighScores() {
        var couldNotGetHSDataFromCD = false //Helps tests if this attempt is the first
        
        //Retrieves the data from core data
        if let individualHSData = CoreDataManager.shared.GetIndividualHighScores(ForTextID: textData?.TextID) {
            fastestTimeHS = individualHSData["fastesttime"] as? Double ?? Double(0)
            fastestTimePerWordHS = individualHSData["fastesttimeperword"] as? Double ?? Double(0)
            highestAvgWPMHS = individualHSData["highestaveragewpm"] as? Int64 ?? Int64(0)
            bestAccuracyHS = individualHSData["mostaccurate"] as? Double ?? Double(0)
        } else {
            //
            couldNotGetHSDataFromCD = true
            //
            fastestTimeHS = totalTime
            fastestTimePerWordHS = avgTimePerWord
            highestAvgWPMHS = Int64(avgWPM)
            bestAccuracyHS = accuracy
        }
        
        //Check to see if current scores are better than saved high scores
        var hadNewHighScore = false
        var newFastestTimeHighScore: Double? = nil
        var newFastestTimePerWordHighScore: Double? = nil
        var newHighestAvgWPMHighScore: Int64? = nil
        var newBestAccuracyHighScore: Double? = nil
        if (totalTime < fastestTimeHS || fastestTimeHS == 0) {
            newFastestTimeHighScore = totalTime
            fastestTimeHS = totalTime
            hadNewHighScore = true
            FastestTimeValueLabel.textColor = UIColor.yellow
        }
        if (avgTimePerWord < fastestTimePerWordHS || fastestTimePerWordHS == 0) {
            newFastestTimePerWordHighScore = avgTimePerWord
            fastestTimePerWordHS = avgTimePerWord
            hadNewHighScore = true
            FastestTimePerWordValueLabel.textColor = UIColor.yellow
        }
        if (avgWPM > highestAvgWPMHS) {
            newHighestAvgWPMHighScore = Int64(avgWPM)
            highestAvgWPMHS = Int64(avgWPM)
            hadNewHighScore = true
            HighestAverageWPMValueLabel.textColor = UIColor.yellow
        }
        if (accuracy > bestAccuracyHS) {
            newBestAccuracyHighScore = accuracy
            bestAccuracyHS = accuracy
            hadNewHighScore = true
            BestAccuracyValueLabel.textColor = UIColor.yellow
        }
        
        //Saves new data to Core Data
        if (!couldNotGetHSDataFromCD) {
            CoreDataManager.shared.SetIndividualHighScores(ForTextID: textData?.TextID, FastestTime: newFastestTimeHighScore, FastestTimePerWord: newFastestTimePerWordHighScore, HighestAvgWPM: newHighestAvgWPMHighScore, BestAccuracy: newBestAccuracyHighScore)
        } else {
            CoreDataManager.shared.SetIndividualHighScores(ForTextID: textData?.TextID, FastestTime: fastestTimeHS, FastestTimePerWord: fastestTimePerWordHS, HighestAvgWPM: highestAvgWPMHS, BestAccuracy: bestAccuracyHS)
        }
        
        //Gets the number of times played data
        if let cdtimesplayed = CoreDataManager.shared.GetNumPlayedWith(TextID: textData?.TextID) {
            numTimesPlayedHS = cdtimesplayed
        } else {
            numTimesPlayedHS = 1
        }
        
        //Shows the New HS Image if necessary
        if (hadNewHighScore) {
            NewHighScoreImageView.isHidden = false
        }
    }

}


//Used to capitalize first letter of any string
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

//Used to Italize and Bold Fonts
extension UIFont {
    var isBold: Bool
    {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool
    {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    func setBold() -> UIFont
    {
        if isBold {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.insert([.traitBold])
            let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
            return UIFont(descriptor: fontDescriptorVar!, size: 0)
        }
    }
    
    func removeBold()-> UIFont
    {
        if !isBold {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.remove([.traitBold])
            let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
            return UIFont(descriptor: fontDescriptorVar!, size: 0)
        }
    }
    
    func setItalic() -> UIFont
    {
        if isBold {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.insert([.traitItalic])
            let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
            return UIFont(descriptor: fontDescriptorVar!, size: 0)
        }
    }
    
    func removeItalic()-> UIFont
    {
        if !isBold {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.remove([.traitItalic])
            let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
            return UIFont(descriptor: fontDescriptorVar!, size: 0)
        }
    }
}

