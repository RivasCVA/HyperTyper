//
//  MainGameViewController.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 5/27/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds

//Used to get data from the Game Details VC
protocol MainGameVCProtocol {
    func DeliverNewTextPreferences(Length length: TextLength, Type type: TextType, Emojify emojify: Bool, TextID textID: String?)
}

class MainGameViewController: UIViewController, MainGameVCProtocol, GADInterstitialDelegate {
    
    //View Outlets
    @IBOutlet weak var MainTextView: UITextView!
    @IBOutlet weak var TypeTextField: UITextField!
    @IBOutlet weak var PercentLabel: UILabel!
    @IBOutlet weak var WPMLabel: UILabel!
    @IBOutlet weak var ProgressLineImageView: UIImageView!
    @IBOutlet weak var RunnerObjectImageView: UIImageView!
    @IBOutlet weak var ExitEffectView: UIVisualEffectView!
    @IBOutlet weak var TextCreditsLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    
    //Interstitial Ad
    var interstitial: GADInterstitial!
    //Tracks if will show interstitial this game
    private var willShowInterstitial = false
    //Will keep track if attempted to present an ad
    private var didAttemptPresentInterstitial = false
    //Run ad after every x number of completed texts
    private let adFactor = 2
    
    //Variables
    var mainTyperBrain: TyperBrain!
    
    var CurrentTextData: TextHolder?
    var MainTextString: String! //Will hold the all of the text the user will need to type
    var isTextEmojis: Bool = false
    var startingTextColor: UIColor = UIColor()
    var defaultTextViewColor: UIColor = UIColor()
    
    var LabelRefreshTimer: Timer = Timer()
    
    var hasStartedTyping = false
    var hasFinishedTypingAll = false
    var runnerObjectStartX = CGFloat(0)
    var runnerObjectEndX = CGFloat(0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Will obtain the default color of the Main Text View
        defaultTextViewColor = MainTextView.backgroundColor ?? UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (!didAttemptPresentInterstitial) {
            //Resets the Refresh Timer
            LabelRefreshTimer = Timer()
            
            //Resets the typing state booleans
            hasStartedTyping = false
            hasFinishedTypingAll = false
            
            //Does not allow the user to edit the text view
            MainTextView.isUserInteractionEnabled = false
            
            //Sets up the labels for the start
            PercentLabel.text = "0%\nDone"
            WPMLabel.text = "0\nWPM"
            TimeLabel.text = "0:00"
            
            //Updates the text view
            MainTextView.text = MainTextString
            
            //Gets the font for the Text View from User Defaults
            if let udFontName = UserDefaults.standard.value(forKey: "MainTextFont") as? String {
                MainTextView.font = UIFont(name: udFontName, size: !isTextEmojis ? MainTextView.font!.pointSize : 28)
            }
            
            if (isTextEmojis) {
                MainTextView.backgroundColor = UIColor.lightGray
            } else {
                MainTextView.backgroundColor = defaultTextViewColor
            }
            
            //Sets up the starting text color
            startingTextColor = MainTextView.textColor!
            
            //Sets up the Typer Brain
            mainTyperBrain = TyperBrain(AttributedMainText: MainTextView.attributedText)
            
            //Sets up the Text Credits Label
            SetupTextCreditsLabel()
            
            //Pops up the keyboard for the TypeTextField (delays to give view some time to pop up)
            TypeTextField.isUserInteractionEnabled = true
            TypeTextField.autocorrectionType = .no
            Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { (timer) in
                if (self.view.isHidden == false) {
                    self.TypeTextField.becomeFirstResponder()
                }
            }
            
            // Resets the runner object contraint
            if let runnerObjectLeadingConstraint = self.view.constraints.filter({ $0.identifier == "RunnerObjectLeadingConstraint"}).first {
                runnerObjectLeadingConstraint.constant = 0
            }
            
            //Sets up the exit view for animation
            ExitEffectView.alpha = 0
            ExitEffectView.isHidden = true
            
            //Sets up the Label Refreshing Timer
            LabelRefreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateLabels), userInfo: nil, repeats: true)
        }
    }
    
    //When the view appears
    override func viewDidAppear(_ animate: Bool) {
        //Sets up the Starting and Ending positions of the runner object
        runnerObjectStartX = ProgressLineImageView.frame.origin.x
        runnerObjectEndX = runnerObjectStartX + ProgressLineImageView.frame.width - RunnerObjectImageView.frame.width
        RunnerObjectImageView.frame.origin.x = runnerObjectStartX
        
        //Resumes the background music if paused
        BackgroundMusic.shared.resumeBackgroundMusic()
        
        //Checks if the view will move to Game Details
        //If not, it will check if it will show ad after finishing
        if (didAttemptPresentInterstitial) {
            didAttemptPresentInterstitial = false
            switchToGameDetails()
        } else {
            //Sets up and loads a new interstitial ad if needed
            let gamesPlayed = CoreDataManager.shared.GetTotalGamesPlayed() ?? 1
            if (gamesPlayed % Int64(adFactor) == 0) {
                willShowInterstitial = true;
                loadInterstitialAd()
            } else {
                willShowInterstitial = false;
            }
        }
    }
    
    //Before the view closes
    override func viewWillDisappear(_ animated: Bool) {
        //Invalidates the refresh timer
        if (LabelRefreshTimer.isValid) {
            LabelRefreshTimer.invalidate()
        }
        //Resets the Main Text View's scroll to top
        MainTextView.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    
    //Called before this View is presented
    //Sets up the the text information
    public func SetupNewTextData(Length length: TextLength, Type type: TextType, Emojify emojify: Bool, TextID textID: String?) {
        CurrentTextData = AllTextManager.GetSelectText(Type: type, Length: length, Emojify: emojify, TextID: textID)
        MainTextString = CurrentTextData?.Text
        isTextEmojis = emojify
    }
    //Using a protocol delegate
    func DeliverNewTextPreferences(Length length: TextLength, Type type: TextType, Emojify emojify: Bool, TextID textID: String?) {
        SetupNewTextData(Length: length, Type: type, Emojify: emojify, TextID: textID)
        isTextEmojis = emojify
    }
    
    //Type Text Field was changed
    @IBAction func TypeTextFieldChanged(_ sender: UITextField) {
        //Checks if this is the user's first type, which starts the label updates
        if (!hasStartedTyping) {
            mainTyperBrain.SetTypeTimeStartToNow()
            hasStartedTyping = true
        }
        
        //Processes the new input text
        if (!isTextEmojis) {
            sender.text = mainTyperBrain.ProcessInputText(InputText: sender.text)
            MainTextView.attributedText = mainTyperBrain.GetAttributedMainTextString()
            hasFinishedTypingAll = mainTyperBrain.HasCompletedText()
        } else {
            sender.text = mainTyperBrain.ProcessInputEmoji(InputText: sender.text)
            MainTextView.attributedText = mainTyperBrain.GetAttributedMainTextString()
            hasFinishedTypingAll = mainTyperBrain.HasCompletedText()
        }
        
        //The user has finished typing
        if (hasFinishedTypingAll) {
            LabelRefreshTimer.invalidate()
            UpdateLabels()
            TypeTextField.resignFirstResponder()
            TypeTextField.isUserInteractionEnabled = false
            //Will show ad; Ad will performSegue
            if (willShowInterstitial) {
                presentInterstitialAd()
            } else {
                switchToGameDetails()
            }
        } else {
            //Updates the focus range of the MainTextView
            if let focusRange = mainTyperBrain.GetFocusTextRange() {
                MainTextView.scrollRangeToVisible(focusRange)
            }
        }
    }
    
    //Performs Segue to Game Details View Controller
    private func switchToGameDetails() {
        performSegue(withIdentifier: "MainGameToGameDetails", sender: self)
    }
    
    //Prepares the destination view before Segue is performed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueID = segue.identifier {
            switch (segueID) {
            case "MainGameToGameDetails":
                //Passes the game details data
                let GDViewController = segue.destination as? GameDetailsViewController
                GDViewController?.PassGameDetailsData(TextData: CurrentTextData, Time: mainTyperBrain.GetTotalTypeTimeTaken(), HighestWPM: mainTyperBrain.GetHighestWPM(), Accuracy: mainTyperBrain.GetAccuracy())
                //Sets the delegate to this view in order to pass back information
                GDViewController?.MGDelegate = self
            default:
                break
            }
        }
    }
    
    //Will update all the labels : Attached to a timer that executes every second
    @objc private func UpdateLabels() {
        if (hasStartedTyping) {
            mainTyperBrain.UpdateAllStatTrackingComponents()
            UpdateWPMLabel()
            UpdatePercentCompletedLabel()
            UpdateTimeLabel()
            UpdateRunnerObject()
        }
    }
    
    //Updates the Time Label
    private func UpdateTimeLabel() {
        let currentTime = mainTyperBrain.GetCurrentTypeTime()
        let minute = Int(floor(currentTime / 60))
        let seconds = Int(floor(((currentTime / 60) - Double(minute)) * 60))
        if (seconds < 10) {
            TimeLabel.text = "\(minute):0\(seconds)"
        } else {
            TimeLabel.text = "\(minute):\(seconds)"
        }
    }
    
    //Updates the Words Per Minute Label
    private func UpdateWPMLabel() {
        if (mainTyperBrain.GetCurrentTypeTime() >= 4) {
            WPMLabel.text = "\(mainTyperBrain.GetWPM())\nWPM"
        }
    }
    
    //Updates the Percent of text Completed Label
    private func UpdatePercentCompletedLabel() {
        PercentLabel.text = "\(mainTyperBrain.GetPercentCompleted())%\nDone"
    }
    
    //Moves the runner object based on the percent of text completed
    private func UpdateRunnerObject() {
        if (mainTyperBrain.GetPercentCompleted() != 0) {
            let XPosDifference = runnerObjectEndX - runnerObjectStartX
            let percentDecimal = Double(mainTyperBrain.GetPercentCompleted()) / 100.0
            let XPosCompleted = XPosDifference * CGFloat(percentDecimal)
            if let runnerObjectLeadingConstraint = self.view.constraints.filter({ $0.identifier == "RunnerObjectLeadingConstraint"}).first {
                UIView.animate(withDuration: 0.5) {
                    runnerObjectLeadingConstraint.constant = XPosCompleted
                }
            }
        }
    }
    
    //Sets up the Text Credits Label
    private func SetupTextCreditsLabel() {
        //Hold the text credit title and author
        let creditsTitle = CurrentTextData?.Title ?? ""
        let creditsAuthor = CurrentTextData?.Author ?? ""
        var creditsText: String
        //Checks if there is a Title
        if (!creditsTitle.isEmpty) {
            //Sets up the Title
            creditsText = "- \"\(creditsTitle)\""
            //Sets up the Title with the Author if there is an Author
            if (!creditsAuthor.isEmpty) {
                creditsText = "- \"\(creditsTitle)\" by \(creditsAuthor)"
            }
            //Sets up the Style of the Title (can be quoted or italized or neither)
            if (CurrentTextData!.TitleStyle == TitleStyle.italicize.caseString) {
                //Nils the attributed text
                TextCreditsLabel.attributedText = nil
                //Removes the quotes and italizes the Title using an Attributed String
                creditsText = creditsText.replacingOccurrences(of: "\"", with: "")
                let attributedCreditsText = NSMutableAttributedString(string: creditsText)
                var _font = UIFont(name: TextCreditsLabel.font.fontName, size: TextCreditsLabel.font.pointSize)!
                _font = _font.setItalic()
                attributedCreditsText.addAttribute(.font, value: _font, range: (creditsText as NSString).range(of: creditsTitle))
                attributedCreditsText.addAttribute(.foregroundColor, value: TextCreditsLabel.textColor!, range: (creditsText as NSString).range(of: creditsText))
                
                //Sets up the attributed text in the Text Credits Label
                TextCreditsLabel.attributedText = attributedCreditsText
            }
            else if (CurrentTextData!.TitleStyle == TitleStyle.quotation.caseString) {
                //Sets up the Text Credits Label with the quoted Title
                TextCreditsLabel.text = creditsText
            }
            else if (CurrentTextData!.TitleStyle == TitleStyle.none.caseString) {
                //Sets up the label with a non-edited Title
                TextCreditsLabel.text = " - " + creditsTitle + " by " + creditsAuthor
            } else {print("The is no Text Title Style accredited to the text: \(creditsTitle), \(creditsAuthor)")}
        }
        else if (!creditsAuthor.isEmpty) {
            //Only sets up the Author in the Text Credits Label
            creditsText = "- \(creditsAuthor)"
            TextCreditsLabel.text = creditsText
        } else { TextCreditsLabel.text = "" }
    }
    
    //Exit Button Pressed
    @IBAction func ExitButtonPressed(_ sender: UIButton) {
        //Shows the Exit View asking if user really wants to quit
        ExitEffectView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.ExitEffectView.alpha = 1
        }
    }
    
    //Exit View Yes Button Pressed
    @IBAction func ExitYesButtonPressed(_ sender: UIButton) {
        //Produces Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        //Dismisses the View
        TypeTextField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    //Exit View No Button Pressed
    @IBAction func ExitNoButtonPressed(_ sender: UIButton) {
        //Hides the Exit View
        UIView.animate(withDuration: 0.25, animations: {
            self.ExitEffectView.alpha = 0
        }) { (done) in
            self.ExitEffectView.isHidden = true
        }
    }
    
    //Sets up the interstitial ad
    private func loadInterstitialAd() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-5709626172947104/5889913909")
        interstitial.delegate = self
        let request = GADRequest()
        
        //REMOVE FOR RELEASE
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["a452c97175ecae1bbdc010df18db29c8"]
        
        interstitial.load(request)
    }
    
    //Displays ad into the screen
    private func presentInterstitialAd() {
        if (interstitial.isReady) {
            BackgroundMusic.shared.pauseBackgroundMusic()
            didAttemptPresentInterstitial = true
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad was not ready to be presented!")
            switchToGameDetails()
        }
    }
    
    /* INTERSTITIAL AD FUNCTIONS
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      //print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      //print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      //print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      //print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      //print("interstitialDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      //print("interstitialWillLeaveApplication")
    }
    */
    
}
