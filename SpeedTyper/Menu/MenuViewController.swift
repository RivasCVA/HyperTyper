//
//  MenuViewController.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 6/7/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MenuViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    //Outlets
    @IBOutlet weak var QuoteTextLabel: UILabel!
    @IBOutlet weak var QuoteAuthorLabel: UILabel!
    //Text Options Outlets
    @IBOutlet weak var TextOptionsView: UIView!
    @IBOutlet weak var TextTypeSegmentedController: UISegmentedControl!
    @IBOutlet weak var TextLengthSegmentedController: UISegmentedControl!
    @IBOutlet weak var EmojifySwitch: UISwitch!
    @IBOutlet weak var TextIDTextField: UITextField!
    
    //Quote of the Day
    var QuoteOfTheDayText = ""
    var QuoteOfTheDayAuthor = ""
    
    //Passed onto Main Game
    var preferredTextLength = TextLength.random
    var preferredTextType = TextType.random
    var emojifyEnabled = false
    var preferredTextID: String?
    
    //Recognizes taps on the View
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Sets the delegates
        TextIDTextField.delegate = self
        
        //Changes the alpha to animate
        self.QuoteTextLabel.alpha = 0
        self.QuoteAuthorLabel.alpha = 0
        
        //Sets up the tapGestureRecognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboardIfPresent))
        
        //Sets up the Text Options Outlets
        TextOptionsView.isHidden = true
        TextOptionsView.alpha = 0
        
        //Gets and Sets the Quote of the Day
        SetupQuoteOfTheDay()
        
        //Gets and Sets the user defaults for the Text Options
        SetupTextOptions()
        
        //Sets up the Background Music
        SetupBackgroundMusic()
        
        //Initializes Google Mobile Ads
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Adds the tap recognizer
        self.view.addGestureRecognizer(tapGestureRecognizer!)
        
        //Used to notify when keyboard will appear
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //Blanks the Text ID var and label
        preferredTextID = nil
        TextIDTextField.text = ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //Hides the Options View in case it is present
        TextOptionsView.alpha = 0
        TextOptionsView.isHidden = true
        
        //Removes the tap recognizer
        view.removeGestureRecognizer(tapGestureRecognizer!)
        
        //Removes the observer to hide keyboard
        NotificationCenter.default.removeObserver(self)
        
        //Resets the constraint of the TextID
        resetTextIDContraint()
    }
    
    //Sets up the Quote of the Day
    private func SetupQuoteOfTheDay() {
        QuoteOfTheDay.getQuoteOfTheDay { (APIQuote, APIAuthor) in
            DispatchQueue.main.async {
                
                if (APIQuote != nil && APIAuthor != nil) {
                    self.QuoteOfTheDayText = APIQuote!
                    self.QuoteOfTheDayAuthor = APIAuthor!
                } else {
                    //Get Offline QotD
                    self.QuoteOfTheDayText = "Have the courage to follow your heart and intuition. They somehow already know what you truly want to become."
                    self.QuoteOfTheDayAuthor = "Steve Jobs"
                }
                //Updates the labels and views wth animation
                self.QuoteTextLabel.text = "\"\(self.QuoteOfTheDayText)\""
                self.QuoteAuthorLabel.text = "\(self.QuoteOfTheDayAuthor) ~ FavQs"
                let t1 = CGAffineTransform.identity.scaledBy(x: 1.4, y: 1.4)
                self.QuoteTextLabel.transform = t1
                self.QuoteAuthorLabel.transform = t1
                UIView.animate(withDuration: 0.75, animations: {
                    self.QuoteTextLabel.alpha = 1
                    self.QuoteAuthorLabel.alpha = 1
                    self.QuoteTextLabel.transform = CGAffineTransform.identity
                    self.QuoteAuthorLabel.transform = CGAffineTransform.identity
                })
            }
        }
    }
    
    //Sets up the Background Music
    private func SetupBackgroundMusic() {
        //Gets preference from User Defaults
        let musicEnabled = UserDefaults.standard.value(forKey: "MusicEnabled") as? Bool
        if (musicEnabled == true || musicEnabled == nil) {
            BackgroundMusic.shared.startBackgroundMusic()
        }
        if (musicEnabled == nil) {
            UserDefaults.standard.setValue(true, forKey: "MusicEnabled")
        }
    }
    
    //Sets up the User Defaults for the Text Options
    private func SetupTextOptions() {
        //Sets up the vars from User Defaults
        preferredTextType = TextType.init(rawValue: UserDefaultsManager.shared.getTextTypeIndex())!
        preferredTextLength = TextLength.init(rawValue: UserDefaultsManager.shared.getTextLengthIndex())!
        emojifyEnabled = UserDefaultsManager.shared.getEmojifyEnabled()
        
       //Sets up the segmented controllers
        TextTypeSegmentedController.selectedSegmentIndex = preferredTextType.rawValue
        TextLengthSegmentedController.selectedSegmentIndex = preferredTextLength.rawValue
        EmojifySwitch.isOn = emojifyEnabled
    }
    
    //Start Button is Pressed
    @IBAction func StartButtonPressed(_ sender: UIButton) {
        //Switches to the Main Game VC
        self.performSegue(withIdentifier: "MenuToMainGame", sender: self)
    }
    
    //Text Options Button is Pressed
    @IBAction func TextOptionsButton(_ sender: UIButton) {
        toggleTextOptionsView()
    }
    
    //Will Show or Hide the View
    private func toggleTextOptionsView() {
        dismissKeyboardIfPresent()
        //Shows or Hides the Text Options View with an animation
        let changedTransform = CGAffineTransform.identity.translatedBy(x: 0, y: -165).scaledBy(x: 1, y: 0)
        if (TextOptionsView.isHidden) {
            TextOptionsView.transform = changedTransform
            self.TextOptionsView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.TextOptionsView.alpha = 1
                self.TextOptionsView.transform = CGAffineTransform.identity
            }
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.TextOptionsView.alpha = 0
            }) { (done) in
                self.TextOptionsView.isHidden = true
            }
        }
    }
    
    //Hides keyboard when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboardIfPresent()
        return true
    }
    
    //Dismisses the keyboard and resets the constraint of the Text Field
    @objc private func dismissKeyboardIfPresent() {
        if (TextIDTextField.isFirstResponder) {
            TextIDTextField.resignFirstResponder()
            resetTextIDContraint()
        }
    }
    
    private func resetTextIDContraint() {
        if let textIDFieldCenterConstraint = self.TextOptionsView.constraints.filter({ $0.identifier == "TextIDCenterConstraint"}).first {
            textIDFieldCenterConstraint.constant = 0
        }
    }
    
    //Runs before keyboard pop up: Will move the ID Text Label
    @objc private func keyboardWillShow(_ notification: Notification) {
        if (TextIDTextField.isFirstResponder) {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                if let textIDFieldCenterConstraint = self.TextOptionsView.constraints.filter({ $0.identifier == "TextIDCenterConstraint"}).first {
                    textIDFieldCenterConstraint.constant = -keyboardHeight + (self.view.frame.size.height - self.view.convert(self.TextIDTextField.frame, from: self.TextOptionsView).origin.y) - self.TextIDTextField.frame.size.height
                }
            }
        }
    }
    
    //Text ID Field input changed
    @IBAction func TextIDTextFieldChanged(_ sender: UITextField) {
        if (sender.text?.isEmpty == true) {
            preferredTextID = nil
        } else {
            preferredTextID = sender.text?.uppercased()
            sender.text = sender.text?.uppercased()
            //Removes blank space if present at the end
            if (preferredTextID?.last == " ") {
                preferredTextID?.removeLast()
            }
        }
    }
    
    //Stats Button is Pressed
    @IBAction func StatsButtonPressed(_ sender: UIButton) {
        //Shows the view
        self.performSegue(withIdentifier: "MenuToBestStats", sender: self)
    }
    
    //Settings Button is Pressed
    @IBAction func SettingButtonPressed(_ sender: UIButton) {
        //Shows the view
        self.performSegue(withIdentifier: "MenuToSettings", sender: self)
    }
    
    //Detects a Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //Touching outside the Text Options View
        if (touch?.view != TextOptionsView) {
            if (TextOptionsView.isHidden == false) {
                toggleTextOptionsView()
            }
        }
    }
    
    //Prepares a segue before transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueID = segue.identifier {
            switch (segueID) {
            case "MenuToMainGame":
                //Passes text options data to the Main Game VC
                let MGViewController = segue.destination as? MainGameViewController
                MGViewController?.SetupNewTextData(Length: preferredTextLength, Type: preferredTextType, Emojify: emojifyEnabled, TextID: preferredTextID)
            default:
                break
            }
        }
        
    }
    
    //Updates the corresponding variable and the value in User Defaults
    @IBAction func TextTypeSegmentedControllerChanged(_ sender: UISegmentedControl) {
        for type in TextType.allCases {
            if (type.rawValue == sender.selectedSegmentIndex) {
                preferredTextType = type
            }
        }
        UserDefaults.standard.setValue(preferredTextType.rawValue, forKey: "TextType")
    }
    @IBAction func TextLengthSegmentedControllerChanged(_ sender: UISegmentedControl) {
        for length in TextLength.allCases {
            if (length.rawValue == sender.selectedSegmentIndex) {
                preferredTextLength = length
            }
        }
        UserDefaults.standard.setValue(preferredTextLength.rawValue, forKey: "TextLength")
    }
    @IBAction func EmojifySwitchChanged(_ sender: UISwitch) {
        emojifyEnabled = sender.isOn
        UserDefaults.standard.setValue(emojifyEnabled, forKey: "EmojifyEnabled")
    }
    

}
