//
//  UIColor+Extensions.swift
//  GroupMusic
//
//  Created by Louis on 2021-06-12.
//

import UIKit

extension UIColor {

    // Check if the color is light or dark, as defined by the injected lightness threshold.
    // Some people report that 0.7 is best. I suggest to find out for yourself.
    // A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.5) -> Bool? {
        let originalCGColor = self.cgColor

        // Now we need to convert it to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing components index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}

extension UIColor {
    static let ui = UI()
    
    struct UI {
        let russianViolet = UIColor(named: "RussianViolet")!
        let amaranth = UIColor(named: "Amaranth")!
        let bluetiful = UIColor(named: "Bluetiful")!
        let emerald = UIColor(named: "Emerald")!
        let white = UIColor.white
    }
}
