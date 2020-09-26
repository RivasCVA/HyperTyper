//
//  SettingsViewController.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 7/4/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate {
    
    //App Delegate
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //Outlets
    @IBOutlet weak var TextFontValueLabel: UILabel!
    @IBOutlet weak var FontDropDownButton: UIButton!
    @IBOutlet weak var FontsUIView: UIView!
    @IBOutlet weak var FontPickerView: UIPickerView!
    @IBOutlet weak var MusicSwitch: UISwitch!
    @IBOutlet weak var HapticSwitch: UISwitch!
    @IBOutlet weak var EraseButton: UIButton!
    @IBOutlet weak var ConfirmEraseButton: UIButton!
    @IBOutlet weak var ConfirmEraseLabel: UILabel!
    
    
    //Vars
    let fontPickerViewValues = [
        "Rockwell", "American Typewriter", "Times New Roman", "Arial", "Papyrus", "Chalkboard SE", "Helvetica"
    ]
    var currentSelectedFont = ""
    
    
    //Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontPickerViewValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fontPickerViewValues[row]
    }
    
    //Row is selected in Picker View
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentSelectedFont = fontPickerViewValues[row]
        TextFontValueLabel.font = UIFont(name: currentSelectedFont, size: TextFontValueLabel.font.pointSize)
        TextFontValueLabel.text = currentSelectedFont
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets up the picker view
        FontPickerView.dataSource = self
        FontPickerView.delegate = self

        //Hides the Fonts View
        FontsUIView.alpha = 0
        FontsUIView.isHidden = true
        
        //Sets the Font of the Text Font Value Label
        if let udFontName = UserDefaults.standard.value(forKey: "MainTextFont") as? String {
            currentSelectedFont = udFontName
            TextFontValueLabel.font = UIFont(name: udFontName, size: TextFontValueLabel.font!.pointSize)
            TextFontValueLabel.text = udFontName
        } else {
            currentSelectedFont = "American Typewriter"
            TextFontValueLabel.font = UIFont(name: currentSelectedFont, size: TextFontValueLabel.font!.pointSize)
            TextFontValueLabel.text = currentSelectedFont
        }
        
        //Sets the default selected row
        FontPickerView.selectRow(fontPickerViewValues.firstIndex(of: currentSelectedFont)!, inComponent: 0, animated: false)
        
        //Adds a tap gesture recognizer to the Text Font Value Label
        TextFontValueLabel.isUserInteractionEnabled = true
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(FontDropDownButtonPressed(_:)))
        tapGesture.delegate = self
        TextFontValueLabel.addGestureRecognizer(tapGesture)
        
        //Sets up the values for the Switches
        if let musicOn = UserDefaults.standard.value(forKey: "MusicEnabled") as? Bool {
            MusicSwitch.isOn = musicOn
        } else { MusicSwitch.isOn = true }
        if let hapticOn = UserDefaults.standard.value(forKey: "HapticEnabled") as? Bool {
            HapticSwitch.isOn = hapticOn
        } else { HapticSwitch.isOn = true }
        
        //Sets up the Confirm Erase Button for animation
        ConfirmEraseButton.isHidden = true
        ConfirmEraseButton.alpha = 0
        ConfirmEraseLabel.isHidden = true
        ConfirmEraseLabel.alpha = 1
    }
    
    //Text Font Choose Drop Down Button Pressed
    @IBAction func FontDropDownButtonPressed(_ sender: UIButton) {
        //Shows or Hides the Text Options View with an animation
        let changedTransform = CGAffineTransform.identity.translatedBy(x: 0, y: -120).scaledBy(x: 1, y: 0)
        if (FontsUIView.isHidden) {
            FontsUIView.transform = changedTransform
            self.FontsUIView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.FontsUIView.alpha = 1
                self.FontsUIView.transform = CGAffineTransform.identity
            }
        } else {
            //Resets to previous state
            ResetTextFontValueLabel()
            //Hides
            HideFontUIView()
        }
    }
    
    //Hides the Font UI View with an Animation
    private func HideFontUIView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.FontsUIView.alpha = 0
        }) { (done) in
            self.FontsUIView.isHidden = true
        }
    }
    
    //Cancel Button in the Fonts UIView Pressed
    @IBAction func FontCancelButtonPressed(_ sender: UIButton) {
        //Resets to previous state
        ResetTextFontValueLabel()
        //Hides
        HideFontUIView()
    }
    
    //Resets the value of the Text Font Value Label to what it was previously
    private func ResetTextFontValueLabel() {
        //Sets the Font of the Text Font Value Label to what it was previously
        if let udFontName = UserDefaults.standard.value(forKey: "MainTextFont") as? String {
            currentSelectedFont = udFontName
            TextFontValueLabel.font = UIFont(name: udFontName, size: TextFontValueLabel.font!.pointSize)
            TextFontValueLabel.text = udFontName
        } else {
            currentSelectedFont = "American Typewriter"
            TextFontValueLabel.font = UIFont(name: currentSelectedFont, size: TextFontValueLabel.font!.pointSize)
            TextFontValueLabel.text = currentSelectedFont
        }
        
        //Resets the selected view
        FontPickerView.selectRow(fontPickerViewValues.firstIndex(of: currentSelectedFont)!, inComponent: 0, animated: true)
    }
    
    //Save Button in the Fonts UIView Pressed
    @IBAction func FontSaveButtonPressed(_ sender: UIButton) {
        //Saves the current font name to User Defaults
        UserDefaults.standard.setValue(currentSelectedFont, forKey: "MainTextFont")
        
        //Hides
        HideFontUIView()
        
        //Produces Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    //Exit View Button Pressed
    @IBAction func ExitButtonPressed(_ sender: UIButton) {
        //Dimisses the view
        self.dismiss(animated: true
            , completion: nil)
    }
    
    //Email/Send Text To Add Button is Pressed
    @IBAction func EmailButtonPressed(_ sender: UIButton) {
        //Creates a Compose View Controller for Mail
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["MaxHatPro@gmail.com"])
            mail.setSubject("Hyper Typer: New Request")
            mail.setMessageBody("<b>Title</b> <br><br><b>Author</b> <br><br><b>Text/Quote</b> <br><br><b>Type (Book, Movie, Quote, etc.)</b> <br><br><b>Source/Link</b> <br><br><b>App Feedback or Suggestions (optional)</b> ", isHTML: true)
            present(mail, animated: true, completion: nil)
        } else {
            print("Cannot send mail")
        }
        
        //Produces Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //Music is turned On or Off
    @IBAction func MusicSwitchChanged(_ sender: UISwitch) {
        //Updates the value in UserDefaults
        UserDefaults.standard.setValue(MusicSwitch.isOn, forKey: "MusicEnabled")
        
        //Will stop/play the Music
        if (!MusicSwitch.isOn) {
            if (BackgroundMusic.shared.isPlaying()) {
                BackgroundMusic.shared.stopBackgroundMusic()
            }
        } else {
            if (!BackgroundMusic.shared.isPlaying()) {
                BackgroundMusic.shared.startBackgroundMusic()
            }
        }
    }
    
    //Haptic Feedback is turned On or Off
    @IBAction func HapticSwitchChanged(_ sender: UISwitch) {
        //Updates the value in UserDefaults
        UserDefaults.standard.setValue(HapticSwitch.isOn, forKey: "HapticEnabled")
    }
    
    //Will show or hide the Confirm Erase Button
    @IBAction func EraseButtonPressed(_ sender: UIButton) {
        if (ConfirmEraseButton.isHidden == true) {
            ConfirmEraseButton.isHidden = false
            UIView.animate(withDuration: 0.6) {
                self.ConfirmEraseButton.alpha = 1
            }
        } else {
            HideEraseConfirmButton()
        }
        
        //Produces Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @IBAction func ConfirmEraseButtonPressed(_ sender: UIButton) {
        //Clears all of Core Data entities
        for _entityName in appDelegate.getAllEntityNames() {
            CoreDataManager.shared.ClearEntity(EntityName: _entityName)
        }
        
        /*//Clears all of User Defaults data
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()*/
        
        //Shows the confirmation label, then it fades away
        ConfirmEraseLabel.isHidden = false
        ConfirmEraseLabel.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 1, animations: {
                self.ConfirmEraseLabel.alpha = 0
            }, completion: { (done) in
                self.ConfirmEraseLabel.isHidden = true
            })
        }
        
        //Hides the Confirm Button
        HideEraseConfirmButton()
        
        //Produces Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    //Detects touches outside of certain views to perform specified actions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //Touching outside confirm erase button
        if (touch?.view != ConfirmEraseButton && ConfirmEraseButton.isHidden == false) {
            HideEraseConfirmButton()
        }
        //Touching outside Text Font Value and Drop Down
        if (touch?.view != TextFontValueLabel && touch?.view != FontDropDownButton && FontsUIView.isHidden == false) {
            //Resets to previous state
            ResetTextFontValueLabel()
            //Hides
            HideFontUIView()
        }
    }
    
    //Hides the Confirm Erase Button
    private func HideEraseConfirmButton() {
        ConfirmEraseButton.alpha = 0
        ConfirmEraseButton.isHidden = true
    }
    
}
