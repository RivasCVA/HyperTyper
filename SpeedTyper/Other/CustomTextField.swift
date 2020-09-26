//
//  CustomTextField.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 6/13/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        // Default
        return super.canPerformAction(action, withSender: sender)
    }

}
