//
//  Date+Extension.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-24.
//

import Foundation

extension Date {
    /**
     Converts from JavaScript's string represnetation of time to Swift
     */
    static func javaScriptStringRepresentationToDate(stringRepresentation: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: stringRepresentation) {
            return date
        } else {
            return nil
        }
    }
}
