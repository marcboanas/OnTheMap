//
//  GradientView.swift
//  On The Map
//
//  Created by Marc Boanas on 31/03/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import UIKit

class GradientView: UIView {

    override open class var layerClass: AnyClass {
        get {
            return CAGradientLayer.classForCoder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = self.layer as! CAGradientLayer
        let colorTop = UIColor(red: 254/255, green: 150/255, blue: 45/255, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 253/255, green: 110/255, blue: 34/255, alpha: 1.0).cgColor
        gradientLayer.colors = [colorTop, colorBottom]
    }
}
