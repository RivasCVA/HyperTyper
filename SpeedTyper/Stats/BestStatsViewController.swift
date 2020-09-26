//
//  BestStatsViewController.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 6/27/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import UIKit

class BestStatsViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var OverallWPMValueLabel: UILabel!
    @IBOutlet weak var Last5GamesValueLabel: UILabel!
    @IBOutlet weak var TotalGamesPlayedValueLabel: UILabel!
    @IBOutlet weak var FastestTimePassageValueLabel: UILabel!
    @IBOutlet weak var FastestTimeTextIDValueLabel: UILabel!
    @IBOutlet weak var FastestTimeTimeValueLabel: UILabel!
    @IBOutlet weak var HighestWPMPassageValueLabel: UILabel!
    @IBOutlet weak var HighestWPMTextIDValueLabel: UILabel!
    @IBOutlet weak var HighestWPMWPMValueLabel: UILabel!
    @IBOutlet weak var MostAccuratePassageValueLabel: UILabel!
    @IBOutlet weak var MostAccurateTextIDValueLabel: UILabel!
    @IBOutlet weak var MostAccurateAccuracyValueLabel: UILabel!
    @IBOutlet weak var MostPlayedPassageValueLabel: UILabel!
    @IBOutlet weak var MostPlayedTextIDValueLabel: UILabel!
    @IBOutlet weak var MostPlayedNumTimesValueLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Overall WPM
        if let overallWPM = CoreDataManager.shared.GetOverallAverageWPM() {
            OverallWPMValueLabel.text = "\(overallWPM) WPM"
        } else {
            OverallWPMValueLabel.text = String(0)
        }
        
        //Last 5 Games WPM
        if let last5WPM = CoreDataManager.shared.GetLast5GamesWPM() {
            Last5GamesValueLabel.text = "\(last5WPM) WPM"
        } else {
            Last5GamesValueLabel.text = String(0)
        }
        
        //Total Games Played
        if let totalGames = CoreDataManager.shared.GetTotalGamesPlayed() {
            if (totalGames > 1) {
                TotalGamesPlayedValueLabel.text = "\(totalGames) games"
            } else { TotalGamesPlayedValueLabel.text = "\(totalGames) game" }
        } else {
            TotalGamesPlayedValueLabel.text = String(0)
        }
        
        //Fastest Time
        if let fastestTimeData = CoreDataManager.shared.GetFastestTimeData() {
            FastestTimePassageValueLabel.text = (fastestTimeData["title"] as? String ?? "")
            FastestTimeTextIDValueLabel.text = (fastestTimeData["textid"] as? String ?? "")
            FastestTimeTimeValueLabel.text = "\(String(format: "%.2f", fastestTimeData["time"] as? Double ?? 0)) seconds"
        } else {
            FastestTimePassageValueLabel.text = "No Data"
            FastestTimeTextIDValueLabel.text = "No Data"
            FastestTimeTimeValueLabel.text = String(0)
        }
        
        //Highest Avg WPM
        if let highestWPMData = CoreDataManager.shared.GetHighestAverageWPMData() {
            HighestWPMPassageValueLabel.text = (highestWPMData["title"] as? String ?? "")
            HighestWPMTextIDValueLabel.text = (highestWPMData["textid"] as? String ?? "")
            HighestWPMWPMValueLabel.text = "\(highestWPMData["averagewpm"] as? Int64 ?? 0) WPM"
        } else {
            HighestWPMPassageValueLabel.text = "No Data"
            HighestWPMTextIDValueLabel.text = "No Data"
            HighestWPMWPMValueLabel.text = String(0)
        }
        
        //Most Accurate
        if let mostAccurateData = CoreDataManager.shared.GetMostAccurateData() {
            MostAccuratePassageValueLabel.text = (mostAccurateData["title"] as? String ?? "")
            MostAccurateTextIDValueLabel.text = (mostAccurateData["textid"] as? String ?? "")
            MostAccurateAccuracyValueLabel.text = "\(String(format: "%.2f", mostAccurateData["accuracy"] as? Double ?? 0))%"
        } else {
            MostAccuratePassageValueLabel.text = "No Data"
            MostAccurateTextIDValueLabel.text = "No Data"
            MostAccurateAccuracyValueLabel.text = String(0)
        }
        
        //Most Played
        if let mostPlayedData = CoreDataManager.shared.GetMostPlayedData() {
            MostPlayedPassageValueLabel.text = (mostPlayedData["title"] as? String ?? "")
            MostPlayedTextIDValueLabel.text = (mostPlayedData["textid"] as? String ?? "")
            let numTimes = mostPlayedData["numtimesplayed"] as? Int64 ?? 0
            if (numTimes > 1) {
                MostPlayedNumTimesValueLabel.text = "\(numTimes) times"
            } else { MostPlayedNumTimesValueLabel.text = "\(numTimes) time" }
        } else {
            MostPlayedPassageValueLabel.text = "No Data"
            MostPlayedTextIDValueLabel.text = "No Data"
            MostPlayedNumTimesValueLabel.text = String(0)
        }
        
    }
    
    //Exit Button Pressed
    @IBAction func ExitButtonPressed(_ sender: UIButton) {
        //Dismisses the view
        self.dismiss(animated: true, completion: nil)
    }
    
}
