//
//  CustomButton.swift
//  On The Map
//
//  Created by Marc Boanas on 14/04/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import UIKit

public class CustomButton: UIButton {
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
    }
}
